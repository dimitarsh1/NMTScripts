from bnlp.nltk_tokenizer import NLTK_Tokenizer
import codecs
import argparse

def main():
    ''' main function '''
    # read argument - file with data
    parser = argparse.ArgumentParser(description='A tokenizer for Bengali.')
    parser.add_argument('-i', '--input', required=True, help='the input file to tokenize.')
    args = parser.parse_args()


    bnltk = NLTK_Tokenizer()

    with codecs.open(args.input, 'r', 'utf8') as ifh:
        for s in ifh.readlines():
            word_tokens = bnltk.word_tokenize(' '.join(s.split()))
            print(' '.join([w.strip() for w in word_tokens]))

if __name__ == "__main__":
    main()

