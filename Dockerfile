FROM rubensa/ubuntu-dev
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Add conda binary to PATH
ENV PATH="$SHARED_FOLDER/conda/bin:$PATH"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Install miniconda as root
RUN curl -o $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    # See https://github.com/ContinuumIO/anaconda-issues/issues/11148
    && mkdir ~/.conda \
    && chmod +x ~/miniconda.sh \
    && /bin/bash -c "umask 002; ~/miniconda.sh -b -p $SHARED_FOLDER/conda" \
    && rm ~/miniconda.sh \
    && ln -s $SHARED_FOLDER/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && printf "\n. $SHARED_FOLDER/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && printf "conda activate base\n" >> ~/.bashrc \
    # Fix group
    && chgrp -R shared $SHARED_FOLDER/conda

# Tell docker that all future commands should be run as the non-root user (defined at rubensa/ubuntu-dev)
USER $DEV_USER

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME=/home/$DEV_USER

# Configure conda for the non-root user
RUN printf "\n. $SHARED_FOLDER/conda/etc/profile.d/conda.sh\nconda activate base\n" >> ~/.bashrc \
    # Use shared folder for packages and environments
    && printf "envs_dirs:\n  - $SHARED_FOLDER/conda/envs\npkgs_dirs:\n   - /shared/conda/pkgs\n" >> ~/.condarc \
    # See https://github.com/ContinuumIO/anaconda-issues/issues/11148
    && mkdir ~/.conda

