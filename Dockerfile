FROM nvcr.io/nvidia/deepstream:6.4-gc-triton-devel

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

CMD ["./deepstream", "-s", "file:///data/demo-video-cafe.mp4", "-c", "config_infer_primary_yoloV8_pose.txt"]
