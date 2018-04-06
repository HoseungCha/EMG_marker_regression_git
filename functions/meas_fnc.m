function yk = meas_fnc(xk)
    persistent firstRun netc2;
    if isempty(firstRun)
        firstRun = 1;
        load('network.mat');
    end
    input = {xk};
    out = netc2(input);
    yk = out{1};
end