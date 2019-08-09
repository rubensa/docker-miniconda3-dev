FROM continuumio/miniconda3
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Define user and group
ARG USER=developer
ARG GROUP=developers

# Configure apt and install packages
RUN apt-get update \
    #
    # Verify sudo installed
    && apt-get -y install --no-install-recommends sudo 2>&1 \
    #
    # Verify git installed
    && apt-get -y install git \
    #
    # create developer user (1000) and group (1000)
    && addgroup --gid 1000 $GROUP \
    && adduser --uid 1000 --ingroup $GROUP --home /home/$USER --shell /bin/bash --disabled-password --gecos "Developer" $USER \
    #
    # add user to sudoers
    && echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER \
    #
    # add fixuid
    && curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
    && chown root:root /usr/local/bin/fixuid \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: $USER\ngroup: $GROUP\npaths:\n  - /home/$USER" > /etc/fixuid/config.yml

# Configure conda for multiple users (https://medium.com/@pjptech/installing-anaconda-for-multiple-users-650b2a6666c6)
RUN chmod -R go-w+rX /opt/conda

# Configure conda for developer user
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/$USER/.bashrc && \
    echo "conda activate base" >> /home/$USER/.bashrc

# Tell docker that all future commands should be run as the user
USER $USER:$GROUP

# Set the default shell to bash rather than sh
ENV SHELL /bin/bash

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/$USER

# Allways run fixuid
ENTRYPOINT ["fixuid"]

