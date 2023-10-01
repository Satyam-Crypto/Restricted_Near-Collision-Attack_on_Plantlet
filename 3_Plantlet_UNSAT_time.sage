def Encryption():                   # for generating keystream
    IV = [randint(0,1) for i in range(90)]
    key = [randint(0,1) for i in range(80)]

    nfsr = [0]*40
    lfsr = [0]*61

    nfsr[:] = IV[:40]
    lfsr[:50] = IV[40:]


    temp= (0x7fd).bits()
    temp.reverse()
    lfsr[50:] = temp
    #print("Initialisation Vector =  ",IV,"\n\nKey =  ",key)

    #print("\nnfsr =  ",nfsr,"\n\nlfsr =  ",lfsr)

    def lfsr_update(L):
        l = (L[0] + L[14] + L[20] + L[34] + L[43] + L[54])
        l = l%2
        return l

    def nfsr_update(N,l0,key,t):
        n = l0 + (((t%80)>>4)&1) + key[t%80] + N[0] + N[13] + N[19] + N[35] + N[39] + N[2]*N[25] + N[3]*N[5] + N[7]*N[8] + N[14]*N[21] + N[16]*N[18] + N[22]*N[24] + N[26]*N[32] + N[33]*N[36]*N[37]*N[38] + N[10]*N[11]*N[12] + N[27]*N[30]*N[31]
        n = n%2
        return n

    def keystream(L,N):
        z = L[30] + N[1] + N[6] + N[15] +  N[17] + N[23] + N[28] + N[34] + (N[4]*L[6] + L[8]*L[10] + L[32]*L[17] + L[19]*L[23] + N[4]*L[32]*N[38])
        z = z%2
        return z

    N = [0]*40
    L = [0]*61
    N[:] = nfsr[:]
    L[:] = lfsr[:]
    key_stream = 2^11
    Key_Stream = [0]*key_stream
   
    #print(L)
    #print(N)
    for i in range(320):
        z = keystream(L,N)
        l_new = (z + lfsr_update(L))%2
        l0 = L[0]
        for j in range(1,60):
            L[j-1] = L[j]
        L[59] = l_new

        n_new = (z+nfsr_update(N,l0,key,i))%2
        for j in range(1,40):
            N[j-1] = N[j]
        N[39] = n_new
        #print("lfsr ",L,"\n","nfsr ",N)
    for i in range(key_stream):

        Key_Stream[i] = keystream(L,N)

        l_new = lfsr_update(L)
        l0 = L[0]
        for j in range(1,60):
            L[j-1] = L[j]
        L[59] = l_new

        n_new = nfsr_update(N,l0,key,i)
        for j in range(1,40):
            N[j-1] = N[j]
        N[39] = n_new
    return Key_Stream

def Sat_new(EQ):  
    #Number of solutions to find
    import time
    tt = cputime()
    start_time = time.time()
    #Number of solutions to find
    number_of_solutions = 1

    #Threads used
    num_threads=8

    #Storing cnf in file
    filename='put'

    from sage.sat.boolean_polynomials import solve as solve_sat
    import subprocess
    from sage.sat.solvers.dimacs import DIMACS
    from sage.sat.converters.polybori import CNFEncoder
    E=EQ
    #print(E[0])
    #print("before write")
    fn = tmp_filename()
    solver = DIMACS(filename=fn)
    e = CNFEncoder(solver,B)
    for i in range(len(E)):
         e.clauses_dense(E[i])
    _ = solver.write()
    #print("after write")
    #print(open(fn).read())
    #print(e.phi)
    fw = open(filename,'w')    
    fw.write(open(fn).read())
    fw.close()

    cmd = 'cryptominisat5 '+str(filename)+' --verb 0 --maxsol '+str(number_of_solutions)+' -t '+str(num_threads)

    p = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)

    print("after cmd")

    Y=[]
    for line in p.stdout.readlines():
        Y.append(line)
       # print("lines",line)

    retval = p.wait()
    for i in range(len(Y)):
         Y[i] = Y[i].split()

    for i in range(len(Y)):
        if Y[i][0] == b's':
            continue
        for j in range(1,len(Y[i])):
            Y[i][j]=int(Y[i][j])

    print(Y)

    #print(len(Y))


    if((Y[0][1]==b'SATISFIABLE')):
        print('Satisfiable')

    end_time = time.time() - start_time
    return end_time,cputime(tt)


