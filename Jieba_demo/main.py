from makeIDF import IDF
from makeVec import Vec

d = IDF()
d.make_idf()
m = Vec(True)
m.make_vec_file()

s = input()
while(s):
    # print(m.simi_vec_text(s))
    # print(m.simi_str_text(s))
    print(m.simi_answermap_vec(s))
    # print(m.simi_answermap(s))
    s = input()

'''
s = input()
s1 = input()
while(s!= "再见" ):
    #m.show(s)
    #m.show(s1)
    print(m.simiStrs(s, s1))
    s = input()
    s1 = input()

'''