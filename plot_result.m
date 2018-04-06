load('result.mat'); %%16680

figure
subplot(4,1,1);
plot(disn.left_eyebrow_out(1:16680,1,1)); hold on;
plot(disn.right_eyebrow_out(1:16680,1,1)); hold on;

plot(disn.left_eyebrow_in(1:16680,1,1)); hold on;
plot(disn.right_eyebrow_in(1:16680,1,1)); hold on;
legend('left outside','right outside','left inside','right inside');
title('Eyebrow');
ylabel('distance');

subplot(4,1,2);
plot(disn.left_upeye(1:16680,1,1)); hold on;
plot(disn.right_upeye(1:16680,1,1)); hold on;

plot(disn.left_downeye(1:16680,1,1)); hold on;
plot(disn.right_downeye(1:16680,1,1)); hold on;
legend('left upp','right up','left down', 'right down');
title('Eye');
ylabel('distance');


subplot(4,1,3);
plot(disn.left_cheek(1:16680,1,1)); hold on;
plot(disn.right_cheek(1:16680,1,1)); hold on;

plot(disn.left_nose(1:16680,1,1)); hold on;
plot(disn.right_nose(1:16680,1,1)); hold on;
legend('left cheek1','right cheek1','left cheek2','right cheek2');
title('Cheek');
ylabel('distance');


subplot(4,1,4);
plot(disn.left_dimple(1:16680,1,1)); hold on;
plot(disn.right_dimple(1:16680,1,1)); hold on;

plot(disn.left_centlip(1:16680,1,1)); hold on;
plot(disn.right_centlip(1:16680,1,1)); hold on;
legend('left dimple1','right dimple1','left dimple2','right dimple2');
title('Dimple');
ylabel('distance');
hold on

figure
subplot(2,1,1);
plot(disn.left_uplip(1:16680,1,1)); hold on;
plot(disn.uplip(1:16680,1,1)); hold on;
plot(disn.right_uplip(1:16680,1,1)); hold on;
legend('left uplip','uplip','right uplip');
title('Upper lip');
xlabel('frame');
ylabel('distance');

subplot(2,1,2);
plot(disn.left_downlip(1:16680,1,1)); hold on;
plot(disn.downlip(1:16680,1,1)); hold on;
plot(disn.right_downlip(1:16680,1,1)); hold on;
legend('left downlip','downlip','right downlip');
title('Down lip');
ylabel('distance');
hold on