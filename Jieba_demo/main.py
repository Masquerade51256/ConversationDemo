from makeIDF import IDF
from makeVec import Vec

d = IDF()
d.make_idf_file() # 生成myidf文件和myWordLib文件

m = Vec(True)
m.make_vec_file() # 补充answerMap文件

s = input()
while(s):
    print(m.simi_answermap_vec(s)) # 与answerMap中的向量匹配
    # print(m.simi_answermap(s)) # 与answerMap中的字符串匹配
    s = input()
