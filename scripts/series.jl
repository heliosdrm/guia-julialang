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
    rand() > 0.15 ? y : -y
end

m = zeros(100,30)
for c = 1:15
    m[:,c] = generadatos(t, log)
end
for c = 16:30
    m[:,c] = generadatos(t, log2)
end
