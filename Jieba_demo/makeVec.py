import jieba
import jieba.analyse
from utility import Utility as Ut
import numpy

class Vec:
    def __init__(self, exIDF:bool=True, exStopWords:bool=True, exDict:bool=True):
        if(exStopWords):
            jieba.analyse.set_stop_words("extra/myStop.txt")
        if(exIDF):
            jieba.analyse.set_idf_path("extra/myIDF.txt")
        if(exDict):
            jieba.load_userdict("extra/myDict.dict")

    def show(self,content:str):
        seg_list = jieba.cut(content)
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

    def simiStrs(self, s1, s2):
        v1 = self.makeVec(s1)
        v2 = self.makeVec(s2)
        result = self.simiVecs(v1, v2)
        return result

    def simiVecs(self, v1, v2):
        s1_cut_code = numpy.array(v1)
        s2_cut_code = numpy.array(v2)
        result = s1_cut_code.dot(s2_cut_code) / (
                numpy.sqrt(s1_cut_code.dot(s1_cut_code)) * numpy.sqrt(s2_cut_code.dot(s2_cut_code)))
        # print(result)
        return result

    def simiVecText(self, s1):
        vecs = Ut.file2List('extra/myVec.txt')
        v1 = self.makeVec(s1)
        bestValue = 0
        target = 'none'
        v2 = []
        for v in vecs:
            v2 =v
            result = self.simiVecs(v1, v2)
            if (result > bestValue):
                bestValue = result
                target = v2
        return [bestValue, target]

    def simiStrText(self, s1):
        fr = open('extra/questionList.txt')
        s2 = fr.readline()
        bestValue = 0
        target = 'none'
        while(s2):
            result = self.simiStrs(s1,s2)
            if(result > bestValue):
                bestValue = result
                target = s2
            s2 = fr.readline()
        return [bestValue, target]

    def makeVecFile(self, file_name):
        fr = open(file_name, 'r')
        fw = open('extra/myVec.txt', 'w', encoding='utf-8')
        content = fr.readline()
        while(content):
            vec = self.makeVec(content)
            fw.write(vec.__str__()+'\n')
            content = fr.readline()
        fr.close()
        fw.close()
        print('向量字典构造结束')


