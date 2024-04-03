FROM nvcr.io/nvidia/deepstream:6.4-gc-triton-devel

# Install additional apt packages
RUN apt-get update && apt-get install -y \
    xvfb \
    libssl3 \
    libssl-dev \
    libgstreamer1.0-0 \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libgstreamer-plugins-base1.0-dev \
    libgstrtspserver-1.0-0 \
    libjansson4 \
    libyaml-cpp-dev \
    libjsoncpp-dev \
    protobuf-compiler \
    gcc \
    make \
    git \
    python3 \
    ffmpeg \
    libmpg123-0 \
    && rm -rf /var/lib/apt/lists/*


RUN pip3 install ultralytics==8.1.29
RUN pip3 install onnx onnxsim onnxruntime

RUN wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8s-pose.pt

COPY ./utils/export_yoloV8_pose.py ./utils/export_yoloV8_pose.py

RUN python3 utils/export_yoloV8_pose.py -w yolov8s-pose.pt --dynamic

WORKDIR /

COPY . .

# Setup environment variables for CUDA Toolkit
# To get video driver libraries at runtime (libnvidia-encode.so/libnvcuvid.so)
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,graphics,utility
ENV NVIDIA_VISIBLE_DEVICES all
ENV GST_DEBUG=3
ENV CUDA_VER=12.3
ENV CUDA_HOME=/usr/local/cuda-${CUDA_VER}
ENV CFLAGS="-I$CUDA_HOME/include $CFLAGS"
ENV PATH=${CUDA_HOME}/bin:${PATH}
#ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
#ENV LD_LIBRARY_PATH=/usr/lib:/usr/local/lib:$LD_LIBRARY_PATH
# Set up the Xvfb environment variables

RUN make -C nvdsinfer_custom_impl_Yolo_pose && make
