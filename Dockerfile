FROM nvcr.io/nvidia/deepstream:6.4-samples-multiarch

# Setup environment variables for CUDA Toolkit
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

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
        libssl3 \
        gnutls-bin \
        gstreamer1.0-tools \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-alsa \
        libssl3  \
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
        libjsoncpp-dev \
        gcc \
        libjpeg-dev \
        libxml2 \
        zlib1g \
        tzdata && \
        rm -rf /var/lib/apt/lists/* && \
        apt autoremove

RUN pip3 install ultralytics==8.1.29
RUN pip3 install onnx onnxsim onnxruntime
RUN wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8s-pose.pt

COPY ./utils/export_yoloV8_pose.py ./utils/export_yoloV8_pose.py

RUN python3 utils/export_yoloV8_pose.py -w yolov8s-pose.pt --dynamic

COPY . .

RUN export CUDA_VER=12.3
RUN make -C nvdsinfer_custom_impl_Yolo_pose
RUN make


CMD ["./deepstream", "-s", "file:///data/demo-video-cafe.mp4", "-c", "config_infer_primary_yoloV8_pose.txt"]
