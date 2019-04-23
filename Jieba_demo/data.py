# -*- coding: cp936 -*-
import jieba
import jieba.posseg as pseg
import os
import sys
from sklearn import feature_extraction
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.feature_extraction.text import CountVectorizer
from numpy import *

# fr = open('exercise.txt')
# fr_list = fr.read()
# dataList = fr_list.split('\n')
# data = []
# for oneline in dataList:
#     data.append(" ".join(jieba.cut(oneline)))
# s = "你是谁"
# content = jieba.cut(s)
# data = [" ".join(content)]
data = ["你 是 哪家 银行 的 呀"]
print(data)
#将得到的词语转换为词频矩阵
freWord = CountVectorizer()
print(freWord)
#统计每个词语的tf-idf权值
transformer = TfidfTransformer()
print(transformer)
#计算出tf-idf(第一个fit_transform),并将其转换为tf-idf矩阵(第二个fit_transformer)
tfidf = transformer.fit_transform(freWord.fit_transform(data))
print(tfidf)
#获取词袋模型中的所有词语
word = freWord.get_feature_names()

#得到权重
weight = tfidf.toarray()
print(weight)