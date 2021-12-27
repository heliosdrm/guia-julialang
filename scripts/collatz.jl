
## Algoritmos básicos

"""
    siguiente_collatz(x::Integer)

Calcula el siguiente número a `x` en una secuencia de Collatz.
Emite un error si el resultado es demasiado alto para el tipo de `x`.

# Ejemplo
```julia-repl
julia> siguiente_collatz(5)
16

julia> siguiente_collatz(6)
3
```
"""
siguiente_collatz(x::BigInt) = iseven(x) ? x ÷ 2 : 3x+1

function siguiente_collatz(x::T) where T<:Integer
    if iseven(x)
        return x >>> 1
    else
        if x > typemax(T) ÷ 3
            throw(DomainError("la secuencia excede del límite superior para $T"))
        end
        return T(3)*x + one(T)
    end
end


"""
    pasoscollatz(x, x0)

Calcula el número de pasos en la secuencia de Collatz desde `x` hasta 1.

# Ejemplo
```julia-repl
julia> pasoscollatz(3) # - 10 - 5 - 16 - 8 - 4 - 2 - 1
7 
```
"""
function pasoscollatz(x::Integer)
    (x < 1) && throw(DomainError("solo se admiten números naturales a partir de uno"))
    n = 0
    while x > 1
        x = siguiente_collatz(x)
        n += 1
    end
    return n
end

"""
    pasoscollatz(x, x0)

Calcula el número de pasos en la secuencia de Collatz
desde `x` hasta un número inferior a `x0`.
Devuelve una tupla con el número de pasos y el número alcanzado.

# Ejemplo
```julia-repl
julia> pasoscollatz(9,8) # - 28 - 14 - 7 
(3, 7)
```
"""
function pasoscollatz(x::Integer, x0)
    (x < 1) && throw(DomainError("solo se admiten números naturales a partir de uno"))
    n = 0
    while x ≥ x0
        x == 1 && break
        x = siguiente_collatz(x)
        n += 1
    end
    return (n, x)
end

"""
    serie_pasoscollatz(n::Integer)

Calcula un vector con el número de pasos en las
secuencias de Collatz con valores iniciales desde 1 hasta `n`.
Las secuencias se calculan con el tipo de entero usado en `n`.

# Ejemplo
```julia-repl
julia> serie_pasoscollatz(5)
5-element Vector{Int64}:
 0
 1
 7
 2
 5
```
""" 
function serie_pasoscollatz(n::T) where T<:Integer
    pasos_total = zeros(Int, n)
    for i=range(T(2), stop=n)
        (pasos, inferior) = pasoscollatz(i, i)
        pasos_total[i] = pasos + pasos_total[inferior]
    end
    return pasos_total
end

# Algoritmos para paralelización

"""
    pasoscollatz!(v, x)

Calcula el número de pasos en la secuencia de Collatz
desde `x` hasta 1, y lo asigna a `v[x]`.
(Se asume que los valores previos de `v[i]` son cero, o bien
el número correcto de pasos de la secuencia de Collatz
que comienza por `i`.)

# Ejemplo
```julia-repl
julia> v = [0,1,0,0,0];

julia> pasoscollatz!(v, 4)
2

julia> v
5-element Vector{Int64}:
 0
 1
 0
 2
 0
 ```
"""
function pasoscollatz!(v::AbstractArray, x)
    xmax = length(v)
    if (x < 1) || (x > xmax)
        throw(DomainError("solo se admiten números naturales menores que $xmax"))
    end
    n = 0
    s = x
    while s > 1
        if s ≤ xmax && v[s] ≠ 0 # (si el valor de v[s] está calculado) 
            return v[x] = n + v[s]
        end
        s = siguiente_collatz(s)
        n += 1
    end
    return v[x] = n
end

"""
    serie_pasoscollatz_threads(n::Integer)

Calcula un vector con el número de pasos en las
secuencias de Collatz con valores iniciales desde 1 hasta `n`.
Las secuencias se calculan con el tipo de entero usado en `n`.

# Ejemplo
```julia-repl
julia> serie_pasoscollatz_threads(5)
5-element Vector{Int64}:
 0
 1
 7
 2
 5
```
""" 
function serie_pasoscollatz_threads(n::T) where T<:Integer
    pasos_total = zeros(Int, n)
    Threads.@threads for i=range(T(2), stop=n)
        pasoscollatz!(pasos_total, i)
    end
    return pasos_total
end
