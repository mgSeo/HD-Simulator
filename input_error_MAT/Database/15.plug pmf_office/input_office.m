function data_out_office = input_office(n,error,x)

in_pmf = readmatrix('pmf_plug_in.csv');
dur_pmf = readmatrix('pmf_charging_dura.csv');
soc_pmf = readmatrix('pmf_ini_SOC.csv');
data_out_office = zeros(n,4);

%% sampling: in-time
v = in_pmf(:,1);
p = in_pmf(:,2);
c = cumsum([0,p(:).']);
c = c/c(end); % make sur the cumulative is 1
[~,i] = histc(rand(1,n),c);
r = v(i); % map to v values

data_out_office(:,1) = i;

%% sampling: dur-time
for t = 1:n
    v = dur_pmf(:,1);
    p = dur_pmf(:,data_out_office(t,1)+1);
    c = cumsum([0,p(:).']);
    c = c/c(end); % make sur the cumulative is 1
    [~,i] = histc(rand(1),c);
    data_out_office(t,2) = i;
end

%% sampling: initial soc
for t = 1:n
    v = soc_pmf(:,1);
    p = soc_pmf(:,data_out_office(t,1)+1);
    c = cumsum([0,p(:).']);
    c = c/c(end); % make sur the cumulative is 1
    [~,i] = histc(rand(1),c);
    data_out_office(t,4) = v(i);
end

%% csv out
data_out_office(:,3) = data_out_office(:,1)+data_out_office(:,2); % out=in+dur
data_out_office(:,2) = [];
writematrix(data_out_office,'15.plug pmf_office/out_plug_time.csv')
if error == 1
    data_out_error = dist_error(x,n);
    writematrix(data_out_error,'15.plug pmf_office/out_plug_time_error.csv')
end
end