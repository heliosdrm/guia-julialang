include("calc_diasemana.jl")

listadias = ["lunes","martes","miércoles","jueves","viernes","sábado", "domingo"]

function numero_primer_dia(m, y)
    primerdia = gauss_diasemana(1, m, y)
    for d = 1:7
        if primerdia == listadias[d]
            return d
        end
    end
end

es_bisiesto(y) = (gauss_diasemana(29,2,y) != gauss_diasemana(1,3,y))

function numero_dias(m, y)
    if m in [1, 3, 5, 7, 8, 10, 12] # enero, marzo, etc.
        return 31
    elseif m == 2 # febrero
        return (es_bisiesto(y) ? 29 : 28)
    else # el resto de meses
        return 30
    end
end

function calendario_vacio(primerdia, ndias)
    (semanas, resto) = divrem(ndias + primerdia - 1, 7)
    if resto == 0
        return tabla = fill("", semanas, 7)
    else
        return tabla = fill("", semanas + 1, 7)
    end
end

function rellenar_calendario!(tabla, primerdia, ndias)    
    # Contador de días (1 si `primerdia` es 1, 0 si es 2, etc.)
    dia_mes = 2 - primerdia
    # Rellenar filas del calendario, hasta que no queden días del mes
    fila = 1
    while dia_mes ≤ ndias
        for columna = 1:7
            if 1 ≤ dia_mes ≤ ndias # Celdas con número dentro del mes
                tabla[fila, columna] = string(dia_mes)
            end
            dia_mes += 1
        end
        fila += 1
    end
end

function tabla_html(tabla, encabezado)
    html = "<table>"
    # Primera fila con nombres de los días (en mayúsculas)
    html *= "<tr>"
    for celda = encabezado
        html *= "<td>$celda</td>"
    end
    html *= "</tr>\n"
    # Siguientes filas
    dims = size(tabla)
    for fila = 1:dims[1]
        html *= "<tr>"
        for columna = 1:dims[2]
            celda = tabla[fila, columna]
            html *= "<td>$celda</td>"
        end
        html *= "</tr>"
    end
    html *= "</table>"
    HTML(html)
end

"""
    calendario_html(m, y[, nombresdias])

Crea el código HTML para el calendario del mes `m`
(un número del 1 al 12) del año `y`, con un encabezado
que contiene los nombres de los días contenidos en `nombresdias`
(se asume que los días van de lunes a domingo).

El tercer argumento es opcional; si no se le pasa ningún valor,
el encabezado contiene los nombres de los días en minúsculas.
"""
function calendario_html(m, y, nombresdias=listadias)
    primerdia = numero_primer_dia(m, y)
    ndias = numero_dias(m, y)
    calendario = calendario_vacio(primerdia, ndias)
    rellenar_calendario!(calendario, primerdia, ndias)
    tabla_html(calendario, nombresdias)
end
