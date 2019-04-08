import jieba
import jieba.analyse
from utility import Utility as Ut

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
        print(vec)
