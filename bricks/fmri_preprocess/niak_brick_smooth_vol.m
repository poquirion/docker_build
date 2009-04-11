function [files_in,files_out,opt] = niak_brick_smooth_vol(files_in,files_out,opt)
%
% _________________________________________________________________________
% SUMMARY NIAK_BRICK_SMOOTH_VOL
%
% Spatial smoothing of 3D or 3D+t data, using a Gaussian separable kernel
%
% [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_SMOOTH_VOL(FILES_IN,FILES_OUT,OPT)
%
% _________________________________________________________________________
% INPUTS
%
%  * FILES_IN        
%       (string) a file name of a 3D+t dataset
%
%  * FILES_OUT       
%       (string, default <BASE FILES_IN>.<EXT>) File name for outputs. 
%       NOTE that if FILES_OUT is an empty string or cell, the name of the 
%       outputs will be the same as the inputs, with a '_s' suffix added 
%       at the end.
%
%  * OPT           
%       (structure) with the following fields :
%
%       FWHM  
%           (vector of size [1 3], default [4 4 4]) the full width at half 
%           maximum of the Gaussian kernel, in each dimension. If fwhm has 
%           length 1, an isotropic kernel is implemented.
%
%       FOLDER_OUT 
%           (string, default: path of FILES_IN) If present, all default 
%           outputs will be created in the folder FOLDER_OUT. The folder 
%           needs to be created beforehand.
%
%       FLAG_VERBOSE 
%           (boolean, default 1) if the flag is 1, then the function prints 
%           some infos during the processing.
%
%       FLAG_TEST 
%           (boolean, default 0) if FLAG_TEST equals 1, the brick does not 
%           do anything but update the default values in FILES_IN and 
%           FILES_OUT.
%
% _________________________________________________________________________
% OUTPUTS
%
% The structures FILES_IN, FILES_OUT and OPT are updated with default
% valued. If OPT.FLAG_TEST == 0, the specified outputs are generated.
%
% _________________________________________________________________________
% SEE ALSO
%
% NIAK_SMOOTH_VOL
%
% _________________________________________________________________________
% COMMENTS
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : medical imaging, slice timing, fMRI

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

flag_gb_niak_fast_gb = true;
niak_gb_vars; % load important NIAK variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seting up default arguments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('files_in','var')|~exist('files_out','var')|~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_SMOOTH_VOL(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_smooth_vol'' for more info.')
end

%% Options
gb_name_structure = 'opt';
gb_list_fields = {'fwhm','flag_verbose','flag_test','folder_out','flag_zip'};
gb_list_defaults = {[4 4 4],1,0,'',0};
niak_set_defaults

if length(opt.fwhm) == 1
    opt.fwhm = opt.fwhm * ones([1 3]);
end

if size(opt.fwhm,1)>size(opt.fwhm,2)
    opt.fwhm = opt.fwhm';
end

fwhm = opt.fwhm;

%% Output files

[path_f,name_f,ext_f] = fileparts(files_in(1,:));
if isempty(path_f)
    path_f = '.';
end

if strcmp(ext_f,gb_niak_zip_ext)
    [tmp,name_f,ext_f] = fileparts(name_f);
    ext_f = cat(2,ext_f,gb_niak_zip_ext);
end

if strcmp(opt.folder_out,'')
    opt.folder_out = path_f;
end

%% Building default output names
if isempty(files_out)

    if size(files_in,1) == 1

        files_out = cat(2,opt.folder_out,filesep,name_f,'_s',ext_f);

    else

        name_filtered_data = cell([size(files_in,1) 1]);

        for num_f = 1:size(files_in,1)
            [path_f,name_f,ext_f] = fileparts(files_in(1,:));

            if strcmp(ext_f,'.gz')
                [tmp,name_f,ext_f] = fileparts(name_f);
            end

            name_filtered_data{num_f} = cat(2,opt.folder_out,filesep,name_f,'_s',ext_f);
        end
        files_out = char(name_filtered_data);

    end
end

if flag_test == 1
    return
end

if opt.fwhm ~=0

    %% Blurring

    if flag_verbose
        fprintf('Reading data ...\n');
    end

    [hdr,vol] = niak_read_vol(files_in);

    opt_smooth.voxel_size = hdr.info.voxel_size;
    opt_smooth.fwhm = opt.fwhm;
    opt_smooth.flag_verbose = opt.flag_verbose;
    vol_s = niak_smooth_vol(vol,opt_smooth);    

    %% Updating the history and saving output
    hdr = hdr(1);
    hdr.flag_zip = flag_zip;
    hdr.file_name = files_out;
    opt_hist.command = 'niak_smooth_vol';
    opt_hist.files_in = files_in;
    opt_hist.files_out = files_out;
    hdr = niak_set_history(hdr,opt_hist);
    niak_write_vol(hdr,vol_s);

else

    instr_copy = cat(2,'cp ',files_in,' ',files_out);
    
    [succ,msg] = system(instr_copy);
    if succ~=0
        error(msg)
    end

end