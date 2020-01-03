include("calc_diasemana.jl")

listadias = ["lunes","martes","miércoles","jueves","viernes","sábado", "domingo"]

function numero_primer_dia(m, y)
    primerdia = gauss_diasemana(1, m, y)
    for d = 1:7
        if listadias[d] == primerdia
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

"""
    calendario_html(m, y)

Crea el código HTML para el calendario del mes `m`
(un número del 1 al 12) del año `y`.
"""
function calendario_html(m, y)
    # Número del primer día y número de días del mes
    primerdia = numero_primer_dia(m, y)
    ndias = numero_dias(m, y)
    # Comienzo de la tabla
    tablahtml = "<table>\n"
    # Primera fila con nombres de los días (en mayúsculas)
    tablahtml *= "<tr>"
    for nombre_dia = listadias
        tablahtml *= "<td>$(uppercase(nombre_dia))</td>"
    end
    tablahtml *= "</tr>\n"
    # Día que correspondería al primer lunes:
    # (1 si `primerdia == 1`, 0 si `primerdia == 2`, etc.)
    dia_mes = 2 - primerdia
    # Añadir una nueva fila si quedan días del mes
    while dia_mes ≤ ndias
        tablahtml *= "<tr>"
        for _ = 1:7
            if 1 ≤ dia_mes ≤ ndias # Celdas con número dentro del mes
                tablahtml *= "<td>$dia_mes</td>"
            else # Celdas en blanco al principio y al final
                tablahtml *= "<td></td>"
            end
            dia_mes += 1
        end
        tablahtml *= "</tr>\n"
    end
    # Cerrar tabla
    tablahtml *= "</table>"
    HTML(tablahtml)
end
