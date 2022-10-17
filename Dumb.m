%Day : 1, ID : 2, Cap : 3, Init : 4, Target : 5, Min : 6, Max : 7, In : 8,
%Out : 9, Pmin : 10, Pmax : 11, Mode : 12, Massive option : 13

ev = readmatrix("input/evConfig.csv");
tou = readmatrix("input/tou.csv");
size_ev = 0;
size_ev = size(ev,1);
column_ev = 0;
column_ev = size(ev,2);
ev_day0 = zeros(1);

ev(:,4) = ev(:,4) .* ev(:,3);
ev(:,5) = ev(:,5) .* ev(:,3);
ev(:,6) = ev(:,6) .* ev(:,3);
ev(:,7) = ev(:,7) .* ev(:,3);

rate = 5;
hour = 48;

%% 데이터 전처리
for i = 1:size_ev
    temp = zeros(1);
    temp = ev(i,1);
    idx = temp == 0;
    if idx == 1
        ev_day0 = zeros(i,column_ev);
        ev_day0(1:i,1:column_ev) = ev(1:i,1:column_ev);
    end
end

ev = ev_day0;
size_ev = 0;
size_ev = size(ev,1);
in = zeros(size_ev,1);
out = zeros(size_ev,1);
dur = zeros(size_ev,1);
Chg_time = zeros(size_ev,1);
power = zeros(size_ev,hour);

for i = 1:size_ev
    in(i,1) = ev(i,8);
    out(i,1) = ev(i,9);
    Chg_time(i,1) = ceil((ev(i,5) - ev(i,4))/rate);
    dur(i,1) = out(i,1) - in(i,1);
end
%%충전 스케줄링 시작
for i = 1:size_ev
    if Chg_time(i,1) >= dur(i,1)
        Chg_time(i,1) = dur(i,1);
    end
end

for i = 1:size_ev
    if Chg_time(i,1) >= 0
        if Chg_time(i,1) > 1
            power(i,(in(i,1):in(i,1)+Chg_time(i,1))) = rate;
        elseif Chg_time(i,1) <= 1
            power(i,in(i,1)) = Chg_time(i,1) * rate;
        end
    end
end

figure(3)
x = 1:hour;
y1 = power(7,:);
y2 = tou(:,6);
t = stairs(x,y1,'linewidth',2);
xlabel('Hours','fontsize',12);
ylabel('Power [kW/h]','fontsize',12);
ylim([0 20]);
hold on
yyaxis right;
ylabel('ToU [Won/kWh]','fontsize',12)
ylim([0 200]);
bar(x,y2,'linewidth',0.01,'facealpha',0)
hold off
