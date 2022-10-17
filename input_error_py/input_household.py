def input_household(n,x,error,office):
    import pandas as pd
    import numpy as np
    import Dist_error
    
    soc_pmf = pd.read_csv("16.plug pmf_household/pmf_ini_SOC.csv",header = None)
    data_out_house = pd.DataFrame(np.zeros([n,3]),columns = ['in','out','init_soc'])
           
    #departure time
    mu = 17.01
    sigma = 3.2
    r = np.random.randn(n)
    R = np.zeros(n)
    for i in range(n):
        R[i] = round(mu + sigma * r[i])
        if R[i] <= 0:
            R[i] = R[i] + 24
        data_out_house['out'][i] = R[i]
        
    #arrival time
    mu = 9.9
    sigma = 2.2
    r = np.random.randn(n)
    R = np.zeros(n)
    for i in range(n):
        R[i] = round(mu + sigma * r[i])
        if R[i] >= 24:
            R[i] = R[i] - 24
        data_out_house['in'][i] = R[i]
    
    #init soc sampling
    c = pd.DataFrame(np.zeros([1,len(soc_pmf)]),columns = None)
    for i in range(n):
        b3 = 0
        v = soc_pmf[0]
        p = soc_pmf[data_out_house['in'][i]]
        cumsum = 0
        for j in range(len(p)):
            cumsum += p[j]
            c[j] = round(cumsum,4)
        c_array = c.values.tolist()
        c_array = c_array[0]
        rand_num = round(float(np.random.rand(1)),4)
        b3 = np.digitize(rand_num,c_array)
        if b3 >= 10:
            b3 = 9
        data_out_house['init_soc'][i] = v[b3]
    
    data_out_house.to_csv("16.plug pmf_household/out_plug_time.csv")
    
    if error == 1:
        data_out_error = Dist_error.Dist_error(n,x,office)
        
