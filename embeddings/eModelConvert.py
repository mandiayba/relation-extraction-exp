#!/usr/bin/env python
# coding: utf-8

# In[6]:

import sys, os
from gensim.models import KeyedVectors
from gensim.test.utils import datapath
import gensim
import json
import numpy
from sys import stderr, stdin
import gzip
import vecto
from vecto.embeddings import load_from_dir



def to_vocab_matrix(src_model_path=None, tgt_model_path="vocab-matrix.json.gz"):
    """
    Convert word2vec models to vocabulary matrix (contes VST)

    @param src_model_path: path to the source model (has extensions .bin or .txt)
    @param tgt_model_path: path to the target model (has extension .json.gz)

    """

    if src_model_path.endswith('.bin'):
        w2v_model_from_bin = KeyedVectors.load_word2vec_format(src_model_path, binary=True)
        VST = dict((k, list(numpy.float_(npf32) for npf32 in w2v_model_from_bin.wv[k])) for k in w2v_model_from_bin.wv.vocab.keys())
        f = gzip.open(tgt_model_path, 'w')
        f.write(json.dumps(VST).encode('UTF-8'))
        f.close()
    elif src_model_path.endswith('.txt'):
        w2v_model_from_bin = KeyedVectors.load_word2vec_format(src_model_path, binary=False)
        VST = dict((k, list(numpy.float_(npf32) for npf32 in w2v_model_from_bin.wv[k])) for k in w2v_model_from_bin.wv.vocab.keys())
        f = gzip.open(tgt_model_path, 'w')
        f.write(json.dumps(VST).encode('UTF-8'))
        f.close()


def fromVecto2Txt(src_model_folder=None, tgt_model_folder="vocab-matrix.json.gz"):
    """
    Convert vecto models to vocabulary matrix (contes VST) requires (python=3.5)

    @param src_model_path: path to the source model (has extensions .bin or .txt)
    @param tgt_model_path: path to the target model (has extension .json.gz)
    """
    
    my_vsm = load_from_dir(src_model_folder_path)
    my_vsm.save_to_dir_plain_txt(tgt_model_folder)
    src = tgt_model_folder + "vector.txt"
    to_vocab_matrix(src_model_path=src, tgt_model_path=tgt)



if __name__=="__main__":
       
    from optparse import OptionParser, OptionGroup
    optparser = OptionParser(description="Convert word2vec models to vocabulary matrix")
    # parameters
    group = OptionGroup(optparser, "Input Files", "If these are undefined, a task (-t) specific corpus file will be used")
    group.add_option("-i", "--inputFile", default=None, dest="inputFile", help="path to the source model (support w2v .bin or .txt")
    group.add_option("-o", "--outputFile", default=None, dest="outputFile", help="path to the target vocabulary")
    optparser.add_option_group(group)
    
    (options, args) = optparser.parse_args()
  
    assert options.inputFile != None
    to_vocab_matrix(src_model_path=options.inputFile, tgt_model_path=options.outputFile)
