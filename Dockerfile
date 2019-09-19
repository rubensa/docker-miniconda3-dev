FROM rubensa/ubuntu-dev
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Define conda group id's
ARG CONDA_GROUP_ID=2000

# Define conda group and installation folder
ENV CONDA_GROUP=conda CONDA_INSTALL_DIR=/opt/conda

# Add conda binary to PATH
ENV PATH="${CONDA_INSTALL_DIR}/bin:$PATH"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    # 
    # Install ACL
    && apt-get -y install acl \
    #
    # Create a conda group
    && addgroup --gid ${CONDA_GROUP_ID} ${CONDA_GROUP} \
    #
    # Assign conda group to non-root user
    && usermod -a -G ${CONDA_GROUP} ${DEV_USER} \
    #
    # Install conda
    && curl -o $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    # See https://github.com/ContinuumIO/anaconda-issues/issues/11148
    && mkdir ~/.conda \
    && /bin/bash -l ~/miniconda.sh -b -p $CONDA_INSTALL_DIR \
    && rm ~/miniconda.sh \
    #
    # Assign conda group folder ownership
    && chgrp -R ${CONDA_GROUP} ${CONDA_INSTALL_DIR} \
    #
    # Set the segid bit to the folder
    && chmod -R g+s ${CONDA_INSTALL_DIR} \
    #
    # Give write acces to the group
    && chmod -R g+wX ${CONDA_INSTALL_DIR} \
    #
    # Set ACL to files created in the folder
    && setfacl -d -m u::rwX,g::rwX,o::r-X ${CONDA_INSTALL_DIR} \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the non-root user
USER ${DEV_USER}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/$DEV_USER

# Configure conda for the non-root user
RUN printf "\n. ${CONDA_INSTALL_DIR}/etc/profile.d/conda.sh\n" >> ~/.bashrc \
    # Use shared folder for packages and environments
    && printf "envs_dirs:\n  - ${CONDA_INSTALL_DIR}/envs\npkgs_dirs:\n   - ${CONDA_INSTALL_DIR}/pkgs\n" >> ~/.condarc \
    # See https://github.com/ContinuumIO/anaconda-issues/issues/11148
    && mkdir ~/.conda
