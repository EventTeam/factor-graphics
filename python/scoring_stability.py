import sys
from pyfactorg import *

# id, posx, posy <children>

filename_pre = "5node"

class Joint(object):
    def __init__(self, id, posx, posy, children, parent = None):
        self.id = id
        self.pos = (posx, posy)
        self.posx = posx
        self.posy = posy
        self.children = children
        self.parent = parent
        self.dist = -1
        self.distvar = 0.5
    def __repr__(self):
        if len(self.children) > 0:
            return "N label %s pos %.1f %.1f Distance %.1f %.1f children %s" %(self.id, self.posx, self.posy, self.dist, self.distvar, reduce(lambda x, y: x+" "+y, self.children))
        else:
            return "N label %s pos %.1f %.1f Distance %.1f %.1f" %(self.id, self.posx, self.posy, self.dist, self.distvar)

joint_table = {}
def connect_joints(joints):
    for j in joints:
        joint_table[j.id] = j
    for j in joints:
        for c in j.children:
            joint_table[c].parent = j


lines = [line.rstrip().split(" ") for line in open("%s.pattern" % filename_pre).readlines()]
lines = filter(lambda l: len(l) > 2, lines)
joints = map(lambda l: Joint(l[0], float(l[1]), float(l[2]), l[3:]),lines)
connect_joints(joints)

for j in joints:
    j.dist = vec.dist(j.pos, j.parent.pos) if j.parent is not None else 0

for j in joints:
    print j, j.parent.id if j.parent is not None else ""

num_test_fg = 3

for n in range(num_test_fg):
    outfile = open("%s%d.fg" %(filename_pre, n+1), 'w')
    for j in joints:
        outfile.write(j.__repr__())
        outfile.write("\n")
    outfile.close()

outfile = open("%s.img" %(filename_pre), 'w')
for j in joints:
    outfile.write(j.__repr__())
    outfile.write("\n")
outfile.close()
