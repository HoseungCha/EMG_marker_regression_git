% ## 검정지표 계산(결정계수 R^2) 


% testY : test set의 xyz
% test_predict : regression 된 xyz
% >> 위에 둘다 (n X 3) matrix

% # 실제 값의 평균계산
test_target_mean = zeros(1,3)
for i = 1: 3
    test_target_mean(1,i) = mean(testY(:,i))
end

    
%  SST & SSE 계산
sst = zeros((len(testY),1))
sse = zeros((len(testY),1))
temp1 = zeros((1,3))
temp2 = zeros((1,3))
for i= 1: len(testY)
    for j=1: 3
        temp1(1,j) = square( testY(i,j)-test_target_mean(1,j) )
        temp2(1,j) = square( test_predict(i,j) - testY(i,j) )
    end
    sst(i,0) = sum(temp1)
    sse(i,0) = sum(temp2)
end
sst = sum(sst)    
sse = sum(sse)    
r_square = 1 - (sse / sst)
