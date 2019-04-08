from makeIDF import IDF
from makeVec import Vec

d = IDF()
#d.makeIDF()
m = Vec()
#m.makeVecFile('extra/questionList.txt')

s = input()
while(s):
    #print(m.simiVecText(s))
    print(m.simiStrText(s))
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