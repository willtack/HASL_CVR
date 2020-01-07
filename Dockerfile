FROM ubuntu:16.04
MAINTAINER Will Tackett <william.tackett@pennmedicine.upenn.edu>

# Update
RUN apt-get update
RUN apt-get install wget -y

# Install zip and jq
RUN apt-get install zip unzip -y
RUN apt-get install -y jq

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}
RUN mkdir -p ${FLYWHEEL}/opt

# Install MCR. Install path: usr/local/MATLAB/MATLAB_Runtime/v96
RUN wget -O opt/mcr.zip http://ssd.mathworks.com/supportfiles/downloads/R2019a/Release/0/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019a_glnxa64.zip
RUN unzip opt/mcr.zip -d opt/
RUN opt/install -mode silent -agreeToLicense yes

# Install libs
RUN apt-get -y install libxmu6

# Copy stuff over
COPY . /flywheel/v0/
RUN chmod +x ${FLYWHEEL}/*

# Change permissions
RUN chmod 777 /

# Configure entrypoints-
ENTRYPOINT ["/flywheel/v0/run"]
