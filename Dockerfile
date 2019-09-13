FROM rubensa/ubuntu-dev
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Add conda binary to PATH
ENV PATH="$HOME/miniconda/bin:$PATH"

# Install miniconda
RUN curl -o $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    # See https://github.com/ContinuumIO/anaconda-issues/issues/11148
    && mkdir $HOME/.conda \
    && /bin/bash $HOME/miniconda.sh -b -p $HOME/miniconda \
    && rm $HOME/miniconda.sh \
    && $HOME/miniconda/bin/conda clean -tipsy \
    && echo ". $HOME/miniconda/etc/profile.d/conda.sh" >> $HOME/.bashrc \
    && echo "conda activate base" >> $HOME/.bashrc