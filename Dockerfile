FROM simexp/octave:3.8.1
MAINTAINER Pierre Bellec <pierre.bellec@criugm.qc.ca>

# Install NIAK from the tim of master
RUN cd /home/ &&  git clone  --single-branch --branch master --depth 1  https://github.com/poquirion/docker_build.git niak

# Install PSOM
RUN cd /home/niak/extensions && wget http://www.nitrc.org/frs/download.php/7065/psom-1.0.2.zip && unzip psom-1.0.2.zip && rm psom-1.0.2.zip

# Install BCT
RUN cd /home/niak/extensions && wget https://sites.google.com/site/bctnet/Home/functions/BCT.zip && unzip BCT.zip && rm BCT.zip

# Build octave configure file
RUN echo addpath\(genpath\(\"/home/niak/\"\)\)\; >> /etc/octave.conf


# Command to run octave as GUI
# docker run -i -t --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v $HOME:$HOME --user $UID:$GID poquirion/docker_build /bin/bash -c "cd $HOME; source /opt/minc-itk4/minc-toolkit-config.sh; octave --force-gui"
