<!-- markdownlint-disable MD029 -->
# MobileVLM distilled from Large VLM Model

## Build foundation model for mobile

Reference:

* [llama.cpp Android Tutorial](https://github.com/JackZeng0208/llama.cpp-android-tutorial)

### Build llama.cpp and prepare MobileLVM

```bash
mkdir build
cd build
cmake ..
cmake --build . --config Release
```

Now all executable files are located in build/bin.

### Host mobile

You're supposed to move to models folder in advance.

```bash
cd models/
```

1. clone repositories locally

```bash
git clone https://huggingface.co/mtgv/MobileVLM-1.7B
git clone https://huggingface.co/openai/clip-vit-large-patch14-336
```

2. split the LLaVA model to LLaMA and multimodel projector constituents

```bash
python ../examples/llava/llava-surgery.py -m MobileVLM-1.7B
```

3. Use convert-image-encoder-to-gguf.py with --projector-type ldp to convert the LLaVA image encoder to GGU

```bash
conda activate llama.cpp
python ../examples/llava/convert-image-encoder-to-gguf.py \
    -m ./clip-vit-large-patch14-336 \
    --llava-projector ./MobileVLM-1.7B/llava.projector \
    --output-dir ./MobileVLM-1.7B \
    --projector-type ldp
```

4. Use convert.py to convert the LLaMA part of LLaVA to GGUF:

```bash
python ../convert.py ./MobileVLM-1.7B
```

Issue:

```text
Traceback (most recent call last):
  File "/data/orlando/workspace/llama.cpp_forward/models/../convert.py", line 1483, in <module>
    main()
  File "/data/orlando/workspace/llama.cpp_forward/models/../convert.py", line 1469, in main
    model   = convert_model_names(model, params, args.skip_unknown)
  File "/data/orlando/workspace/llama.cpp_forward/models/../convert.py", line 1206, in convert_model_names
    raise Exception(f"Unexpected tensor name: {name}. Use --skip-unknown to ignore it (e.g. LLaVA)")
Exception: Unexpected tensor name: model.vision_tower.vision_tower.vision_model.embeddings.class_embedding. Use --skip-unknown to ignore it (e.g. LLaVA)
```

corrected with variation:

```bash
python ../convert.py ./MobileVLM-1.7B --skip-unknown
```

5. Use quantize to convert LLaMA part's DataType from fp16 to q4_k

```bash
../build/bin/quantize ./MobileVLM-1.7B/ggml-model-f16.gguf ./MobileVLM-1.7B/ggml-model-q4_k.gguf q4_k_s
```

result as follow:

```txt
llama_model_quantize_internal: model size  =  2602.38 MB
llama_model_quantize_internal: quant size  =   754.43 MB
```

### Android compile and run

1. compile via [examples/llava/android/build_64.sh](examples/llava/android/build_64.sh) with Android NDK prepared

```bash
mkdir examples/llava/android/build_64
export ANDROID_NDK=/data/orlando/android/android_sdk/ndk/26.2.11394342
export NDK=/data/orlando/android/android_sdk/ndk/26.2.11394342
cd examples/llava/android/build_64
../build_64.sh
```

Check Android ABI and device's instruction set architecture and compilation reference from [CMake](https://developer.android.com/ndk/guides/cmake)

```bash
(llama.cpp) orlando@nlp-in-477-l:/data/orlando/workspace/llama.cpp_forward/examples/llava/android/build_64$ adb shell uname -m
aarch64
```

2. pre-testing on linux

```bash
/data/orlando/workspace/llama.cpp_forward/examples/llava/android/build_64/bin/llava-cli -m /data/orlando/workspace/llama.cpp_forward/models/MobileVLM-1.7B/ggml-model-q4_k.gguf \
    --mmproj /data/orlando/workspace/llama.cpp_forward/models/MobileVLM-1.7B/mmproj-model-f16.gguf \
    --image /data/orlando/workspace/llama.cpp_forward/models/MobileVLM-1.7B/llm/demo.jpg \
    -p "A chat between a curious user and an artificial intelligence assistant. The assistant gives helpful, detailed, and polite answers to the user's questions. USER: <image>\nWho is the author of this book? Answer the question using a single word or phrase. ASSISTANT:"
```

3. run on Android by android/adb_run.sh

```bash
cd examples/llava/android/build_64
../adb_run.sh
```

Using adb command to check

```bash
(llama.cpp) orlando@nlp-in-477-l:/data/orlando/workspace/llama.cpp_forward/examples/llava/android/build_64$ adb shell ls -R /data/local/tmp/_mmproj-model-f16.gguf_4_demo.jpg.txt
/data/local/tmp/_mmproj-model-f16.gguf_4_demo.jpg.txt
(llama.cpp) orlando@nlp-in-477-l:/data/orlando/workspace/llama.cpp_forward/examples/llava/android/build_64$ adb shell cat /data/local/tmp/_mmproj-model-f16.gguf_4_demo.jpg.txt
cd /data/local/tmp /data/local/tmp/llava-cli -m /data/local/tmp/ggml-model-q4_k.gguf --mmproj /data/local/tmp/mmproj-model-f16.gguf -t 4 --image /data/local/tmp/demo.jpg -p A chat between a curious user and an artificial intelligence assistant. The assistant gives helpful, detailed, and polite answers to the user's questions. USER: <image>
Who is the author of this book? 
Answer the question using a single word or phrase. ASSISTANT:
/system/bin/sh: /data/local/tmp/llava-cli: not executable: 64-bit ELF file
```
