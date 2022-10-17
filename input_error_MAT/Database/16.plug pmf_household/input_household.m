function data_out_house = input_household(n,error,x)
data_out_house = zeros(n,3);
soc_pmf = readmatrix('pmf_ini_SOC.csv');

%% departure time pdf
mu = 9.97;
sigma = 2.2;

r = normrnd(mu,sigma,[n,1]);
R = round(r); % in-time

idx = find(R<1);
if isempty(idx) == 0
    R(idx) = R(idx) + 24;
end
data_out_house(:,2) = R;

%% arrival time pdf
mu = 17.01;
sigma = 3.2;

r = normrnd(mu,sigma,[n,1]);
R = round(r); % in-time

idx = find(R>24);
if isempty(idx) == 0
    R(idx) = R(idx) - 24;
end
data_out_house(:,1) = R;

%% sampling: initial soc
for t = 1:n
    v = soc_pmf(:,1);
    p = soc_pmf(:,data_out_house(t,1)+1);
    c = cumsum([0,p(:).']);
    c = c/c(end); % make sur the cumulative is 1
    [~,i] = histc(rand(1),c);
    data_out_house(t,3) = v(i);
end

%% data out
writematrix(data_out_house,'16.plug pmf_household/out_plug_time.csv')
%% error input
if error == 1
    data_out_error = dist_error(x,n);
    writematrix(data_out_error,'16.plug pmf_household/out_plug_time_error.csv')
end

end