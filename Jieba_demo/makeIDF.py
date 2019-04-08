import jieba
import jieba.analyse
import math
from utility import Utility as Ut

class IDF:
    def __init__(self, filename: str = "extra/questionList.txt"):
        self.f = filename
        jieba.load_userdict("extra/myDict.dict")

    def makeIDF(self):
        all_dict = {}
        fp = open(self.f, 'r')
        s = fp.readline()
        total = 0

        while (s):
            cut_line = jieba.cut(s)
            stopwords = Ut.file2List("extra/myStop.txt")
            outstr = []
            for word in cut_line:
                if word not in stopwords:
                    if word != '\t' and word != '\n':
                        outstr.append(word)
            for word in outstr:
                if ' ' in outstr:
                    outstr.remove(' ')
            temp_dict = {}
            total += 1
            for word in outstr:
                #print(word)
                temp_dict[word] = 1
            for key in temp_dict:
                num = all_dict.get(key, 0)
                all_dict[key] = num + 1

            #print(temp_dict)
            #print(all_dict)
            #print(total)
            s = fp.readline()
            fp.close


        idf_dict = {}
        for key in all_dict:
            # print(all_dict[key])
            w = key
            p = '%.10f' % (math.log10(total / (all_dict[key] + 1)))
            if w > u'\u4e00' and w <= u'\u9fa5':
                idf_dict[w] = p
        print('IDF字典构造结束')
        fw = open('extra/myIDF.txt', 'w', encoding='utf-8')
        fw2 = open('extra/myWordsLib.txt', 'w', encoding='utf-8')

        for k in idf_dict:
            if k != '\n':
                fw.write(k + ' ' + idf_dict[k] + '\n')
                fw2.write(k + '\n')
        fw.close()
        fw2.close()




