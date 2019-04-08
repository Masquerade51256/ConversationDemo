import jieba
import jieba.analyse
from utility import Utility as Ut
import math
import numpy

class Match:
    def __init__(self, exIDF:bool=True, exStopWords:bool=True, exDict:bool=True):
        if(exStopWords):
            jieba.analyse.set_stop_words("extra/myStop.txt")
        if(exIDF):
            jieba.analyse.set_idf_path("extra/myIDF.txt")
        if(exDict):
            jieba.load_userdict("extra/myDict.dict")

    def match(self,content:str):
        seg_list = jieba.cut(content)  # 默认是精确模式
        print(", ".join(seg_list))
        for x, w in jieba.analyse.extract_tags(content,withWeight = True):
            print('%s,%s' %(x, w))

    def makeVec(self,content:str):
        vec=[]
        words = Ut.file2List("extra/myWordsLib.txt")
        seg_list = jieba.analyse.extract_tags(content, withWeight=True)
        for word in words:
            v=0
            for x, w in seg_list:
                if(x==word):
                    v=w
            vec.append(v)

        #print(vec)
        return vec

    def similarity(self, s1_cut_code, s2_cut_code):

        s1_cut_code = numpy.array(s1_cut_code)
        s2_cut_code = numpy.array(s2_cut_code)
        result = s1_cut_code.dot(s2_cut_code) / (
                    numpy.sqrt(s1_cut_code.dot(s1_cut_code)) * numpy.sqrt(s2_cut_code.dot(s2_cut_code)))
        print(result)

        '''
        sum = 0
        sq1 = 0
        sq2 = 0
        for i in range(len(s1_cut_code)):
            sum += s1_cut_code[i] * s2_cut_code[i]
            sq1 += pow(s1_cut_code[i], 2)
            sq2 += pow(s2_cut_code[i], 2)

        try:
            result = round(float(sum) / (math.sqrt(sq1) * math.sqrt(sq2)), 2)
        except ZeroDivisionError:
            result = 0.0
        print(result)
        '''

