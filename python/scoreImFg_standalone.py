import os, sys, pickle, random
import test

from fg_interface import *

#python scoreImFg_standalone.py -i 4node.img -f 4node.fgs -l 4node.lb -u 4node.ub -t 4node.trials

def score_img(nodes, factors, imnodes):
    load_asn_from_nodes(nodes, imnodes)
    input_image = constructAssignments(nodes)
    score_of_input = logscore(factors, input_image)
    return score_of_input 

def make_init_fg(num_nodes):
    def starting_gauss(all_pos, mean, var):
        unnorm = sum(map(lambda pos: (vec.dist(pos, mean))**2, all_pos))*0.5/var
        normed = (unnorm)- log((2*pi*var)**(num_nodes/2.0))
        return normed

    def asn_to_pos(asn):
        return map(lambda (k, v): v.pos, asn.items())

    return lambda asn: starting_gauss(asn_to_pos(asn), (0, 0), 100)

def read_val_from_file(filename):
    return [line.rstrip() for line in open(filename).readlines()]


from optparse import OptionParser

def init_app():
    ##
    ## Parse input arguments
    ##
    parser = OptionParser()
    parser.add_option("-i", "--img", dest="imgfile", type = "string", help="IMG_FILE", metavar="IMG_FILE", default = "")
    parser.add_option("-f", "--fgs", dest="fgfiles", type = "string", help="FG_FILES", metavar="FG_FILES", default = "")
    parser.add_option("-l", "--lowerbetafiles", dest="lowerbetafiles", type = "string", help="LOWER_BETAS", metavar="LOWER_BETAS", default = "")
    parser.add_option("-u", "--upperbetafiles", dest="upperbetafiles", type = "string", help="UPPER_BETAS", metavar="UPPER_BETAS", default = "")
    parser.add_option("-t", "--trialsfile", dest="trialsfile", type = "string", help="TRIALSFILE", metavar="TRIALSFILE", default = "")
    return parser.parse_args()

def delimit(str_delim, strs):
    return reduce(lambda x, y: x + str_delim + y, strs)

if __name__ == "__main__":
    
    (options, args) = init_app()

    
    imgfile = options.imgfile
    fgfiles = options.fgfiles
    lowerbetafiles = options.lowerbetafiles
    upperbetafiles = options.upperbetafiles
    trialsfile = options.trialsfile

    #args = sys.argv
    imnodes, imfactors = mkImgFromFile(imgfile)
    proposed_topo_filenames = read_val_from_file(fgfiles)
    lowerbetas = map(int, read_val_from_file(lowerbetafiles))
    upperbetas = map(int, read_val_from_file(upperbetafiles))
    trials = map(int, read_val_from_file(trialsfile))


    #init_fg = make_init_fg(len(imnodes))
    init_fg = lambda asn: 1.0 #make_init_fg(len(imnodes))


    proposed_topos = map(lambda fn: (fn, mkFGFromFile(fn)), proposed_topo_filenames)
    score_img_in_topo = map(lambda (fn, (n, f)): (fn, score_img(n, f, imnodes)), proposed_topos)



    for lb in lowerbetas:
        for ub in upperbetas:
            fn_score_dict = {}
            for trial_num in trials:
                for i in range(trial_num):
                    z_of_topos = map(lambda (fn, (n, f)): (fn, scoreImg(n, f, init_fg, lower_beta = lb, upper_beta = ub, trans_iter = 100)), proposed_topos) 
                    norm_score_img_in_topo = map(lambda ((fn1, (sam1, sco1)), (fn2, sco2)): (fn1, sco2-sco1), zip(z_of_topos, score_img_in_topo))

                    #print "\nUnnormalized score:"
                    #for (fn, unnorm_score) in score_img_in_topo:
                    #    print fn, unnorm_score

                    #print "\nnormalization_constant:"
                    #for (fn, (s, z)) in z_of_topos:
                    #    print fn, z
                    #
                    #print "\nnormalized_score:"
                    for (fn, norm_score) in norm_score_img_in_topo:
                        print fn, norm_score
                        fn_score_dict[fn] = fn_score_dict.get(fn, []) + [norm_score] 

                    #sorted_norm_scores = sorted(norm_score_img_in_topo, key=lambda (fn, s): s, reverse=True)
                    #print "\nSorted normalized_score:"
                    #for (fn, norm_score) in sorted_norm_scores:
                    #    print fn, norm_score


                outfile = open("%s_lb_%d_ub_%d_tt_%d.score" % (imgfile, lb, ub, trial_num), 'w')
                scoring_rows = map(list, zip(*map(lambda (k, v): [k] + map(str, v), fn_score_dict.items())))
                #outfile.write('\n'.join(map(lambda row: "\t".join(row), scoring_rows)))
                outfile.write(delimit('\n', map(lambda r: delimit('\t', r), scoring_rows)))
                outfile.close()


