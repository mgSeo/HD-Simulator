clear
%% input 데이터 만들기 : EV 30개, Day 0~29
add = readtable("evConfig.csv");
add.init = add.init .* add.cap;
add = removevars(add,{'Day','ID','cap','Massive','mode','max','min','Pmin','Pmax','target'});

row_ev = size(add,1); % EV개수
col_ev = size(add,2); % 열 개수
x = 20;

%% 함수 만들기
function dist_error(x,row_ev,col_ev);
    mu = 0;
    sigma1 = x/1.96;
    data = normrnd(mu,sigma1,[row_ev col_ev]);
    error_rate = [];
    ev_err = table('size',[row_ev col_ev],'VariableTypes',["double","double","double"],'VariableNames',["init","in","out"]);
    for i = 1:row_ev
        ev_err.init(i) = (add.init(i) * (100+data(i,1))/100);
        ev_err.in(i) = round(add.in(i) * (100+data(i,2))/100);
        ev_err.out(i) = round(add.out(i) * (100+data(i,3))/100);        
        
        if ev_err.out(i) >= 48
            ev_err.out(i) = 48;
        end
        if ev_err.in(i) >= ev_err.out(i) && ev_err.out(i) <= 24
            ev_err.out(i) = ev_err.out(i) + 24;
        end
        error_rate(i,1) = data(i,1);
        error_rate(i,2) = data(i,2);
        error_rate(i,3) = data(i,3);

    end

    for i = 1:row_ev
        for j = 1:col_ev
            if error_rate(i,j) >= 100 || error_rate(i,j) <= -100
                error_rate(i,j) = 0;
                ev_err(i,j) = add(i,j);
            end
        end
    end
end