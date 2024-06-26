# The base image for PyTorch GPU
# If NVCC is required, select the 'devel' version; otherwise choose the 'runtime' version
# FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel
FROM pytorch/pytorch:1.8.1-cuda10.2-cudnn7-runtime

# Install inotify-tools to monitor changes and nano and less
RUN apt-get -y update && apt -y install inotify-tools curl
RUN apt-get -y install nano less unzip wget
# Install AWS CLI (removed if unnecessary)
# RUN apt -y install unzip
# COPY awscli-bundle-1.32.0.zip /usr/local/bin/awscli-bundle.zip
# RUN cd /usr/local/bin && unzip awscli-bundle.zip && rm awscli-bundle.zip && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && rm -r awscli-bundle

# Install Azure AzCopy CLI (removed if unnecessary)
# COPY azcopy_linux_amd64_10.22.2.tar.gz /usr/local/bin/azcopy_linux_amd64.tar.gz
# RUN cd /usr/local/bin && tar --strip-components=1 --exclude=*.txt -xf azcopy_linux_amd64.tar.gz && rm azcopy_linux_amd64.tar.gz

# Install GCP CLI (removed if unnecessary)
# RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-461.0.0-linux-x86_64.tar.gz > /usr/local/google-cloud-cli.tar.gz
# RUN cd /usr/local && tar -xf google-cloud-cli.tar.gz && rm google-cloud-cli.tar.gz
# ENV PATH $PATH:/usr/local/google-cloud-sdk/bin

# Install JupyterLab
RUN mkdir Installed
RUN cd Installed
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
RUN pip install jupyterlab
RUN pip install ipywidgets

# Install HuggingFace
RUN pip install transformers
RUN pip install datasets
# RUN pip install accelerate, for Distributed Training using PyTorch

# Tokenizer and Detokenizer
RUN pip install sentencepiece

# Install the AutoAWQ to support the quantized models - PyTorch GPU
# RUN pip install https://github.com/casper-hansen/AutoAWQ/releases/download/v0.1.6/autoawq-0.1.6+cu118-cp310-cp310-linux_x86_64.whl

# Install additional libraries and dependencies to special needs
RUN pip install matplotlib


# Generate the Jupyterlab configuration file
RUN jupyter lab --generate-config

# The target directory for data persistence
ENV target_dir /root/data

# Set the current working directory
RUN mkdir -p /root/data
COPY examples /root/data/examples
WORKDIR /root/data

# Some useful tools
COPY tools.ipynb /root/data/tools.ipynb

# Copy the shell file
COPY start.sh /root/start.sh
RUN chmod +x /root/start.sh

# The TCP port for the JupyerLab service
EXPOSE 8000

# Execute the script file when the container is running
RUN touch /root/welcome.txt.backup && echo "Image: JupyterLab + PyTorch GPU " >> /root/welcome.txt.backup
CMD /root/start.sh
