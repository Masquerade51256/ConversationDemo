from makeIDF import IDF
from match import Match

"""
d = IDF()
d.makeIDF()
m = Match(False)
s = input()
while(s!="再见"):
    m.match(s)
    m.makeVec(s)
    s=input()
"""

d = IDF()
d.makeIDF()
m = Match(False)
s = input()
s1 = input()
while(s!= "再见" ):
    #m.match(s)
    vec = m.makeVec(s)
    #m.match(s1)
    vec1 = m.makeVec(s1)
    m.similarity(vec, vec1)
    s = input()
    s1 = input()

