import jieba
import jieba.analyse

#字符串
content = "中文分词是中文文本处理的一个基础步骤，也是中文人机自然语言交互的基础模块，在进行中文自然语言处理时，通常需要先进行分词。"

for x,w in jieba.analyse.extract_tags(content,withWeight = True):
    print('%s,%s' %(x,w))