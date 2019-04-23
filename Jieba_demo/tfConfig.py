from configparser import ConfigParser
class TfConfig:
    ex_stop_words = True
    ex_idf = False
    ex_dict = True
    answermap_path = "extra/answerMap.ini"

    TRAIN = True
    TEST = False
    mode = TRAIN
    make_idf = True
    rewrite_vec = mode

    def __init__(self):
        self.cfgParser = ConfigParser()
        self.cfgParser.read('extra/config.ini', encoding="UTF8")
        self.threshold = float(self.cfgParser.get('parameters', 'threshold'))

    def set_threshold(self, v):
        self.cfgParser.set('parameters', 'threshold', str(v))
        with open('extra/config.ini', 'w+') as fw:
            self.cfgParser.write(fw)
        self.threshold = v