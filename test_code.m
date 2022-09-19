clear all
%% 데이터 불러오기
EV = readtable("input/evConfig.csv");
ToU = readtable("input/tou.csv");
batt_cost = readtable("input/batt_cost.csv");
Demand_ResultData = readtable("input/Demand_ResultData.csv");
peakprice = readtable("input/peakprice.csv");
PV_ResultData = readtable("input/PV_ResultData.csv");
test = readtable("input/evConfig.csv");

%% 데이터 전처리
test2 = [1:size(test,1)];
test2 = reshape(test2,900,1);
test2 = array2table(test2,'VariableNames',{'time'});
test = horzcat(test2,test);

%% 데이터 테이블화

%% 데이터 mat파일화
% ToU = [];
% ToU(:,1) = tou(:,5);
% ToU(:,2) = tou(:,6);
% ToU(1,1) = 1;
% for i = 2:length(ToU)
%     ToU(i,1) = ToU(i-1,1) + 1;
% end
% ToU = transpose(ToU);
% 
% ev = {};
% day = 30;
% cd 'ev Data'\
% ev_idx = [1:length(EV)/day];
% ev_idx = transpose(ev_idx);
% 
% for i = 1:day
%     for j = 1:length(EV)
%         if EV(j,1) == i-1
%             ev{i,1} = EV((i-1)*30+1:i*30,:);
%             data1 = horzcat(ev_idx,ev{i,1});
%             data1 = transpose(data1);
%         end
%     end
%     count = convertCharsToStrings(sprintf('evConfig_Day%d',i-1));
%     save(count,"data1");
% end
% SIM_test = data1(1:3,:);
% 
save("evConfig","test",'-v7.3')
% save("PV_ResultData","PV_ResultData");
% save("Demand_ResultData","Demand_ResultData");
% save("peakprice","peakprice");
% save("ToU","ToU");
% save("SIM_test","SIM_test")

%%