clear all
%% input 데이터 가져오기
%coder.extrinsic("readmatrix")
ev = readmatrix("input/evConfig.csv");
tou = readmatrix("input/tou.csv");
peakprice = readmatrix("input/peakprice.csv");
PV = readmatrix("input/PV_ResultData.csv");
Demand = readmatrix("input/Demand_ResultData.csv");
size_ev = 0;
size_ev = size(ev,1);
column_ev = 0;
column_ev = size(ev,2);
ev_day = zeros(1);
for i = 1:size(ev)
    ev(i,4) = ev(i,4) * ev(i,3);
    ev(i,5) = ev(i,5) * ev(i,3);
    ev(i,6) = ev(i,6) * ev(i,3);
    ev(i,7) = ev(i,7) * ev(i,3);

end

hour = 48;
%% 데이터 전처리
for i = 1:size_ev
    temp = zeros(1);
    temp = ev(i,1);
    idx = temp == 0;
    if idx == 1
        ev_day = zeros(i,column_ev);
        ev_day(1:i,1:column_ev) = ev(1:i,1:column_ev);
    end
end
size_ev = 0;
size_ev = size(ev_day,1);
in = zeros(size_ev,1);
out = zeros(size_ev,1);
dur = zeros(size_ev,1);
for i = 1:size_ev
    in(i,1) = ev_day(i,8);
    out(i,1) = ev_day(i,9);
    ev_day(i,5) = ev_day(i,5); %* ev_day(i,3);
    ev_day(i,4) = ev_day(i,4); %* ev_day(i,3);
    dur(i,1) = out(i,1) - in(i,1) + 1;
end

%% intlinprog 시작
tot_dur = sum(dur); 
obj_N = tot_dur + 1; %목적함수 개수 : duration + Peak
obj = ones(obj_N,1); %목적함수
Const_N = 3; %제약조건 개수

for i = 1:obj_N
    obj(i,1) = obj(i,1);
end

% boundary
lb = zeros(tot_dur,1);
ub = zeros(tot_dur,1);
dur_num = 1;
for i = 1:size_ev
    lb(dur_num : dur_num + dur(i,1),1) = ev(i,10);
    ub(dur_num : dur_num + dur(i,1),1) = ev(i,11);
    dur_num = dur_num + dur(i,1);
end

% 목적함수 tou & peakprice 적용
dur_num = 1;
for i = 1:size_ev
    obj(dur_num:dur_num + dur(i,1) - 1,1) = obj(dur_num:dur_num + dur(i,1) - 1,1) .* tou(in(i,1):out(i,1),6);
    dur_num = dur_num + dur(i,1);
end
obj(dur_num,1) = obj(dur_num,1) * peakprice(1,3);

f = obj;

% constraint 1 : SoC boundary & target SoC
A_soc = zeros(tot_dur,obj_N);
A_target = zeros(size_ev,obj_N);
b_soc_lb = zeros(tot_dur,1);
b_soc_ub = zeros(tot_dur,1);
b_target_lb = zeros(size_ev,1);
b_target_ub = zeros(size_ev,1);

dur_num = 1;

for i = 1:size_ev    
    ev_soc = tril(ones(dur(i,1)));

    A_soc(dur_num:dur_num + dur(i,1) - 1,dur_num:dur_num + dur(i,1) - 1) = ev_soc;    
    b_soc_lb(dur_num:dur_num + dur(i,1) - 1,1) = -ev(i,4) + ev(i,6);
    b_soc_ub(dur_num:dur_num + dur(i,1) - 1,1) = -ev(i,4) + ev(i,7);
    
%     target SoC
    A_target(i,dur_num:dur_num+dur(i,1) - 1) = ev_soc(dur(i,1),:);    
    
    b_target_lb(i,1) = -ev(i,4) + ev(i,5) - 5;
    b_target_ub(i,1) = -ev(i,4) + ev(i,5) + 5;

    dur_num = dur_num + dur(i,1);
end
% % constraint  : peak price 찾기
%     
%     % X_t 양 확인하기
% for i = 1:size_ev
%     for j = 1:hour
%         if ev_day(i,8) <= j && j <= ev_day(i,9)
%         ev_check(i,j) = 1;
%         var_hours(j,1) = var_hours(j,1) + 1;
%         end
%     end    
% end
% dur_num = 1;
% ev_hour = 0;
% for i = 1:size_ev
%     for j = 1:hour
%         if ev(i,8) <= j && j <= ev(i,9)
%             ev_hour = j-ev(i,8);
%              A(1,dur_num + ev_hour) = 1;
%         end
%     end
%     ev_hour
% end

%최적화
intcon = 1:obj_N;
A = [-A_soc; A_soc; -A_target; A_target];
b = [-b_soc_lb; b_soc_ub; -b_target_lb; b_target_ub];
[x,fval,exitflag,output] = intlinprog(f,intcon,A,b,[],[],lb,ub);

%% 결과 정리
dur_num = 1;
ev_result = zeros(size_ev,hour);
for i = 1:size_ev
    ev_result(i,ev(i,8):ev(i,9)) = x(dur_num:dur_num+dur(i,1)-1,1);
    dur_num = dur_num + dur(i,1);
end

figure(3)
x = 1:hour;
y1 = ev_result(1,:);
y2 = tou(:,6);
t = stairs(x,y1,'linewidth',2);
xlabel('Hours','fontsize',12);
ylabel('Power [kW/h]','fontsize',12);
% ylim([-200 200]);
hold on
yyaxis right;
ylabel('ToU [Won/kWh]','fontsize',12)
ylim([0 200]);
bar(x,y2,'linewidth',0.01,'facealpha',0)
hold off