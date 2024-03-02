#!/bin/bash

model_dir="/data/orlando/workspace/llama.cpp_forward/models/MobileVLM-1.7B"
projector_name="mmproj-model-f16.gguf"
llama_name="ggml-model-q4_k.gguf"
img_dir="/data/orlando/workspace/llama.cpp_forward/models/MobileVLM-1.7B/llm"
img_name="demo.jpg"
prompt="A chat between a curious user and an artificial intelligence assistant. The assistant gives helpful, detailed, and polite answers to the user's questions. USER: <image>\nWho is the author of this book? \nAnswer the question using a single word or phrase. ASSISTANT:"
# img_name="cat.jpeg"
# prompt="A chat between a curious user and an artificial intelligence assistant. The assistant gives helpful, detailed, and polite answers to the user's questions. USER: <image>\nWhat is in the image? ASSISTANT:"
# img_name="task1_1.jpeg"
# prompt="A chat between a curious user and an artificial intelligence assistant. The assistant gives helpful, detailed, and polite answers to the user's questions. USER: <image>\nWho is the author of this book? \nAnswer the question using a single word or phrase. ASSISTANT:"

program_dir="/data/orlando/workspace/llama.cpp_forward/examples/llava/android/build_64/bin"
binName="llava-cli"
n_threads=4


deviceDir="/data/local/tmp"
saveDir="output"
if [ ! -d ${saveDir} ]; then
    mkdir ${saveDir}
fi


function android_run() {
    # # copy resource into device
    # adb push ${model_dir}/${projector_name} ${deviceDir}/${projector_name}
    # adb push ${model_dir}/${llama_name} ${deviceDir}/${llama_name}
    # adb push ${img_dir}/${img_name} ${deviceDir}/${img_name}
    # # copy program into device
    # adb push ${program_dir}/${binName} ${deviceDir}/${binName}
    # adb shell "chmod 0777 ${deviceDir}/${binName}"

    # run
    # adb shell "echo cd ${deviceDir} ${deviceDir}/${binName} \
    #                                              -m ${deviceDir}/${llama_name} \
    #                                              --mmproj ${deviceDir}/${projector_name} \
    #                                              -t ${n_threads} \
    #                                              --image ${deviceDir}/${img_name} \
    #                                              -p \"${prompt}\" \
    #                                              > ${deviceDir}/${modelName}_${projector_name}_${n_threads}_${img_name}.txt"
    adb shell "cd ${deviceDir}; pwd; ${deviceDir}/${binName} \
                                                 -m ${deviceDir}/${llama_name} \
                                                 --mmproj ${deviceDir}/${projector_name} \
                                                 -t ${n_threads} \
                                                 --image ${deviceDir}/${img_name} \
                                                 -p \"${prompt}\" \
                                                 >> ${deviceDir}/${modelName}_${projector_name}_${n_threads}_${img_name}.txt 2>&1"
    adb pull ${deviceDir}/${modelName}_${projector_name}_${n_threads}_${img_name}.txt ${saveDir}
}

android_run

echo "android_run is Done!"
