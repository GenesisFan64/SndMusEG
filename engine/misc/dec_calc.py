out_art    = open("art.bin","wb")

b = 1
c = 700
while c:
 print "dc.l $",256*b,",$",256*(b+1),",$",256*(b+2),",$",256*(b+3),",$",256*(b+4),",$",256*(b+5),",$",256*(b+6),",$",256*(b+7)
 b += 1
 c -= 1