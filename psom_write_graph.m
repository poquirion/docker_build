function [flag_fail,err_msg] = psom_write_graph(file_name,graph,opt)
%
% _________________________________________________________________________
% SUMMARY PSOM_WRITE_GRAPH
%
% Write a graph in the graphviz .dot format
%
% SYNTAX
% [FLAG_FAIL,ERR_MSG] = PSOM_WRITE_GRAPH(FILE_NAME,GRAPH,LABEL_NODES)
%
% _________________________________________________________________________
% INPUTS:
%
% FILE_NAME
%       (string) the file name to save the graph (should end with .dot)
%
% GRAPH
%       (sparse matrix) GRAPH(I,J) == 1 if there is an arrow from node I to
%       node J.
%
% OPT
%       (structure) with the following fields :
%
%       LABEL_NODES
%           (cell of string, default {'NODE1',...}) LABEL_NODES{I} is the 
%           label of node number I.
%                       description of the graph will be saved.
%
% _________________________________________________________________________
% OUTPUTS:
%
% FLAG_FAIL
%       (boolean) if FLAG_FAIL~=0, an error occured when generating the
%       file.
%
% ERR_MSG      
%       (string) if an error occured, ERR_MSG is the error message.
%
% _________________________________________________________________________
% COMMENTS:
% 
% A .dot description of the graph is saved in the file FILE_NAME.
%
% The graphviz toolbox can be used to visualize the graph. See:
% http://www.graphviz.org/
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : graph, dot

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

list_colors = {'"#58a4ff"','"#ffffd0"','"#98ff58"','"#ff9f58f"','"#d0fffa"','#ffd0e7'};
list_shapes = {'box','circle','diamond','ellipse','triangle','egg'};

nbe = length(levels_data);
list_colors = list_colors(:);
list_shapes = list_shapes(:);
while length(list_colors(:))<nbe
    list_colors(:,end+1) = list_colors(:,end);
    list_shapes(:,end+1) = list_shapes(:,end);
end
list_colors = list_colors(:);
list_shapes = list_shapes(:);
        
    
[hf,err_msg] = fopen(file_name,'w+');
if hf == -1
    flag = -1;
    return
else
    flag = 0;
    err_msg = '';
end

fprintf(hf,'digraph database {\n');

str_database2.study = struct_data;
struct_data = str_database2;
struct_data.vars = [];
levels_database2 = cell([length(levels_data)+1 1]);
levels_database2{1} = 'root';
levels_database2(2:end) = levels_data;
levels_data = levels_database2;

clear str_database2
clear levels_database2

for num_l = 1:length(levels_data)
    fprintf(hf,'%s[label="\\N",fillcolor=%s,shape=%s,style = filled]\n',levels_data{num_l},list_colors{num_l},list_shapes{num_l});    
end

for num_l = 1:length(levels_data)-1
    fprintf(hf,'%s -> %s\n',levels_data{num_l},levels_data{num_l+1});    
end


str_simple = niak_database2simplestruct(struct_data);
sub_write_level(hf,struct_data,str_simple,levels_data,list_colors,list_shapes);

fprintf(hf,'}');

fclose(hf)

function [] = sub_write_level(hf,struct_data,str_simple,levels_data,list_colors,list_shapes)

if isfield(struct_data,'vars')
    struct_data = rmfield(struct_data,'vars');
end
if isfield(str_simple,'vars')
    str_simple = rmfield(str_simple,'vars');
end

list_parents = fieldnames(struct_data);
list_nodes = fieldnames(str_simple);

if (size(list_parents,1)>0)
  
    for num_p = 1:length(list_parents)
        
        lab_parent = list_parents{num_p};
        lab_node = list_nodes{num_p};
        str_parent = getfield(struct_data,lab_parent);
        str_simple_parent = getfield(str_simple,lab_node);
        
        if isfield(str_parent,'vars')
            vars = getfield(str_parent,'vars');
        else
            vars = [];
        end
        
        if isempty(vars)
            fprintf(hf,'%s[label="%s",fillcolor=%s,shape=%s,style = filled]\n',lab_node,lab_parent,list_colors{1},list_shapes{1});
        else
            list_vars = fieldnames(vars);
            str_var = '';
            for num_v = 1:length(list_vars)
                str_var = cat(2,str_var,' ',list_vars{num_v});
            end
            fprintf(hf,'%s[label="%s\\n %s",fillcolor=%s,shape=%s,style = filled]\n',lab_node,lab_parent,str_var,list_colors{1},list_shapes{1});
        end
        
        str_parent = rmfield(str_parent,'vars');
        str_simple_parent = rmfield(str_simple_parent,'vars');
        
        list_child = fieldnames(str_simple_parent);
        
        for num_c = 1:length(list_child)
            lab_child = list_child{num_c};
            fprintf(hf,'%s->%s\n',lab_node,lab_child);
        end
        
        sub_write_level(hf,str_parent,str_simple_parent,levels_data(2:end),list_colors(2:end),list_shapes(2:end));
                    
    end
    
end