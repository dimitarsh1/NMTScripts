# NMTMultiPipeline
Train an NMT model with various NMT platforms:
- Nematus
- MarianNMT
- OpenNMT
- OpenNMT-py

> Version 0.1.0\
> Date 22/06/2018

# To train:
Export the following global variables: \
`export SRCLANG=[YOUR SOURCE LANGUAGE CODE, e.g., en]` \
`export TRGLANG=[YOUR TARGET LANGUAGE CODE, e.g., de]` \
`export ENGINEDIR=[THE DIRECTORY WHERE DATA AND MODELS WILL BE KEPT]` 

Run the following scripts in this order to train\
`1_split_ttv.sh [SOURCE_FILE] [TARGET_FILE] [SRCLANG] [TRGLANG] [ENGINEDIR] [TESTCOUNT] [VALCOUNT]`\
`2_tokenize_data.sh [SRCLANG] [TRGLANG] [ENGINEDIR]`\
`3_truecase_data.sh [ENGINEDIR]`\
`4_dictionary.sh [ENGINEDIR]`\
`5_train.sh [ENGINEDIR] [NMT_SYSTEM] [GPU_ID]`

# To translate
Run the following in order to translate\
`6_translate.sh [ENGINEDIR] [INPUT] [NMT_SYSTEM] [GPU_ID]`\
`7_postprocess.sh [INPUT_TR] [TRGLANG]`

### comboscript for translation 
`main_translate.sh [ENGINEDIR] [INPUT] [TRGLANG] [NMT_SYSTEM] [GPU_ID]`

# Arguments for training and translation
`[SOURCE_FILE]` - the source file; in textual format, UTF-8 encoded\
`[TARGET_FILE]` - the target file; in textual format, UTF-8 encoded\
`[SRCLANG]` - the source language code, e.g., en\
`[TRGLANG]` - the target language code, e.g., pt\
`[ENGINEDIR]` - the directory where all the data and models will be stored\
`[TESTCOUNT]` - the count for the test set\
`[VALCOUNT]` - the count for the validation set\
`[NMT_SYSTEM]` - the system you want to train. Choose one of: nematus, marian, opennmt, opennmt-py\
`[GPU_ID]` - the id of the GPU device which you want to run your system on\
`[INPUT]` - file to translate\
`[INPUT_TR]` - translated file to postprocess (reverses BPE, tokenisation and truecasing)

!Currently nematus and marian are supported.

