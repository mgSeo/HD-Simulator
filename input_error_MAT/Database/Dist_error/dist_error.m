%% 함수 만들기
function data_out_error = Dist_error(x,n);
add = readmatrix("out_plug_time.csv");

loop = n;
mu = 0;
sigma1 = x/1.96;
error_rate = [];
data_out_error = [];
ev_err = [];
while (size(ev_err,1) < n)
    data = normrnd(mu,sigma1,[loop 3]);
    %% 데이터 만들기
    for i = 1:loop
        ev_err(i,1) = round(add(i,1) * (100+data(i,1))/100);
        ev_err(i,2) = round(add(i,2) * (100+data(i,2))/100);
        ev_err(i,3) = (add(i,3) * (100+data(i,3))/100);

        error_rate(i,1) = data(i,1);
        error_rate(i,2) = data(i,2);
        error_rate(i,3) = data(i,3);
    end
    %% 비정상 데이터 수정
    idx_time = find(ev_err(:,1) >= ev_err(:,2) | ev_err(:,2) > 48 | ev_err(:,3) > 1 | ev_err(:,3) < 0);
    ev_err(idx_time,:) = [];
    loop = loop-size(idx_time,1);
    data_out_error = vertcat(data_out_error,ev_err);
    if size(data_out_error,1) >= n
        break    
    end
end
if length(data_out_error) > n
    data_out_error(n+1:size(data_out_error,1),:) = [];
end
end