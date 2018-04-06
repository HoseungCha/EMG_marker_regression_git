function cost = GLVQ_costfun(dj, dk)
cost = (dj-dk)/(dj+dk);