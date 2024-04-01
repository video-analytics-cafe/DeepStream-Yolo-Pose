FROM serge3006/deepstream-python-bindings-6.1

WORKDIR /app

# Install kafka
RUN git clone https://github.com/edenhill/librdkafka.git \
    && cd librdkafka \
    && git reset --hard 063a9ae7a65cebdf1cc128da9815c05f91a2a996 \
    && ./configure \
    && make \
    && make install \
    && cp /usr/local/lib/librdkafka* /opt/nvidia/deepstream/deepstream-6.1/lib

# Install aditional dependencies
RUN apt-get install libglib2.0 libglib2.0-dev \
    && apt-get install libjansson4 libjansson-dev

COPY ./requirements.txt requirements.txt

RUN python3 -m pip install -r requirements.txt

COPY ./configs deepstream_kafka/configs
COPY ./model deepstream_kafka/model
COPY ./src deepstream_kafka/src
COPY ./main.py deepstream_kafka/main.py
COPY ./__init__.py deepstream_kafka/__init__.py