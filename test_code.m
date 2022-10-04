clear all
%%
% function y = Arb(data)
% coder.extrinsic("readmatrix")
% coder.extrinsic("intlinprog")
% coder.extrinsic("writematrix")
%Day : 1, ID : 2, Cap : 3, Init : 4, Target : 5, Min : 6, Max : 7, In : 8,
%Out : 9, Pmin : 10, Pmax : 11, Mode : 12, Massive option : 13

ev = readmatrix("ev.csv");
size_ev = 0;
size_ev = size(ev,1);
idx = 0;
test = zeros(size_ev,1);
in = ev(:,8);
writematrix("test.csv")
for i = 1:size_ev
    test(i,1) = find(in(i,1) > 15);
end
y = 0;
y = size(ev,1);