FROM ubuntu:16.04
MAINTAINER Will Tackett <william.tackett@pennmedicine.upenn.edu>


# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    curl \
                    bzip2 \
                    ca-certificates \
                    xvfb \
                    cython3 \
                    build-essential \
                    autoconf \
                    wget \
                    libtool \
                    pkg-config \
                    jq \
                    zip \
                    unzip \
                    nano \
                    default-jdk \
                    git && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y --no-install-recommends \
                    nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install FSL
#ENV FSLDIR="/usr/share/fsl"
#RUN apt-get update -qq \
#  && apt-get install -y -q --no-install-recommends \
#         bc \
#         dc \
#         file \
#         libfontconfig1 \
#         libfreetype6 \
#         libgl1-mesa-dev \
#         libglu1-mesa-dev \
#         libgomp1 \
#         libice6 \
#         libxcursor1 \
#         libxft2 \
#         libxinerama1 \
#         libxrandr2 \
#         libxrender1 \
#         libxt6 \
#         wget \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#  && echo "Downloading FSL ..." \
#  && mkdir -p /usr/share/fsl \
#  && curl -fsSL --retry 5 https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-5.0.9-centos6_64.tar.gz \
#  | tar -xz -C /usr/share/fsl --strip-components 1

# Installing Neurodebian packages (FSL, AFNI, git)

# Pre-cache neurodebian key
COPY docker/files/neurodebian.gpg /usr/local/etc/neurodebian.gpg

RUN curl -sSL "http://neuro.debian.net/lists/$( lsb_release -c | cut -f2 ).us-ca.full" >> /etc/apt/sources.list.d/neurodebian.sources.list && \
    apt-key add /usr/local/etc/neurodebian.gpg && \
    (apt-key adv --refresh-keys --keyserver hkp://ha.pool.sks-keyservers.net 0xA5D32F012649A5A9 || true)

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    fsl-core=5.0.9-5~nd16.04+1 \
                    fsl-mni152-templates=5.0.7-2 \
                    afni=16.2.07~dfsg.1-5~nd16.04+1 \
                    git-annex-standalone && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV FSLDIR=/usr/share/fsl/5.0 \
    PATH=/usr/share/fsl/5.0:${PATH} \
    PATH=/usr/share/fsl/5.0/bin:${PATH} \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    LD_LIBRARY_PATH="/usr/lib/fsl/5.0:$LD_LIBRARY_PATH"


#ENV PATH="${FSLDIR}/bin:$PATH"
#ENV FSLOUTPUTTYPE="NIFTI_GZ"

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

# ENV preservation for Flywheel Engine
RUN env -u HOSTNAME -u PWD | \
  awk -F = '{ print "export " $1 "=\"" $2 "\"" }' > ${FLYWHEEL}/docker-env.sh
RUN chmod +x ${FLYWHEEL}/docker-env.sh

# Configure entrypoints-
ENTRYPOINT ["/flywheel/v0/run"]
