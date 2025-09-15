#!/bin/bash

model_dir="/data/orlando/workspace/llama.cpp_forward/models/MobileVLM-1.7B"
projector_name="mmproj-model-f16.gguf"
llama_name="ggml-model-q4_k.gguf"
img_dir="/data/orlando/workspace/llama.cpp_forward/models/MobileVLM-1.7B/llm"
# img_name="demo.jpg"
# prompt="A chat between a curious user and an artificial intelligence assistant. The assistant gives helpful, detailed, and polite answers to the user's questions. USER: <image>\nWho is the author of this book? \nAnswer the question using a single word or phrase. ASSISTANT:"
# img_name="cat.jpeg"
# prompt="A chat between a curious user and an artificial intelligence assistant. The assistant gives helpful, detailed, and polite answers to the user's questions. USER: <image>\nWhat is in the image? ASSISTANT:"
img_name="task1_1.jpg"
prompt="You're following a set of instructions on Android Phones with your knowledge. The step instructions are '['Unlock your Android device and locate the messaging app icon on your home screen or app drawer.', 'Tap on the messaging app icon to open it.', 'Once the app is open, look for a chat icon, usually represented by a speech bubble or messaging symbol, located at the bottom right or top right corner of the screen.', 'Tap on the chat icon to access your chat list.', 'Scroll through your chat list to find the conversation you want to open.', 'Tap on the conversation to open the chat.', 'Confirm finished all instructions or can't move forward']'. Previous actions are described in ['click 'Messages','press the back button on the Android Phone', 'click 'Start chat', 'press the back button on the Android Phone', 'press the back button on the Android Phone'] and all screenshots are attached. Actionable controls on current screen are:  Actionable controls on current screen are: index: 0, type: button, text: Search messages, location: [806, 148, 933, 274] index: 1, type: button, text: Account and settings.Choose an account, location: [933, 148, 1080, 274] Given those screens and previous actions, please indicate the next action following instructions. If all instructions are completed or you can't use other available actions to finish the next instruction, please provide a 'response' action with a brief reason in action_parameter. Other available actions are: click, input, enter, back, clear. If a click is required, set action_parameter by one 'type: button' index and set long_hold as 1 if long_hold as 1 if need to hold. If an input is needed, set item_index by one 'type: input' index and set action_parameter by input text. For enter and clear actions, set action_parameter by one 'type: input' index. Use back to navigate to the previous screen without parameter. The default value of both item_index and long_hold is -1. For Google map or Here WeGo: choose 'Baskin Engineering, Santa Cruz, CA', or '3022 Baronian Ct, Soquel, CA' or other locations when choose destination or search/find a location; add stop 'Shun Feng Restaurant, Santa Cruz, CA'. Please avoid repeating the same action on the same screen. For eBay,  Tell eBay you want to sell a macbookPro 2016. Could you just output a simple json with action type in action_type, action_parameter, confidence_level field(a value between 0 and 1 about how confident it is), instruction_step from the step index in instructions between 0 and 6 which help make such decision, item_index and long_hold?. ASSISTANT:"

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
    adb push ${img_dir}/${img_name} ${deviceDir}/${img_name}
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
