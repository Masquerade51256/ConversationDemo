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
# s = "����˭"
# content = jieba.cut(s)
# data = [" ".join(content)]
data = ["�� �� �ļ� ���� �� ѽ"]
print(data)
#���õ��Ĵ���ת��Ϊ��Ƶ����
freWord = CountVectorizer()
print(freWord)
#ͳ��ÿ�������tf-idfȨֵ
transformer = TfidfTransformer()
print(transformer)
#�����tf-idf(��һ��fit_transform),������ת��Ϊtf-idf����(�ڶ���fit_transformer)
tfidf = transformer.fit_transform(freWord.fit_transform(data))
print(tfidf)
#��ȡ�ʴ�ģ���е����д���
word = freWord.get_feature_names()

#�õ�Ȩ��
weight = tfidf.toarray()
print(weight)