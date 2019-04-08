from makeIDF import IDF
from match import Match

d = IDF()
d.makeIDF()
m = Match(False)
s = input()
while(s!="再见"):
    m.match(s)
    m.makeVec(s)
    s=input()