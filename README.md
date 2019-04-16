# 语句在语料库中进行tf-idf特征匹配

## 项目内容与自测结果

1. 建立了自己的词库、停止词库、IDF词典、tf-idf向量词典以及回答词典；

2. 实现了根据输入语句的tf-idf特征向量在回答词典中匹配，并输出相应的回答；

3. 输入输出格式；

   1. 输入：循环输入一行中文字符

   2. 输出：列表，[余弦相似度，问题在answerMap中的编号，回答内容]

   3. 示例：

      ```
      << IDF字典构造结束
      << 向量字典构造结束
      >> 我老婆也有一张招行卡，她也能参加吗？
      << [0.4562206819651142, '17', '如果满足条件是可以的。具体情况，我们的理财经理会在5个工作日内跟您联系，为您详细解答。']
      ```

4. 自测结果。

   字符串输入匹配效果不甚理想，在不参照话术表的情况下，初次测验（十条语句输入，下同）的正确率（指实际输出与预期相符，下同）仅为50%，主要原因是话术表中每个回答对应的用户提问语句过少，未包含所有可能出现的词语。经过多次补充添加，现在正确率可达80%～90%。

## 文件说明

1. ##### `answerMap.cfg`

   以每个回答类型为section，section名为1至34的编号，包含回答的内容（answer）、用户可能的问题（question）和用户问题对应的tf-idf特征向量（vector），示例如下：

   ```
   [1]
   question = 你们公司叫什么？你们是哪家公司的？你们什么银行的？
   answer = 我们是招商银行南京分行，我是这次活动的客服专员。
   vector = [0.23299000143333332, 0.27623067748888885, 0, 0.14243956831111113, 0, ...]
   ```

2. ##### `myDict.txt`

   添加语句库中一些专有词，使jieba能够有效分词。

3. ##### `myIDF.dict`

   自定义IDF词库，储存分词结果及对应IDF值，用于替换默认IDF词库，提高匹配精度，可在`Vec`对象初始化时选择是否使用`myIDF`。

   ```python
       def __init__(self, 
       	ex_idf: bool = True, 
       	ex_stop_words: bool = True, 
       	ex_dict: bool = True, 
       	file_name="extra/answerMap.cfg"):
           if ex_stop_words:
               jieba.analyse.set_stop_words("extra/myStop.txt")
           if ex_idf:
               jieba.analyse.set_idf_path("extra/myIDF.txt")
           if ex_dict:
               jieba.load_userdict("extra/myDict.dict")
   ```

4. ##### `myStop.txt`

   自定义停止词，目前仅收录语气词及标点符号。

5. ##### `myWordsLib.txt`

   自定义词库，储存语料库所有语句的分词结果，用于生成tf-idf向量，体现tf-idf向量维度。

6. ##### `main.py`

   项目入口，输入一行字符串，打印出匹配结果，内容如下：

   ```python
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
   ```

7. ##### `makeIDF.py`

   IDF类，主要用于生成`myIDF.dict`

8. ##### `makeVec.py`

   Vec类，完成字符串转换为tf-idf向量及余弦相似度匹配功能

9. ##### `utility.py`

   工具类，提供一些转换工具函数

## 函数说明

1. ##### `make_vec(self,content:str)`

   `Vec`类方法，将传入的字符串转化为tf-idf向量并返回。

2. ##### `simi_vecs(self, v1, v2)`

   `Vec`类方法，比较传入的两个向量，返回它们的余弦相似度。

3. ##### `simi_strs(self, s1, s2)`

   `Vec`类方法，调用`make_vec`方法将传入的两个字符串转化为tf-idf向量，再调用`simi_vecs`方法比较并返回它们的余弦相似度。

4. ##### `simi_answermap(self, s1)`

   `Vec`类方法，调用`simi_strs`方法，将传入的字符串与`answerMap`中所有`section`的`question`进行余弦相似度匹配，返回一个向量，包括最高的余弦相似度、最相似的section标号和对应回答的内容。

5. ##### `simi_answermap_vec(self, s1)`

   `Vec`类方法，调用`simi_strs`方法，将传入的字符串调用`make_vec`方法转化为tf-idf向量，再与`answerMap`中所有`section`的`vector`进行余弦相似度匹配，返回一个向量，包括最高的余弦相似度、最相似的`section`标号和对应回答的内容，是主要的对外接口。

6. ##### `make_vec_file(self, file_name="extra/answerMap.cfg")`

   `Vec`类方法，从answerMap中读取每个`section`的`question`，调用`make_vec`方法转化为tf-idf向量，存入对应`section`中的`vector`中。

7. ##### `make_idf_file(self, file_name='extra/myIDF.txt')`

   `IDF`类方法，从answerMap中读取每个`section`的`question`，调用jieba库中的`cut`方法将其分词，并计算每个词的逆文件频率，将其写入myIDF中，同时将每个词写入myWordLib中。

## 待修正与补充

1. 语料库中语句过少，自定义IDF文件效果不明显；
2. 目前answerMap中每个section只有一个question语句，不甚合理；
3. 可考虑采用监督学习训练优化一下语料库；
4. myWordLib.txt文档内容在myIDF.txt文档中事实上已存在，存在冗余存储问题。
