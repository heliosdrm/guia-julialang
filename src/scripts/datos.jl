using GRUtils

t = 0.01:0.01:1
function generadatos(t, fun)
    r = abs(randn())/5
    s = t .- r .- 0.1
    p = (s./r^2*fun(r)) .* exp.(-8(s./r).^2)
    n = randn(100)
    for _ = 1:10
        n[2:end] .+= n[1:end-1]
    end
    plot(n)
    pn = p .+ 0.05 .* n/1000
    y = cumsum(pn)
    rand() > 0.15 ? y : y
end

m = zeros(100,30)
for c = 1:15
    m[:,c] = generadatos(t, log)
end
for c = 16:30
    m[:,c] = generadatos(t, log2)
end
plot(t, m)

resu = zeros(30,2)
for i = 1:30
    pico, j = findmax(abs.(m[:,i]))
    resu[i,:] .= pico, t[j]
end

plot(resu[1:15,1],resu[1:15,2],"o",resu[16:30,1],resu[16:30,2], "o")

plot(m[:,11:30])

sig = rand(30) .> 0.15
m2 = m .* ifelse.(sig, 1.0, -1.0
plot(m2)
sig

plot(m2[:,1])
plot!(gcf(), m2[:,6], hold=true)
plot(m2[:,5])
cd("/home/meliana/Documentos/Helios/programacion/guia-julialang/src/datos")
mkdir("series")
cd("series")
for i = 1:30
    c = (i <= 15) ? "A" : "B"
    d = Base.Printf.@sprintf("%02d", i)
    fn = "s$c$d.txt"
    ts = map(t) do x
        Base.Printf.@sprintf("%0.2f", x)
    end
    nums = map(m2[:,i]) do x
        Base.Printf.@sprintf("%0.3f", x)
    end
    open(fn, "w") do f
        for j = 1:100
            println(f, "$(ts[j])\t$(nums[j])")
        end
    end
end
