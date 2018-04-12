layers = [ ...
    sequenceInputLayer(12)
    lstmLayer(100)
    fullyConnectedLayer(9)
    regressionLayer]