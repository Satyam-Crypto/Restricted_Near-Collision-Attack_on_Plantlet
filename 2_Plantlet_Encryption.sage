def lfsr_update(L):
    l = (L[0] ^^ L[14] ^^ L[20] ^^ L[34] ^^ L[43] ^^ L[54])
    return l

def nfsr_update(N,l0,key,t):
    n = l0 ^^ (((t%80)>>4)&1) ^^ key[t%80] ^^ N[0] ^^ N[13] ^^ N[19] ^^ N[35] ^^ N[39] ^^ N[2]&N[25] ^^ N[3]&N[5] ^^ N[7]&N[8] ^^ N[14]&N[21] ^^ N[16]&N[18] ^^ N[22]&N[24] ^^ N[26]&N[32] ^^ N[33]&N[36]&N[37]&N[38] ^^ N[10]&N[11]&N[12] ^^ N[27]&N[30]&N[31]
    return n

def keystream(L,N):
    z = L[30] ^^ N[1] ^^ N[6] ^^ N[15] ^^  N[17] ^^ N[23] ^^ N[28] ^^ N[34] ^^ (N[4]&L[6] ^^ L[8]&L[10] ^^ L[32]&L[17] ^^ L[19]&L[23] ^^ N[4]&L[32]&N[38])
    return z

def Encryption():
    key = [randint(0,1) for i in range(80)]
    N = [randint(0,1) for i in range(40)]
    L = [randint(0,1) for i in range(61)]
    
    temp= (0x7fd).bits()
    temp.reverse()
    L[50:] = temp
    
    key_stream = 4
    for i in range(320):
        z = keystream(L,N)
        l_new = (z ^^ lfsr_update(L))
        l0 = L[0]
        for j in range(59):
            L[j] = L[j+1]
        L[59] = l_new

        n_new = (z ^^ nfsr_update(N,l0,key,i))
        
        for j in range(39):
            N[j] = N[j+1]
        N[39] = n_new
    
    for i in range(key_stream):
        z = keystream(L,N)
        
        if (i != key_stream-1):
            l_new = lfsr_update(L)
            l0 = L[0]
            for j in range(60):
                L[j] = L[j+1]
            L[60] = l_new

            n_new = nfsr_update(N,l0,key,i)
            for j in range(39):
                N[j] = N[j+1]
            N[39] = n_new

        #print(z,end = ",") 
        
sample = 1000
runtime = [0]*sample
for i in range(sample):
    tt = cputime()
    Encryption()
    runtime[i] = cputime(tt)
print(sum(runtime)/sample.n())    

