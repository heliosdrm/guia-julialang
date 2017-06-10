"""
Cálculo del día de la semana.
La función devuelve una cadena de texto con el día de la semana que corresponde
a los números de día, mes y año introducidos como los argumentos numéricos
`d`, `m`, `y`, respectivamente.
"""
function gauss_diasemana(d, m, y)
    # Enero y febrero (m=1, m=2) se tratan como el año anterior
    # en torno a los años bisiestos
    if m < 3
        y = y - 1
    end
    # Dividir el año entre centenas (c) y el resto (g)
    c = div(y, 100)
    g = mod(y, 100)
    # Definir e y f en función del mes (de 1 a 12) y el siglo
    # (en ciclos de 400 años --- 4 siglos)
    earray = [0,3,2,5,0,3,5,1,4,6,2,4]
    farray = [0,5,3,1]
    e = earray[m]
    f = farray[mod(c,4)+1]
    # Seleccionar el día de la semana en función del cálculo de Gauss
    warray = ["domingo","lunes","martes","miércoles",
        "jueves","viernes","sábado"]
    w = mod(d + e + f + g + div(g, 4), 7)
    return(warray[w+1])
end
