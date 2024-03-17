FROM nvcr.io/nvidia/deepstream:6.4-gc-triton-devel

# Install additional packages
RUN apt-get update && apt-get install -y \
    libjson-glib-dev \
    #libssl3 \
    libssl-dev \
    libgstreamer1.0-0 \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libgstreamer-plugins-base1.0-dev \
    libgstrtspserver-1.0-0 \
    libgstrtspserver-1.0-dev \
    libjansson4 \
    libyaml-cpp-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -y --no-install-recommends install \
    git \
    gstreamer-1.0 \
    gstreamer1.0-dev \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-tools \
    gir1.2-gstreamer-1.0

# Add open GL libraries and other required components. Added new gstreamer components and additional components including CVE patches
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive  apt-get install -y --no-install-recommends \
        pkg-config \
        libglvnd-dev \
        libgl1-mesa-dev \
        libegl1-mesa-dev \
        libgles2-mesa-dev \
        libegl-mesa0 \
        libglib2.0-dev \
        libcjson-dev \
        libssl-dev \
        wget \
        libyaml-cpp-dev \
        libssl-dev \
        openssl \
        gnutls-bin \
        gstreamer1.0-tools \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-alsa \
        libgstreamer1.0-0 \
        libgstrtspserver-1.0-0 \
        libjansson4 \
        librabbitmq4 \
        libuuid1 \
        libc-bin \
        libcurl3-gnutls \
        libcurl4 \
        libjson-glib-1.0-0 \
        gstreamer1.0-rtsp \
        rsyslog \
        git \
        openssl \
        python3 \
        python3-pip \
        libjsoncpp-dev \
        gcc \
        libjpeg-dev \
        libxml2 \
        zlib1g \
        tzdata && \
        rm -rf /var/lib/apt/lists/* && \
        apt autoremove

RUN apt-get update && apt-get install -y \
    libmpeg2-4 \
    libx265-199 \
    libmpg123-0 \
    libavcodec-extra \
    libde265-0

RUN pip3 install ultralytics==8.1.29
RUN pip3 install onnx onnxsim onnxruntime

WORKDIR /

RUN wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8s-pose.pt

COPY ./utils/export_yoloV8_pose.py ./utils/export_yoloV8_pose.py

RUN python3 utils/export_yoloV8_pose.py -w yolov8s-pose.pt --dynamic

COPY ./ ./

RUN export CUDA_VER=12.1 && make -C nvdsinfer_custom_impl_Yolo_pose && make
RUN export GST_DEBUG=5

# Setup environment variables for CUDA Toolkit
# To get video driver libraries at runtime (libnvidia-encode.so/libnvcuvid.so)
ENV NVIDIA_DRIVER_CAPABILITIES $NVIDIA_DRIVER_CAPABILITIES,video,compute,graphics,utility

ENV CUDA_HOME=/usr/local/cuda-12.1
ENV CFLAGS="-I$CUDA_HOME/include $CFLAGS"
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV GST_PLUGIN_PATH=/usr/lib/x86_64-linux-gnu/gstreamer-1.0:/usr/local/lib/gstreamer-1.0
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/lib:$LD_LIBRARY_PATH

CMD ["./deepstream", "-s", "file:///data/demo-video-cafe.mp4", "-c", "config_infer_primary_yoloV8_pose.txt"]
