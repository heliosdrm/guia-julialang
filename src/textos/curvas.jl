using StatsFuns
imp_resp = [linspace(0,-1,10);linspace(-1,1.5,25);linspace(1.5,0,10);zeros(55)]
n = 30
anchos  = 3 + 3rand(n)
inicios = 15 + 3rand(n)
resp = zeros(100,2,n)
for par=0:1
    for i=1:n
        ax = par*(.5-rand())
        imp = normpdf.(inicios[i],anchos[i]+ax,collect(1:100))
        imp .+= 0.1.*maximum(imp).*randn(100)
        f = 4/(1+anchos[i]+ax) # 1+0.8*(3/anchos[i]-1)
        ir2 = [linspace(0,-1,round(10f));linspace(-1,1.5,round(25f));linspace(1.5,0,round(10f))]
        ir2 = [ir2;zeros(100-length(ir2))]
        resp[:,2-par,i] = real(ifft(fft(imp).*fft(ir2)))
    end
end



n = length(arch)
tmax = zeros(n)
vmax = zeros(n)
x = zeros(100)
tiempo = collect(1:100)
for i=1:n
    datos = readdlm(arch[i])
    x .= sqrt.(datos[:,1].^2+datos[:,2].^2) .* sign.(datos[:,1])
    # Buscamos el valor absoluto máximo y la fila en la que se encuentra
    valor_maximo, fila_maximo = findmax(x)
    valor_minimo, fila_minimo = findmin(x)
    # Y asignamos los datos que corresponden a los vectores tmax, vmax
    tmax[i] = tiempo[fila_maximo]-tiempo[fila_minimo]
    vmax[i] = valor_maximo-valor_minimo
end

