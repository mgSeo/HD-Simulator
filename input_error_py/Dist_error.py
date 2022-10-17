def Dist_error(n,x,office): 
    import pandas as pd
    import numpy as np 
    if office == 1:
        plug_time = pd.read_csv("15.plug pmf_office/out_plug_time.csv")
    else:
        plug_time = pd.read_csv("16.plug pmf_household/out_plug_time.csv")
      
    mu = 0
    sigma = x/1.96
    error_rate = np.zeros([1,3])
    ev_err = np.zeros([1,3])
    loop = n
    while len(ev_err) <= n:
        data = mu + sigma * np.random.randn(loop,3)
        for i in range(loop):
            error_data = np.zeros([1,3])
            error_data[0,0] = round(plug_time['in'][i] * (100 + data[i,0])/100)
            error_data[0,1] = round(plug_time['out'][i] * (100 + data[i,1])/100)
            error_data[0,2] = plug_time['init_soc'][i] * (100 + data[i,2])/100
            
            if ev_err[0,0] == 0 and ev_err[0,1] == 0 and ev_err [0,2] == 0:
                ev_err = error_data
            else:
                ev_err = np.append(ev_err, error_data, axis = 0)         
                        
        #Abnormal Data
        find_err1 = np.argwhere(ev_err[:,1] - ev_err[:,0] < 0 ) # plug-time minus
        find_err2 = np.argwhere(ev_err[:,1] > 48) # plug-time over
        find_err3 = np.argwhere(ev_err[:,2] < 0) #SoC violence
        find_err4 = np.argwhere(ev_err[:,2] > 1) #SoC violence
        idx_error = np.vstack([find_err1, find_err2, find_err3, find_err4])
        ev_err = np.delete(ev_err,idx_error,0)
        
        if len(ev_err) >= n:
            break
    data_out_error = pd.DataFrame(np.zeros([n,3]),columns = ['in','out','init_soc'])
    for i in range(n):
        data_out_error['in'][i] = ev_err[i,0]
        data_out_error['out'][i] = ev_err[i,1]
        data_out_error['init_soc'][i] = ev_err[i,2]
    
    if len(ev_err) > n:
        for i in range(n+1,len(ev_err)):
            np.delete(ev_err,i,0)
    if office == 1:
        data_out_error.to_csv("15.plug pmf_office/out_plug_time_error.csv")
    else:
        data_out_error.to_csv("16.plug pmf_household/out_plug_time_error.csv")
