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
    autoconf \
    automake \
    libtool \
    gstreamer-1.0 \
    gstreamer1.0-dev \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
#    gstreamer1.0-doc \
    gstreamer1.0-tools \
#    gstreamer1.0-x \
#    gstreamer1.0-alsa \
#    gstreamer1.0-gl \
#    gstreamer1.0-gtk3 \
#    gstreamer1.0-qt5 \
#    gstreamer1.0-pulseaudio \
#    python-gst-1.0 \
#    libgirepository1.0-dev \
    libcairo2-dev \
    gir1.2-gstreamer-1.0 \
    python3-gi
#    python-gi-dev

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
