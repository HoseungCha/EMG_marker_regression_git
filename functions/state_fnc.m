function xk = state_fnc(xk,uk)
    persistent firstRun;
    persistent net;
    if isempty(firstRun)
        firstRun = 1;
        load('network.mat');
    end
    input = {uk;xk};
    out = net(input);
    xk = out{1};
end