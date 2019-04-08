import jieba
import jieba.analyse
from utility import Utility as Ut
from configparser import ConfigParser
import numpy
import json


class Vec:
    def __init__(self, ex_idf: bool = True, ex_stop_words: bool = True, ex_dict: bool = True, file_name="extra/answerMap.cfg"):
        if ex_stop_words:
            jieba.analyse.set_stop_words("extra/myStop.txt")
        if(ex_idf):
            jieba.analyse.set_idf_path("extra/myIDF.txt")
        if(ex_dict):
            jieba.load_userdict("extra/myDict.dict")
        self.cfgParser = ConfigParser()
        self.cfgParser.read(file_name, encoding="UTF8")
        self.index = ['1', '2', '3', '4', '5', '6',
                      '7', '8', '9', '10', '11', '3',
                      '13', '14', '15', '16', '17', '18',
                      '19', '20', '21', '22', '23', '24',
                      '25', '26', '27', '28', '29', '30',
                      '30', '31', '32', '33', '34']

    def show(self,content: str):
        seg_list = jieba.cut(content)
        print(", ".join(seg_list))
        for x, w in jieba.analyse.extract_tags(content,withWeight = True):
            print('%s,%s' %(x, w))

    def make_vec(self,content:str):
        vec=[]
        words = Ut.file2List("extra/myWordsLib.txt")
        seg_list = jieba.analyse.extract_tags(content, withWeight=True)
        for word in words:
            v = 0
            for x, w in seg_list:
                if x == word:
                    v = w
            vec.append(v)
        return vec

    def simi_strs(self, s1, s2):
        v1 = self.make_vec(s1)
        v2 = self.make_vec(s2)
        result = self.simi_vecs(v1, v2)
        return result

    def simi_vecs(self, v1, v2):
        result = 0.0
        s1_cut_code = numpy.array(v1)
        s2_cut_code = numpy.array(v2)
        if (numpy.linalg.norm(s1_cut_code) != 0.0) & (numpy.linalg.norm(s2_cut_code) != 0.0):
            result = s1_cut_code.dot(s2_cut_code) / (numpy.sqrt(s1_cut_code.dot(s1_cut_code)) * numpy.sqrt(s2_cut_code.dot(s2_cut_code)))
        return result

    def make_vec_file(self, file_name="extra/answerMap.cfg"):
        for i in self.index:
            vec = self.make_vec(self.cfgParser[i]['question'])
            self.cfgParser[i]['vector'] = str(vec)
        with open(file_name, 'w+') as fw:
            self.cfgParser.write(fw)
        print('向量字典构造结束')

    def simi_answermap(self, s1):
        target = 'none'
        answer = 'none'
        bestValue = 0
        for i in self.index:
            s2 = self.cfgParser[i]['question']
            result = self.simi_strs(s1, s2)
            if (result > bestValue):
                bestValue = result
                answer = self.cfgParser[i]['answer']
                target = i
        return [bestValue, target, answer]

    def simi_answermap_vec(self, s1):
        v1 = self.make_vec(s1)
        target = 'none'
        answer = 'none'
        bestValue = 0
        for i in self.index:
            v2 = json.loads(self.cfgParser[i]['vector'])
            result = self.simi_vecs(v1, v2)
            if (result > bestValue):
                bestValue = result
                answer = self.cfgParser[i]['answer']
                target = i
        return [bestValue, target, answer]