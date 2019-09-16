FROM rubensa/ubuntu-dev
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Add conda binary to PATH
ENV PATH="/opt/conda/bin:$PATH"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Install miniconda as root
RUN curl -o $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    # See https://github.com/ContinuumIO/anaconda-issues/issues/11148
    && mkdir ~/.conda \
    && /bin/bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate base" >> ~/.bashrc \
    # Configure conda for multiple users (https://medium.com/@pjptech/installing-anaconda-for-multiple-users-650b2a6666c6)
    && chmod -R go-w+rX /opt/conda

# Tell docker that all future commands should be run as the non-root user (defined at rubensa/ubuntu-dev)
USER $DEV_USER:$DEV_GROUP

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME=/home/$DEV_USER

# Configure conda for the non-root user
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate base" >> ~/.bashrc
