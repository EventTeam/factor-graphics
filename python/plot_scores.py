import sys
from pyfactorg import *
import matplotlib.pyplot as plt
import numpy as np

def mean_var_one_file(_filename):
    lines = [line.rstrip().split('\t') for line in open(_filename)]
    data = sorted(zip(*lines), key = lambda v: v[0])
    xaxis_labels = map(lambda col: col[0], data)
    column_data = map(lambda col: map(float, col[1:]), data)
    mean_var_data = map(lambda c: mean_var(c), column_data)
    mean_var_data = map(lambda (m, v): (m, sqrt(v)), mean_var_data)
    return _filename, xaxis_labels, mean_var_data

def plot_multiple(mean_var_datas):
    out_file = "output.pdf"
    width = 1./(2*len(mean_var_datas))

    def parse(filename):
        (imgname, lb, lb_v, ub, ub_v, tt, tt_v) = filename.split('/')[1].rstrip('.score').split("_")
        return "%s:%s,%s:%s,%s:%s." %(lb, lb_v, ub, ub_v, tt, tt_v)
        

    def plot_single((i, (_filename, xlabels, mean_var_data))):
        plt.errorbar(ind+i*width, fsts(mean_var_data), yerr = snds(mean_var_data), fmt = 'o', label = parse(_filename))


    plt.subplot2grid((3, 3), (1, 0), colspan=2, rowspan=2)
    xaxis_labels = mean_var_datas[0][1]
    xaxis_labels = map(lambda l: l.rstrip(".fg"),xaxis_labels)
    ind = np.arange(len(xaxis_labels))
    i_mean_var_datas = zip(range(len(mean_var_datas)), mean_var_datas)
    map(plot_single, i_mean_var_datas)
    
    plt.ylabel('Scores')
    plt.xlabel('Factor graphs')
    plt.title("AIS Scores")
    plt.xticks(ind, xaxis_labels)
    plt.xlim(-1, len(xaxis_labels))

    plt.legend(bbox_to_anchor=(0.02, 1.5), loc=2, borderaxespad=0.)
    #plt.show()
    plt.savefig(out_file)


filedir = "stability-test"

lbs = [100, 200, 500, 1000]
ubs = [100, 200, 500, 1000]
tts = [10, 20, 50, 100]

filenames = ["stability-test/%dnode.img_lb_%d_ub_%d_tt_%d.score" %(4, lb, ub, tt) for lb in lbs for ub in ubs for tt in tts if tt == 50 and lb == 1000]

mean_var_datas = map(mean_var_one_file, filenames)
plot_multiple(mean_var_datas)
