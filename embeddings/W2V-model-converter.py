#!/usr/bin/env python
# coding: utf-8

# In[6]:


from gensim.models import KeyedVectors
from gensim.test.utils import datapath


# ### load pretrained model (since intermediate data is not included, the model cannot be refined with additional data)

# In[7]:


wv_from_bin = KeyedVectors.load_word2vec_format("PubMed-w2v.bin", binary=True)


# In[8]:


import gensim
import json
import numpy
from sys import stderr, stdin
from optparse import OptionParser
import gzip


# In[ ]:


VST = dict((k, list(numpy.float_(npf32) for npf32 in wv_from_bin.wv[k])) for k in wv_from_bin.wv.vocab.keys())


# In[ ]:


### convert to vocab matrix


# In[ ]:


fileName = 'PMC-w2v-skipgram-200.json.gz'
f = gzip.open(fileName, 'w')
f.write(json.dumps(VST).encode('UTF-8'))
f.close()

