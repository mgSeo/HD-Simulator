import pandas as pd
import numpy as np   
import input_office
import input_household
import Dist_error

n = 10000 # ev 개수
x = 20 #error rate
office = 0 # 1 : office, 0 : house
error = 0 # 1 : error 0 : no

if office == 1:
    result_office = input_office.input_office(n,x,error,office)    
else:
    result_household = input_household.input_household(n,x,error,office)

        