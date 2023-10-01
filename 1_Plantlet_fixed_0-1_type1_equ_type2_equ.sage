R = BooleanPolynomialRing(501,['n_%d'%(i) for i in range(80,0,-1)]+['n%d'%(i) for i in range(0,120)]+['l_%d'%(i) for i in range(80,0,-1)]+['l%d'%(i) for i in range(141)]+['k%d'%i for i in range(80)])
R.inject_variables()
x = R.gens()
x = list(x)

def keystream(L,N):
    z = L[30] + N[1] + N[6] + N[15] +  N[17] + N[23] + N[28] + N[34] + (N[4]*L[6] + L[8]*L[10] + L[32]*L[17] + L[19]*L[23] + N[4]*L[32]*N[38])
    return z
    
def lfsr_update_forward(L):
    l = (L[0] + L[14] + L[20] + L[34] + L[43] + L[54])
    return l
    
def lfsr_update_backward(L):
    lb = L[60] + L[13] + L[19] + L[33] + L[42] + L[53]
    return lb


def nfsr_update_forward(N,l0,key,t):
    n = l0 + (((t%80)>>4)&1) + key[t%80] + N[0] + N[13] + N[19] + N[35] + N[39] + N[2]*N[25] + N[3]*N[5] + N[7]*N[8] + N[14]*N[21] + N[16]*N[18] + N[22]*N[24] + N[26]*N[32] + N[33]*N[36]*N[37]*N[38] + N[10]*N[11]*N[12] + N[27]*N[30]*N[31]
    return n
    
def nfsr_update_backward(N,l0,key,t):
    nb = l0 + (((t%80)>>4)&1) + key[t%80] + N[39] + N[12] + N[18] + N[34] + N[38] + N[1]*N[24] + N[2]*N[4] + N[6]*N[7] + N[13]*N[20] + N[15]*N[17] + N[21]*N[23] + N[25]*N[31] + N[32]*N[35]*N[36]*N[37] + N[9]*N[10]*N[11] + N[26]*N[29]*N[30]
    return nb
    

#fixed 38 positions 
F = [[34],[43],[54],[34,45],[43,44],[43,45],[43,50],[43,56],[45,54],[46,54],[48,54],[49,54],[50,54],[53,54],[54,55],[54,56],[54,57],[54,58],[54,59],[54,60],[40,43,51],[41,43,52],[41,52,54],[42,43,53],[45,50,54],[45,54,56],[46,54,57],[47,48,54],[47,50,54],[48,54,59],[49,50,54],[50,51,54],[50,54,55],[50,54,56],[50,54,58],[50,54,59],[51,54,55],[53,54,57]]




for f in range (len(F)):
    nfsr= x[:200]
    lfsr = x[200:421]
    key = x[421:]


    nfsr_copy = nfsr[:]
    lfsr_copy = lfsr[:]

    fault = F[f]

    for i in range(len(fault)):
        lfsr_copy[80 + fault[i]] +=1
    count_forward = 0
    for i in range(80):          #original variable nfsr,lfsr, nfsr_copy , lfsr_copy , 
        L = lfsr[80+i:80+i+61]          #temporary variable L,L_copy N, N_copy
        l = lfsr_update_forward(L)

        L_copy = lfsr_copy[80+i:80+i+61]
        l_c = lfsr_update_forward(L_copy)

        lfsr_copy[80+61+i] = lfsr[80+61+i] + l_c + l

        N = nfsr[80+i:80+i+40]
        n = nfsr_update_forward(N,L[0],key,i)

        N_copy = nfsr_copy[80+i:80+i+40]
        n_c = nfsr_update_forward(N_copy,L_copy[0],key,i)

        nfsr_copy[80+40+i] = nfsr[80+40+i] + n_c + n                 #will check at which position fault is propagated

        if (n + n_c) != 0 and (n + n_c) != 1:
            count_forward+=1
        if count_forward >= 6:
            key_str_f = i                     #will check how far it can go in forward direction
            break

    count_back = 0
    for i in range(80):
        L = lfsr[80-i:80-i+61]
        lb = lfsr_update_backward(L)

        L_copy = lfsr_copy[80-i:80-i+61]
        lbc = lfsr_update_backward(L_copy)

        lfsr_copy[79-i] = lfsr[79-i] + lb + lbc

        N = nfsr[80-i:80-i+40]
        nb = nfsr_update_backward(N,lb,key,79-i)

        N_copy = nfsr_copy[80-i:80-i+40]
        nbc = nfsr_update_backward(N_copy,lbc,key,79-i)

        nfsr_copy[79-i] = nfsr[79-i] + nb + nbc            #will check at which position fault is propagated

        if (nb + nbc) != 0 and (nb + nbc) != 1:
            count_back+=1
        if count_back >= 6:                  #will check how far it can go in backward direction
            key_str_b = i
            break

    count1 = 0
    count2 = 0
    pos0 = 0 
    pos1 = 0
    pos2 = 0
    A = [0]*80
    B = [0]*80
    C = [0]*80
    for i in range(-key_str_b,key_str_f):
        L = lfsr[80+i:80+i+61]
        N = nfsr[80+i:80+i+40]
        z = keystream(L,N)

        L_copy = lfsr_copy[80+i:80+i+61]
        N_copy = nfsr_copy[80+i:80+i+40]
        z_copy = keystream(L_copy,N_copy)

        print(i,"\t",z+z_copy)      #print it to see type2 equation

        if z+z_copy == 0 or z+z_copy == 1:                         #count1 calculates the number of equation involving only 0 or 1
            count1+=1
            if z+z_copy == 0:
                A[pos0] = i
                pos0+=1
            else:
                B[pos1] = i
                pos1+=1
        else:
            key_str_var = (z+z_copy).variables()
            key_str_var = list(key_str_var)
            for k in range(len(key_str_var)):
                if key_str_var[k] in nfsr:
                    k = -1000
                    break
            if k != -1000:
                #print(i) 
                count2+=1  #count2 calculates the number of equation involving only lfsr variables
                C[pos2] = [i, z+z_copy]
                pos2+=1
    #if count1+count2>=49:
    print("Fault",fault)    # printing the LFSR difference positions
    print("Count\t\t(",count1,count2,count1+count2,")") #Print for total number of fixed 0/1 and number of total equation containing LFSR only
    print("Zeroes\t",A[:pos0],"\n Ones\t",B[:pos1])   # print for the positions of fixed 0/1
    for i in range(pos2):                             # print for see type1 equations    
        print('$Z_{t_1 + %d} \\oplus Z_{t_2 + %d} = '%(C[i][0],C[i][0]),C[i][1],"$")

