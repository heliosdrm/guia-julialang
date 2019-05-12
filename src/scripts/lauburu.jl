ang = linspace(0,pi,100)
(x1, y1) = (1.+cos.(pi.-ang), sin.(pi.-ang))
(x2, y2) = (1.5.+0.5cos.(-ang), 0.5sin.(-ang))
(x3, y3) = (0.5.+0.5cos.(ang), 0.5sin.(ang))
(x, y) = ([x1; x2; x3], [y1; y2; y3])
# Derecha; Arriba; Izquierda; Abajo
lauburu_x = [x; -y; -x; y]
lauburu_y = [y; x; -y; -x]
lauburu = Shape(lauburu_x, lauburu_y)

