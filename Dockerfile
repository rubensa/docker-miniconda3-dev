FROM rubensa/ubuntu-dev
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME /root

# Add conda binary to PATH
ENV PATH /opt/conda/bin:$PATH

# Install miniconda
RUN curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    # See https://github.com/ContinuumIO/anaconda-issues/issues/11148
    && mkdir ~/.conda \
    && /bin/bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh \
    && /opt/conda/bin/conda clean -tipsy \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate base" >> ~/.bashrc \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
    && /opt/conda/bin/conda clean -afy \
    # Configure conda for multiple users (https://medium.com/@pjptech/installing-anaconda-for-multiple-users-650b2a6666c6)
    && chmod -R go-w+rX /opt/conda

# Tell docker that all future commands should be run as the non-root user
USER ${USER}:${GROUP}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/$USERNAME

# Configure conda for the non-root user
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/$USER/.bashrc \
    && echo "conda activate base" >> /home/$USER/.bashrc
