def input_office(n,x,error,office):
    import pandas as pd
    import numpy as np
    import random as rd   
    import Dist_error
    in_pmf = pd.read_csv("15.plug pmf_office/pmf_plug_in.csv", header = None)
    dur_pmf = pd.read_csv("15.plug pmf_office/pmf_charging_dura.csv",header = None)
    soc_pmf = pd.read_csv("15.plug pmf_office/pmf_ini_SOC.csv",header = None)
    
    v = in_pmf[0]
    p = in_pmf[1]
    c = pd.DataFrame(np.zeros([1,len(p)]),columns = None)
    r = pd.DataFrame(np.zeros([1,len(p)]),columns = None)
    data_out_office = pd.DataFrame(np.zeros([n,4]),columns = ['in','dur','out','init_soc'])
      
    #in-time sampling
    cumsum = 0
    for i in range(len(p)):
        cumsum += p[i]
        c[i] = round(cumsum,4)
    # c[i] = c[i]/c[len(c)]
    c_array = c.values.tolist()
    c_array = c_array[0]
    rand_num = np.random.rand(n)
    for i in range(len(rand_num)):
        rand_num[i] = round(rand_num[i],4)
    b1 = np.digitize(rand_num,c_array)
    for i in range(len(b1)):
        if b1[i] >= 24:
            b1[i] = 23
        r[i] = v[b1[i]]
        data_out_office['in'][i] = r[i]
    
    #dur-time sampling
    c = pd.DataFrame(np.zeros([1,len(p)]),columns = None)
    for i in range(n):
        b2 = 0
        v = dur_pmf[0]
        p = dur_pmf[data_out_office['in'][i]]
        cumsum = 0
        for j in range(len(p)):
            cumsum += p[j]
            c[j] = round(cumsum,4)
        c_array = c.values.tolist()
        c_array = c_array[0]
        rand_num = round(float(np.random.rand(1)),4)
        b2 = np.digitize(rand_num,c_array)
        data_out_office['dur'][i] = b2
     
    #initial soc sampling
    c = pd.DataFrame(np.zeros([1,len(soc_pmf)]),columns = None)
    for i in range(n):
        b3 = 0
        v = soc_pmf[0]
        p = soc_pmf[data_out_office['in'][i]]
        cumsum = 0
        for j in range(len(p)):
            cumsum += p[j]
            c[j] = round(cumsum,4)
        c_array = c.values.tolist()
        c_array = c_array[0]
        rand_num = round(float(np.random.rand(1)),4)
        b3 = np.digitize(rand_num,c_array)
        data_out_office['init_soc'][i] = v[b3]
            find_err1 = np.argwhere(ev_err[:,1] - ev_err[:,0] < 0 ) # plug-time minus
        find_err2 = np.argwhere(ev_err[:,1] > 48) # plug-time over
        find_err3 = np.argwhere(ev_err[:,2] < 0) #SoC violence
        find_err4 = np.argwhere(ev_err[:,2] > 1) #SoC violence
        idx_error = np.vstack([find_err1, find_err2, find_err3, find_err4])
        ev_err = np.delete(ev_err,idx_error,0)
    #csv out
    data_out_office['out'] = data_out_office['in'] + data_out_office['dur']
    data_out_office.drop(['dur'],axis = 'columns')
    data_out_office.to_csv("15.plug pmf_office/out_plug_time.csv")
    
    if error == 1:
        data_out_error = Dist_error.Dist_error(n,x,office)
        