sum0=0
sum1 =0 
EXP = 1000
for loop in range(EXP):
    K = [randint(0,1) for i in range (80)]
    L = [0 for i in range (80)] + [randint(0,1) for i in range (61)] + [0 for i in range(80)]

    
    t1 = randint(0,800)
    t2 = randint(1,10)
    KS =Encryption() 
    Z = KS[t1:t1+160]
    ZZ = KS[t1+80*t2:t1+80*t2+160]
  
    LL = L[:]
    
    D = [[34],[43],[54],[34,45],[43,44],[43,45],[43,50],[43,56],[45,54],[46,54],[48,54],[49,54],[50,54],[53,54],[54,55],[54,56],[54,57],[54,58],[54,59],[54,60],[40,43,51],[41,43,52],[41,52,54],[42,43,53],[45,50,54],[45,54,56],[46,54,57],[47,48,54],[47,50,54],[48,54,59],[49,50,54],[50,51,54],[50,54,55],[50,54,56],[50,54,58],[50,54,59],[51,54,55],[53,54,57]]
    t3 = randint(0,37)
    for i in range ((len(D[t3]))):
        LL[80+D[t3][i]] = (LL[80+D[t3][i]] + 1)%2

    for i in range (80):
        L[80+61+i] = (L[80+0+i] + L[80+14+i] + L[80+20+i] + L[80+34+i] + L[80+43+i] + L[80+54+i])%2
        
    for i in range (80):
        L[79-i] =  (L[80+60-i] + L[79+14-i] + L[79+20-i] + L[79+34-i] + L[79+43-i] + L[79+54-i])%2
        
    
    for i in range (80):
        LL[80+61+i] = (LL[80+0+i] + LL[80+14+i] + LL[80+20+i] + LL[80+34+i] + LL[80+43+i] + LL[80+54+i])%2

    for i in range (80):
        LL[79-i] =  (LL[80+60-i] + LL[79+14-i] + LL[79+20-i] + LL[79+34-i] + LL[79+43-i] + LL[79+54-i])%2








    B.<k0, k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, k11, k12, k13, k14, k15, k16, k17, k18, k19, k20, k21, k22, k23, k24, k25, k26, k27, k28, k29, k30, k31, k32, k33, k34, k35, k36, k37, k38, k39, k40, k41, k42, k43, k44, k45, k46, k47, k48, k49, k50, k51, k52, k53, k54, k55, k56, k57, k58, k59, k60, k61, k62, k63, k64, k65, k66, k67, k68, k69, k70, k71, k72, k73, k74, k75, k76, k77, k78, k79, n0, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13,n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27,n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39 , n40, n41,n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55,n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69,n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83,n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94, n95, n96,n97,n98, n99, n100, n101, n102, n103, n104, n105, n106, n107, n108, n109,n110, n111, n112, n113, n114, n115, n116, n117, n118, n119,n120, n121,n122, n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,n134, n135, n136, n137, n138, n139,n140, n141, n142, n143, n144, n145,n146, n147, n148, n149, n150, n151, n152, n153, n154, n155, n156, n157,n158, n159, n160, n161, n162, n163, n164, n165, n166, n167, n168, n169,n170, n171, n172, n173, n174, n175, n176, n177, n178, n179, n180, n181,n182, n183, n184, n185, n186, n187, n188, n189, n190, n191, n192, n193,n194, n195, n196, n197, n198, n199,nn0, nn1, nn2,nn3, nn4, nn5, nn6, nn7, nn8, nn9, nn10, nn11,nn12, nn13, nn14, nn15, nn16, nn17, nn18, nn19, nn20, nn21, nn22, nn23,nn24, nn25, nn26, nn27, nn28, nn29, nn30, nn31, nn32, nn33, nn34, nn35,nn36, nn37, nn38, nn39, nn40, nn41, nn42, nn43, nn44, nn45, nn46, nn47,nn48, nn49, nn50, nn51, nn52, nn53, nn54, nn55, nn56, nn57, nn58, nn59,nn60, nn61, nn62, nn63, nn64, nn65, nn66, nn67, nn68, nn69, nn70, nn71,nn72, nn73, nn74, nn75, nn76, nn77, nn78, nn79,  nn120, nn121, nn122, nn123, nn124, nn125,nn126,nn127, nn128, nn129, nn130, nn131, nn132, nn133, nn134, nn135, nn136,nn137, nn138, nn139, nn140, nn141, nn142, nn143, nn144, nn145, nn146,nn147, nn148, nn149, nn150, nn151, nn152, nn153, nn154, nn155, nn156,nn157, nn158, nn159, nn160, nn161, nn162, nn163, nn164, nn165, nn166,nn167, nn168, nn169, nn170, nn171, nn172, nn173, nn174, nn175, nn176,nn177, nn178, nn179, nn180, nn181, nn182, nn183, nn184, nn185, nn186,nn187, nn188, nn189, nn190, nn191, nn192, nn193, nn194, nn195, nn196,nn197, nn198, nn199> = BooleanPolynomialRing()

    x = B.gens()
    x = list(x)
    #print x
    #print len(x)


    K = x[:80]
    #print K
    N = x[80:280]
    #print N
    
    NN = x[280:360]+x[160:200]+x[360:]
    #print NN
    
    
    
    N_equ_f = []
    NN_equ_f = []
    N_equ_b = [n1]*80
    NN_equ_b = [n1]*80
    for i in range (80):
        N_equ_f = N_equ_f + [(L[80+0+i] + K[i] + ((i>>4)&1) + N[80+0+i] + N[80+13+i] + N[80+19+i] + N[80+35+i] + N[80+39+i] + (N[80+2+i] * N[80+25+i]) + N[80+3+i]*N[80+5+i] + N[80+7+i]*N[80+8+i] + N[80+14+i]*N[80+21+i] + N[80+16+i]*N[80+18+i] + N[80+22+i]*N[80+24+i] + N[80+26+i]*N[80+32+i] + N[80+33+i]*N[80+36+i]*N[80+37+i]*N[80+38+i] + N[80+10+i]*N[80+11+i]*N[80+12+i] + N[80+27+i]*N[80+30+i]*N[80+31+i]+N[80+40+i])]

        NN_equ_f = NN_equ_f + [(LL[80+0+i] + K[i] + ((i>>4)&1) + NN[80+0+i] + NN[80+13+i] + NN[80+19+i] + NN[80+35+i] + NN[80+39+i] + (NN[80+2+i] * NN[80+25+i]) + NN[80+3+i]*NN[80+5+i] + NN[80+7+i]*NN[80+8+i] + NN[80+14+i]*NN[80+21+i] + NN[80+16+i]*NN[80+18+i] + NN[80+22+i]*NN[80+24+i] + NN[80+26+i]*NN[80+32+i] + NN[80+33+i]*NN[80+36+i]*NN[80+37+i]*NN[80+38+i] + NN[80+10+i]*NN[80+11+i]*NN[80+12+i] + NN[80+27+i]*NN[80+30+i]*NN[80+31+i]+NN[80+40+i])]

        N_equ_b[79-i] = (L[79-i] + K[79-i] + (((79-i)>>4)&1) + N[80+39-i] + N[79+13-i] + N[79+19-i] + N[79+35-i] + N[79+39-i] + (N[79+2-i] * N[79+25-i]) + N[79+3-i]*N[79+5-i] + N[79+7-i]*N[79+8-i] + N[79+14-i]*N[79+21-i] + N[79+16-i]*N[79+18-i] + N[79+22-i]*N[79+24-i] + N[79+26-i]*N[79+32-i] + N[79+33-i]*N[79+36-i]*N[79+37-i]*N[79+38-i] + N[79+10-i]*N[79+11-i]*N[79+12-i] + N[79+27-i]*N[79+30-i]*N[79+31-i]+N[79-i])

        NN_equ_b[79-i] = (LL[79-i] + K[79-i] + (((79-i)>>4)&1) + NN[80+39-i] + NN[79+13-i] + NN[79+19-i] + NN[79+35-i] + NN[79+39-i] + (NN[79+2-i] * NN[79+25-i]) + NN[79+3-i]*NN[79+5-i] + NN[79+7-i]*NN[79+8-i] + NN[79+14-i]*NN[79+21-i] + NN[79+16-i]*NN[79+18-i] + NN[79+22-i]*NN[79+24-i] + NN[79+26-i]*NN[79+32-i] + NN[79+33-i]*NN[79+36-i]*NN[79+37-i]*NN[79+38-i] + NN[79+10-i]*NN[79+11-i]*NN[79+12-i] + NN[79+27-i]*NN[79+30-i]*NN[79+31-i]+NN[79-i])


   
    Z_equ = []
    ZZ_equ = []
    for i in range (160):
        Z_equ = Z_equ + [(L[30+i] + N[1+i] + N[6+i] + N[15+i] +  N[17+i] + N[23+i] + N[28+i] + N[34+i] + (N[4+i]*L[6+i] + L[8+i]*L[10+i] + L[32+i]*L[17+i] + L[19+i]*L[23+i] + N[4+i]*L[32+i]*N[38+i])+Z[i])]
       
        ZZ_equ = ZZ_equ + [(LL[30+i] + NN[1+i] + NN[6+i] + NN[15+i] +  NN[17+i] + NN[23+i] + NN[28+i] + NN[34+i] + (NN[4+i]*LL[6+i] + LL[8+i]*LL[10+i] + LL[32+i]*LL[17+i] + LL[19+i]*LL[23+i] + NN[4+i]*LL[32+i]*NN[38+i])+ZZ[i])]
        
    EQ =  Z_equ + ZZ_equ + N_equ_f + NN_equ_f + N_equ_b + NN_equ_b

    
    a,b=Sat_new(EQ)
    print(loop,a)  # for printing individual time
    sum0 = sum0+a
    sum1 = sum1+b
    
avg_sum0 = sum0/EXP
print(avg_sum0)         #for printing  average time
