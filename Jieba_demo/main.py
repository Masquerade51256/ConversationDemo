from makeIDF import IDF
from makeVec import Vec
from tfConfig import TfConfig as cfg

d = IDF()
# d.make_idf_file() # 生成myidf文件和myWordLib文件

m = Vec()
# m.make_vec_file() # 补充answerMap文件
c = cfg()
c.set_threshold(0.1)
m.train()
s = input()
while(s):
    # m.show(s)
    # print(m.make_vec(s))
    print(m.simi_answermap_vec(s)) # 与answerMap中的向量匹配
    # print(m.simi_answermap(s)) # 与answerMap中的字符串匹配
    s = input()



