function factoresprimos(n)
    # Lista de números enteros (Int) inicialmente vacía
    factores = Int[]
    # Se comienza probando el factor f = 2
    f = 2
    # Búsqueda en un bucle `while`
    while n ≥ f^2
        # Si se encuentra un divisor...
        if mod(n, f) == 0
            push!(factores, f) # se añade a la lista de factores
            n = div(n, f)      # y se divide n por el factor
        else
            # Si f no es un divisor, probar con el siguiente
            f = f + 1
        end
    end
    # Añadir el número que queda sin factorizar y devolver la lista
    push!(factores, n)
    return factores
end

function primos(n)
    # Se inicia la lista con `1`
    primos = [1]
    # m es el máximo factor primo a verificar
    m = 1
    valor_m = 4
    # Comenzamos a probar desde el número 2
    numero = 2
    while length(primos) < n
        # Partimos de la suposición de que `numero` es un primo
        es_primo = true
        # Comprobamos factores primos desde el 2 hasta el m-ésimo
        for p = primos[2:m]
            # Si el número es divisible, no es primo...
            if mod(numero, p) == 0
                es_primo = false
                break # ... y no hace falta seguir comprobando
            end
        end
        # Añadir el número primo si se ha verificado
        if es_primo
            push!(primos, numero)
        end
        # Pasar al siguiente número
        numero = numero + 1
        # Si se alcanza el valor máximo, aumentar el umbral
        if numero == valor_m
            numero = numero + 1
            m = m + 1
            valor_m = primos[m+1]^2
        end
    end
    return primos
end
