clear
close all;
clc;

input = [100,150,130; 80, 130, 100; 120, 190, 140]'
target = [5,-10,7; 6, -9, 8; 8, -12, 10]'

disp('input, zscore');
disp(zscore(input,0,1));
disp('target, zscore');
disp(zscore(target,0,1));

disp('input, min-max');
Max = max(input);
Min = min(input);
input_n = (input-Min)./(Max-Min);
disp(input_n);

disp('target, min-max(with_abs)');
Max = max(target);
Min = min(target);
target_n = (target-Min)./(Max-Min);
disp(target_n);

disp('target, min-max(with_abs)');
Max = max(abs(target));
Min = min(abs(target));
target_n_abs = (target-Min)./(Max-Min);
disp(target_n_abs);

input = [70, 130, 100]