clear all
%% 데이터 mat 파일화
test = importdata("input/evConfig.csv");
ToU = importdata("input/tou.csv");
batt_cost = importdata("input/batt_cost.csv");
Demand_ResultData = importdata("input/Demand_ResultData.csv");
peakprice = importdata("input/peakprice.csv");
PV_ResultData = importdata("input/PV_ResultData.csv");

batt_cost = batt_cost.data;
ToU = ToU.data;
EV = test.data;

Demand_ResultData = Demand_ResultData.data;
peakprice = peakprice.data;
PV_ResultData = PV_ResultData.data;


ev = {};
day = 30;
cd 'ev Data'\
ev_idx = [1:length(EV)/day];
ev_idx = transpose(ev_idx);

for i = 1:day
    for j = 1:length(EV)
        if EV(j,1) == i-1
            ev{i,1} = EV((i-1)*30+1:i*30,:);
            data1 = horzcat(ev_idx,ev{i,1});
            data1 = transpose(data1);
        end
    end
    count = convertCharsToStrings(sprintf('evConfig_Day%d',i-1));
    save(count,"data1");
end
SIM_test = data1(1:3,:);

save("evConfig","EV");
save("PV_ResultData","PV_ResultData");
save("Demand_ResultData","Demand_ResultData");
save("peakprice","peakprice");
save("ToU","ToU");
save("SIM_test","SIM_test")

%%