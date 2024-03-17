ARG COG_REPO
ARG COG_MODEL
ARG COG_VERSION

FROM r8.im/${COG_REPO}/${COG_MODEL}@sha256:${COG_VERSION}

# Install necessary packages and Python 3.10
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends software-properties-common curl git openssh-server

RUN apt-get -y install build-essential \
        zlib1g-dev \
        libncurses5-dev \
        libgdbm-dev \
        libnss3-dev \
        libssl-dev \
        libreadline-dev \
        libffi-dev \
        libsqlite3-dev \
        libbz2-dev \
        wget \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get purge -y imagemagick imagemagick-6-common

RUN cd /usr/src \
    && wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz \
    && tar -xzf Python-3.10.0.tgz \
    && cd Python-3.10.0 \
    && ./configure --enable-optimizations \
    && make altinstall

RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 1

# Create a virtual environment
RUN python3 -m venv /opt/venv

# Install runpod within the virtual environment
RUN /opt/venv/bin/pip install runpod firebase==4.0.1 firebase-admin==6.4.0

ADD src/handler.py /rp_handler.py

CMD ["/opt/venv/bin/python3", "-u", "/rp_handler.py"]
