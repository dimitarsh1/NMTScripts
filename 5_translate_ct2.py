#!/usr/bin/python3
# -*- coding: utf-8 -*-

import argparse
import ctranslate2
from joblib import Parallel, delayed

def main():
    ''' main function '''
    # read argument - file with data
    parser = argparse.ArgumentParser(description='Translates using ctranslate2.')
    parser.add_argument('-i', '--input', required=True, help='the file containing preprocessed sentences.')
    parser.add_argument('-o', '--output', required=True, help='the output file.')
    parser.add_argument('-m', '--model-dir', required=True, help='the to use for translation.')
    parser.add_argument('-g', '--gpuid', required=False, help='the id of the gpu to use for translation.', default='0')
    
    args = parser.parse_args()

    print(args.model_dir)
    print(args.input)
    print(args.output)
    print(str(args.gpuid))
    translator = ctranslate2.Translator(model_path = args.model_dir, device="cuda", device_index=int(args.gpuid))
    
    translator.translate_file(input_path = args.input, output_path = args.output, beam_size = 1)


if __name__ == "__main__":
    main()
