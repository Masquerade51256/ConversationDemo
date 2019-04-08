
class Utility:
    def file2List(file_name):
        r = []
        for ln in open(file_name):
            r.extend(ln.strip().split(' '))
        return r