function [P_ev,SOC_ev] = Func_dispatcher(ev,cluster,P_fleet,horizon)
%% Pre-define parameters:
P_ev = table();
SOC_ev = table();
temp.k = 0;
%% Define varable:
for k = 1:size(cluster,1)
    k_idx = find(ev.cluster==k);
    sum_dur = sum(ev.duration(k_idx));
    N = sum_dur + cluster.n_ev(k);
    ub =  [cluster.pcs(k) * ones(sum_dur,1); inf * ones(cluster.n_ev(k),1)];
    lb = [-cluster.pcs(k) * ones(sum_dur,1); zeros(cluster.n_ev(k),1)];

    %% Constraints:
    % Power 같게 (Cluster <=> ev)
    Aeq_balance = zeros(cluster.duration(k), N);
    Beq_balance = P_fleet(1:cluster.duration(k), k);
    dur = 0;
    for n = 1:cluster.n_ev(k)
        vdx = k_idx(n);
        in = ev.serviceFrom(vdx) - cluster.From(k) + 1;
        out = ev.serviceTo(vdx) - cluster.From(k);
        Aeq_balance(in:out, dur+1:dur+ev.duration(vdx)) = eye(ev.duration(vdx));
        dur = dur + ev.duration(vdx);
    end

    % SoE meet
    A_soe = zeros(N,N); B_soelb = zeros(N,1); B_soeub = zeros(N,1);
    dur = 0;
    for n = 1:cluster.n_ev(k)
        vdx = k_idx(n);
        A_soe(dur + 1 : dur + ev.duration(vdx), dur + 1 : dur + ev.duration(vdx)) = tril(ones(ev.duration(vdx))) * ev.eff(vdx);
        B_soelb(dur + 1 : dur + ev.duration(vdx)) = ev.initialSOC(vdx) * ev.capacity(vdx)/100;
        B_soeub(dur + 1 : dur + ev.duration(vdx)) = (100 - ev.initialSOC(vdx))*ev.capacity(vdx)/100;
        dur = dur + ev.duration(vdx);
    end

    % SoE target
    A_gap_p = zeros(cluster.n_ev(k),N);
    B_gap_p = zeros(cluster.n_ev(k),1);
    dur = 0;
    for n = 1:cluster.n_ev(k)
        vdx = k_idx(n);
        A_gap_p(n, dur + 1 : dur + ev.duration(vdx)) = ev.eff(vdx);
        B_gap_p(n) = (ev.goalSOC(vdx) - ev.initialSOC(vdx))*ev.capacity(vdx)/100;
        dur = dur + ev.duration(vdx);
    end
    A_gap_n = -A_gap_p;
    A_gap_p(:,sum_dur+1:N) = -eye(cluster.n_ev(k));
    A_gap_n(:,sum_dur+1:N) = -eye(cluster.n_ev(k));
    B_gap_n = -B_gap_p;

    f = zeros(N,1);
    f(sum_dur+1:N) = 99999;
    A = [-A_soe ;   A_soe; A_gap_p; A_gap_n];
    B = [B_soelb; B_soeub; B_gap_p; B_gap_n];
    Aeq = [Aeq_balance];
    Beq = [Beq_balance];

    % solve
    options = optimoptions('linprog','Algorithm','interior-point','Display','off');
    [x,~,exitflag,~] = linprog(f,A,B,Aeq,Beq,lb,ub,options);

    %% result
    p_ev = zeros(horizon,cluster.n_ev(k));
    soc = zeros(horizon,cluster.n_ev(k));
    for n = 1:cluster.n_ev(k)
        vdx = k_idx(n);
        in = ev.serviceFrom(vdx) - min(ev.serviceFrom) + 1;
        out = ev.serviceTo(vdx) - min(ev.serviceFrom);
        p_ev(in:out,n) = x(1:ev.duration(vdx));
        soc(in,vdx) = ev.initialSOC(vdx);
        soc(in+1:out+1,n) = cumsum(x(1:ev.duration(vdx)))*ev.eff(vdx)/ev.capacity(vdx)*100 + ev.initialSOC(vdx);
        x(1:ev.duration(vdx)) = [];
    end
    for i = 1:cluster.n_ev(k)
        vdx = k_idx(i);
        id = ['id_',num2str(ev.id(vdx))];
        P_ev(:,temp.k+i) = array2table(p_ev(:,i));
        P_ev.Properties.VariableNames{temp.k+i} = id;
        SOC_ev(:,temp.k+i) = array2table(soc(:,i));
        SOC_ev.Properties.VariableNames{temp.k+i} = id;
    end
    temp.k = temp.k + cluster.n_ev(k);
end
id = unique(ev.id);
for n = 1:size(ev,1)-1 % table column sorting
    id_left = ['id_',num2str(id(n))];
    id_right = ['id_',num2str(id(n+1))];
    P_ev = movevars(P_ev, id_right, 'after', id_left);
    SOC_ev = movevars(SOC_ev, id_right, 'after', id_left);
end
end