# Capítulo 3. Funciones y estructuras de control

La potencia de un lenguaje de programación se encuentra a la hora de implementar algoritmos medianamente complejos, que impliquen algo más que una secuencia lineal de operaciones. A poco que aumente la complejidad de un programa, se hace necesario utilizar ciertas estructuras de código entre las que podemos destacar:

* Funciones que encapsulen "trozos" de código con el fin de reutilizarlos o simplificar el código fuente.
* Estructuras de control para definir flujos condicionales e iterativos en la ejecución del código.

En los capítulos anteriores ya hemos visto ejemplos de funciones y estructuras de control, que se han presentado sin apenas explicaciones. En este capítulo vamos a dar las explicaciones básicas para entenderlas y utilizarlas, ya que son una parte fundamental de cualquier lenguaje de programación, aunque sin entrar en ciertos detalles avanzados que se dejan para capítulos específicos más adelante.

Siguiendo el esquema habitual, comenzamos con un ejemplo más que nos servirá como guía para las explicaciones posteriores.

## Ejemplo: "hoja de calendario"

Vamos a crear un programa que toma como entrada los números de un mes y un año, y escribe un código HTML para representar el calendario del mes correspondiente. Los pasos a seguir por este programa son los siguientes:

1. Calcular el primer día de la semana de ese mes.
2. Calcular el número de días incluidos en el mes.
3. Escribir el código del calendario como una tabla HTML de 7 columnas, con los siguientes contenidos:
    * Una primera fila con los nombres de los días de la semana.
    * Celdas en blanco en la segunda fila hasta llegar al primer día del mes.
    * Celdas numeradas secuencialmente en varias filas, hasta llegar al último día del mes.
    * Celdas en blanco tras el último día, hasta completar la última semana.

El primer paso lo podemos resolver con la función [`gauss_diasemana`](1-primerospasos.md#gauss_diasemana) que se presentó en el capítulo 1. Pero como esa función devuelve el día de la semana en forma de texto, necesitamos la lista de días para convertirlo en un número. Si consideramos que la semana comienza el lunes, esta lista es:

```@setup c3
include("../../scripts/calc_diasemana.jl")
```

```@example c3
listadias = ["lunes","martes","miércoles","jueves","viernes","sábado", "domingo"]
nothing # hide
```

La función `numero_primer_dia` que se presenta a continuación utiliza esta lista y la función `findfirst`, para encontrar la primera (y única) posición de la lista que coincide con el resultado de `gauss_diasemana`:[^1]

```@example c3
function numero_primer_dia(m, y)
    primerdia = gauss_diasemana(1, m, y)
    return findfirst(primerdia .== listadias)
end
nothing # hide
```

[^1]: Esta no es una forma muy eficiente de buscar la posición de `primerdia` en `listadias`, aunque es simple y para conjuntos de datos pequeños funciona bien.

devuelve un vector de índices, porque podría darse el caso de que el elemento a buscar estuviese repetido en varias posiciones. Si el elemento buscado no estuviera en la lista, el único elemento del vector sería un `Nothing` --un elemento que representa un resultado nulo--.

El segundo paso (contar el número de días) es trivial para todos los meses excepto para febrero, que depende de que el año sea bisiesto o no. Para resolver este problema definimos la función `es_bisiesto`, que compara si un supuesto 29 de febrero caería en el mismo día de la semana que el 1 de marzo, y devuelve el valor "verdadero" (`true`) si los días no coinciden (el año es bisiesto), o "falso" (`false`) en caso contrario:

```@example c3
es_bisiesto(y) = (gauss_diasemana(29,2,y) != gauss_diasemana(1,3,y))
nothing # hide
```

Con esto, podríamos definir la siguiente función para calcular el número de días del mes:

```@example c3
function numero_dias(m, y)
    if m in [1, 3, 5, 7, 8, 10, 12] # enero, marzo, etc.
        return 31
    elseif m == 2 # febrero
        return (es_bisiesto(y) ? 29 : 28)
    else # el resto de meses
        return 30
    end
end
nothing # hide
```

La composición del calendario la hace la función `calendario_html` que se presenta a continuación. Esta función comienza llamando a las dos que hemos definido antes, y continúa escribiendo el código HTML en la variable `tablahtml`, una cadena de texto que se va ampliando paso a paso. Esta cadena de texto comienza siendo la etiqueta `<table>` que marca el inicio de una tabla, y finaliza con la etiqueta de cierre `</table>`. Cada fila se enmarca entre las etiquetas `<tr>`, `</tr>`, y cada celda dentro de una fila entre `<td>` y `</td>`.[^2]

[^2]: Véase la estructura de tablas HTML en [https://www.w3schools.com/html/html_tables.asp](https://www.w3schools.com/html/html_tables.asp).

Para ampliar la cadena de texto `tablahtml` con un texto determinado usamos la operación de concatenación de textos, con instrucciones del tipo `tablahtml *= texto`, que es una forma abreviada de escribir `tablahtml = tablahtml * texto"`. También utilizamos la operación de "interpolación" descrita en el capítulo anterior. Por ejemplo, la cadena de texto `"<td>$nd</td>"` representa el código HTML para una celda con el valor de la variable `nd` interpolado. La cadena de texto completa se convierte al final de la función en un bloque de código HTML, con la función `HTML`.

El código de la función es el siguiente. Aunque pueda resultar algo críptico a primera vista, a lo largo de este capítulo iremos desentrañando sus distintas partes:

```@example c3
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
    # Número del día que correspondería al primer lunes del calendario:
    # (1 si `primerdia == 1`, 0 si `primerdia == 2`, etc.)
    dia_mes = 2 - primerdia
    # Añadir filas al calendario, hasta que no queden días del mes
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
nothing # hide
```

Con este código cargado en nuestra sesión de trabajo, podemos generar la tabla del mes de agosto de 2018 escribiendo la siguiente instrucción:

```@example c3
calendario_html(8, 2018)
```

## Funciones

Las funciones son bloques de código que encapsulan un conjunto de instrucciones para crear o transformar una o más variables, a partir de unos datos de entrada. En el ejemplo anterior hemos creado varias funciones, que sirven de muestra para ver distintas formas de definirlas.

Una de las principales utilidades de definir funciones es la posibilidad de reutilizar el código en otros sitios. Esto ahorra líneas de código, reduce el riesgo de errores a la hora de reescribirlo, y hace los programas más legibles. Una ventaja adicional en el caso de Julia es que, si las características del código lo permiten, las funciones se compilan la primera vez que se ejecutan, y esto puede hacer que los programas vayan mucho más rápidos.

Como se ha visto en los ejemplos, el código para definir una función es el siguiente:

```julia
"""
DOCSTRING
"""
function NOMBRE(ENTRADAS)
    # CÓDIGO
    return SALIDAS
end
```

Las palabras en mayúsculas representan los elementos que son propios de cada función (normalmente no se escriben en mayúsculas, pero se usan aquí para distinguirlos):

* `DOCSTRING` es un texto de documentación de la función. Se trata de un elemento opcional, que en el ejemplo anterior solo hemos usado para la función principal (`calendario_html`).
* `NOMBRE` es el nombre de la función, como `calendario_html`, `es_bisiseto`, etc.. Cualquier nombre válido para una variable es válido también para funciones.
* `ENTRADAS` es la lista de variables de entrada a la función (véanse los detalles más abajo). Pueden definirse funciones que no requieran ningún argumento, en cuyo caso los paréntesis después del nombre de la función se dejan vacíos.
* `CODIGO` es el cuerpo con el código que se ha de ejecutar en la función, utilizando los argumentos de `ENTRADA` y cualesquiera otras variables que se definan dentro de la función. El código se suele escribir indentado respecto al encabezado de la función
* `SALIDAS` es la lista de variables de salida de la función (véanse los detalles más abajo). La función finaliza inmediatamente cuando se ejecuta la línea que contiene la palabra `return`, aunque haya más código escrito después. Si no se pone ninguna línea con la palabra `return`, se devuelve por defecto el valor de la última línea de código de la función, como `HTML(tablahtml)` en la función `calendario_html`.

Cuando el cuerpo de la función es tan sencillo que se puede reducir a una sola línea, también se puede simplificar la forma de definirla, eliminando la clave `function` y el finalizador `end`. Este es el caso, por ejemplo, de la función `es_bisiesto`. Por poner otro ejemplo, las siguientes declaraciones definen la misma función para calcular la suma aritmética `1+2+ ... + n`

```julia
function suma_aritmetica(n)
    return n * (n + 1) / 2
end

function suma_aritmetica(n)
    n * (n + 1) / 2
end

suma_aritmetica(n) = n * (n + 1) / 2
```

A continuación se presentan brevemente cada uno de los elementos empleados en la definición de una función.

### Docstring

El llamado "docstring" es un texto para documentar la función, de tal manera que si se consulta en la ayuda, se presentará ese texto en pantalla. Se trata de un elemento opcional (si no se proporciona ningún "docstring", al consultar la ayuda de la función se presentará un texto estándar declarando que se trata de una función no documentada).

Cualquier cadena de texto entrecomillada, escrita justo antes de declarar la función, sirve de "docstring", pero el estilo habitual es el empleado en el ejemplo de `calendario_html` (y de `gauss_diasemana` del primer capítulo):

* El texto se escribe entre dos líneas con tres comillas `"""`, que sirven para delimitar una cadena de texto que ocupa varias líneas (y en las que se pueden escribir palabras entre comillas sin tener que utilizar secuencias de escape).
* Se puede utilizar el formato [Markdown](https://daringfireball.net/projects/markdown/) para escribir el texto de ayuda con formato (líneas de título, formato de texto, bloques de código, hiperenlaces, etc).
* En la primera línea se escribe la forma (o formas) de llamar a la función, con el texto indentado para que al consultar la ayuda aparezca escrito como un bloque código.
* Después de un espacio de separación se describe lo que hace la función, ejemplos de uso y otros detalles de interés.

### Argumentos de entrada

Las funciones pueden tener uno, varios o ningún argumento de entrada. Los argumentos de la función se declaran como una lista de variables separadas por comas, encerrados entre paréntesis después del nombre de la función. Por ejemplo, `calendario_html` toma los argumentos `m` (número del mes) e `y` (año), por lo que su declaración es:

```julia
function calendario_html(m, y)
```

#### Agrupaciones de argumentos

Puede ocurrir que los datos a pasar a la función estén recogidos en una misma variable, por ejemplo dentro de un vector. Para esos casos, Julia dispone de una forma especial de introducir series de datos en la llamada a la función, "descomponiéndolas" como si fueran variables individuales.

Supongamos, por ejemplo, que el mes a evaluar está en la cadena de texto `08-2018`. Con la función `split` podemos extraer las partes correspondientes al mes y el año:

```@repl c3
fecha = "08-2018"
numeros = split(fecha, "-")
```

Luego usamos la función `parse` para interpretar los textos como números enteros (`Int`); se llama a la función mediante la sintaxis "con punto" para aplicarla a los dos elementos del vector a la vez, como vimos en el capítulo anterior:

```@repl c3
numeros = parse.(Int, numeros)
```

Este vector de dos números se puede pasar a la función `calendario_html` como si fueran dos números separados, añadiéndole unos puntos suspensivos que hacen de operador de "descomposición" (lo que en inglés llaman *splatting of variables*):

```julia-repl
julia> calendario_html(numeros...)
```

Este operador tiene también un uso simétrico. Al declarar los argumentos de entrada en una función, el último de ellos puede escribirse con puntos suspensivos. Esto significa que a partir de su posición puede ponerse un número variable de argumentos (incluso ninguno), de tal manera que todos ellos se recogerán en una sola variable.

Esto ocurre, por ejemplo, con la función `joinpath` que se usa para componer la ruta de un archivo o directorio. Su declaración es:

```julia
function joinpath(parts...)
```

Esta declaración significa que se puede introducir cualquier número de argumentos, los cuales se agruparán como elementos de una sola variable, que el código de la función reconocerá con el nombre `parts`.

#### Argumentos con valores por defecto

Es posible hacer que algunos argumentos tengan valores por defecto, haciendo que sea opcional introducirlos. El valor por defecto se define en la declaración de la función escribiéndolo junto al nombre del argumento separado por el signo `=`. Por ejemplo, esta sencilla función sirve para incrementar el valor de `x` con un valor arbitrario, que por defecto es `1`.

```@example c3
incrementar(x, inc=1) = x + inc
nothing # hide
```

A esta función se le puede llamar con uno o dos argumentos:

```@repl c3
incrementar(5)
incrementar(5, 3)
```

Los argumentos con valores por defecto han de estar necesariamente después de los argumentos obligatorios, para que no exista ambigüedad a la hora de llamar a la función con un conjunto reducido de argumentos. Por la misma razón, no es posible combinar argumentos con valores por defecto y agrupaciones variables de argumentos (con los puntos suspensivos).

#### Argumentos "con nombre"

Algunas funciones también admiten argumentos identificados por su nombre, en lugar de por su posición (lo que en inglés se llaman *keyword arguments*). En el capítulo anterior hemos visto algunos ejemplos, como los argumentos `skipstart` y `header` de la función `readdlm`, o `delim`, `ignorerepeated`, `missingstring`, etc. de `CSV.read`.

Los argumentos "con nombre" se introducen siempre después de los argumentos posicionales, y es habitual (aunque no obligatorio en general) separar ambos conjuntos de argumentos por un punto y coma, en lugar de una coma. Una propiedad interesante de estos argumentos es que se pueden pasar en cualquier orden, ya que el nombre es suficiente para distinguirlos.

Estos argumentos también pueden declararse con valores por defecto (en cuyo caso son opcionales) o sin ellos (lo que los hace obligatorios), aunque lo más habitual es que sean opcionales. También es posible declarar un conjunto indefinido de argumentos con nombre utilizando los puntos suspensivos, igual que en el caso de los argumentos posicionales. Así pues, una función podría declararse con un conjunto de argumentos de entrada como el siguiente:

```julia
function foo(x, y, z...; a=1, b, c...)
    # [...]
end
```

!!! note

    El punto y coma es necesario para separar la lista de argumentos posicionales y los argumentos con nombre a la hora de definir la función. Si una función solo tuviera argumentos con nombre, la lista de argumentos debería empezar con un punto y coma --e.g. `foo(; a...)`.

Una forma (algo exótica, pero válida) de llamar a esta función `foo` podría ser:

```julia
foo(1.0, ["pim", "pam", "pum"]..., bang=0, b=10)
```

Los valores asignados a las variables de la función con esta llamada serían los siguientes:

* `x = 1.0`
* `y = "pim"`
* `z`: una colección de dos datos, con `z[1] = "pam"`, y `z[2] = "pum"`
* `a = 1` (valor por defecto)
* `b = 10`
* `c`: una coleccion de datos nombrados, con `c[:bang] = 0`.

La flexibilidad que proporcionan los argumentos con nombre los hace una opción atractiva para facilitar el uso de las funciones, pero es recomendable usarlos con mesura. El abuso de este tipo de argumentos es una causa frecuente de código poco eficiente, que impide a Julia utilizar todas sus herramientas para optimizar los programas.


### Argumentos de salida

El valor que las funciones devuelven por defecto es el resultado de la última línea de su código. Además, si alguna línea de la función contiene la palabra `return`, al ejecutarse esta línea la función devuelve el resultado que sigue y se interrumpe su ejecución. Esto permite que la función pueda terminar en varios puntos --según corresponda por el flujo de ejecución de instrucciones--. A menudo, como en los ejemplos mostrados, también se pone la palabra `return` en la última línea del código de la función para que el funcionamiento quede más claro, aunque no es estrictamente necesario.

Si por alguna razón conviene que la función no devuelva ningún valor, se puede añadir una línea que diga `return nothing`. Esto hace que el resultado devuelto por la función sea el objeto de tipo `Nothing`, que en la práctica es como si no devolviese nada.

Las funciones también pueden actuar como su devolviesen más de un resultado. En el capítulo anterior vimos el siguiente ejemplo, en el que la función `readdlm` se utilizaba con la opción `header=true` para extraer por un lado una matriz de datos y por otro los nombres de las columnas correspondientes:

```julia
(datos_un, nombres) = readdlm("datos/esperanzadevida.txt", header=true)
```

Para que una función devuelva dos o más variables basta con poner la lista de resultados seapradas por comas, como en la siguiente función que devuelve la media y la diferencia de dos números:

```@example c3
function mediaydiferencia(a, b)
    media = (a + b) / 2
    diferencia = b - a
    return (media, diferencia)
end
nothing # hide
```

En realidad lo que ocurre al hacer esto es que la función devuelve una "tupla" de valores. Una tupla es una colección de datos, parecida a un vector, pero que no es mutable (sus valores on se pueden modificar). Al poner dos variables de salida en la llamada a la función, lo que se hace es descomponer esta tupla, de forma parecida a cuando se utilizan los puntos suspensivos en los argumentos de entrada. Así pues, las siguientes formas de usar la función `mediaydiferencia` serían equivalentes:

```@repl c3
# Opción 1: llamar a la función con dos salidas
m, d = mediaydiferencia(1, 5)
# Opción 2: una salida y descomposición posterior
resultado = mediaydiferencia(1, 5);
m = resultado[1]
d = resultado[2]
```

!!! note

    Los paréntesis en torno a la tupla de resultados, tanto en el cuerpo de la función como en la llamada a la misma, pueden ayudar a hacer el código más legible, pero como se ha visto en este ejemplo no son obligatorios.

### Cuerpo de la función: variables locales y globales

El cuerpo de una función es el bloque de código que se ejecuta al llamarla. Hay tres grupos de variables que se pueden usar dentro de una función:

En primer lugar están las variables introducidas como argumentos. Estas variables reciben valores externos, pero son internas a la función, lo que se conoce como "variables locales". Eso significa que se les puede reasignar otros valores dentro de la función sin que eso afecte al objeto original. Por ejemplo:

```@repl
function duplicar(x)
    # Cambiamos el valor del argumento `x`...
    x = 2x
    return x
end
x = 1
duplicar(x)
x # ... pero el valor original permanece inalterado
```

Luego están las variables que se definen dentro de las funciones, como `primerdia`, `ndias`, `tablahtml`, etc. en el caso de `calendario_html`. Estas también son variables locales, que se destruyen al término de la función, y por lo tanto no se puede acceder a ellas desde fuera (al margen de que sus valores sí se puedan devolver como resultado de la función, como se hace con `tablahtml`). Al igual que ocurre con los argumentos, estas variables locales pueden tomar nombres idénticos a los de variables definidas fuera de la función --o en otras funciones--, sin que haya conflico o confusión entre ellas.

Finalmente, dentro de una función también se pueden usar variables definidas en otra parte del código que contiene la función. Esto es lo que ocurre, por ejemplo, con la variable `listadias`, que hemos definido como una variable "global", externa a las funciones, pero es usada tanto por `numero_primer_dia` como por `calendario_html`. Lo que no puede hacerse con las variables globales es asignarles nuevos valores, ya que entonces se confundirían con variables locales

Esta capacidad de las funciones para reconocer objetos globales, definidos fuera de su contexto local, no solo es útil para poder reutilizar variables, sino que es crucial para que las funciones puedan llamarse entre ellas --ya que las funciones son objetos al igual que otras variables--.

!!! note "¡Cuidado con los objetos mutables!" 

    Aunque una variable global normalmente no pueda redefinirse dentro de una función, lo que sí puede ocurrir con un objeto global mutable (como el vector `listadias`), es que su contenido se modifique sin redefinir las variables. Lo mismo ocurre si se pasa un objeto mutable como argumento: aunque se asigne a una variable local, las modificaciones que se hagan a su contenido (sin haber reasignado otro valor a la variable) se reflejarán en la variable externa original.


## Bloques condicionales

Como dice su propio nombre, los bloques condicionales son fragmentos de código que solo se ejecutan si se cumple cierta condición. En el ejemplo del calendario tenemos varias de estas estructuras. De hecho, todo el código de la función `numero_dias` se reduce a una estructura de este tipo:

```julia
if m in [1, 3, 5, 7, 8, 10, 12] # enero, marzo, etc.
    return 31
elseif m == 2 # febrero
    return (es_bisiesto(y) ? 29 : 28)
else # el resto de meses
    return 30
end
```

Este código significa que si se cumple la condición que hay tras la palabra `if`, se ejecutará el bloque que sigue (reducido a la línea `return 31`), y se ignorará el resto hasta la palabra `end`. De no cumplirse, se evaluará la condición señalada por `elseif`, que condiciona la ejecución del siguiente bloque. Se podría añadir un número indefinido de `elseif`s, que se evaluarían secuencialmente hasta que alguno de ellos se cumpliera. Si ninguna de las condiciones señaladas por `if` o `elseif` se cumple, entonces se ejecuta el bloque de código que sigue a la palabra `else`.

Los bloques `elseif` y `else` son opcionales. Las estructuras condicionales pueden tener un solo bloque delimitado entre `if` y `end`, de tal manera que no se ejecute ningún código si la condición no se cumple.

Finalmente, se puede señalar una forma abreviada de escribir estructuras condicionales en una sola línea, especialmente adecuada para casos en los que el código a ejecutar es muy breve. Se trata del "operador ternario", que está presente en el segundo bloque del ejemplo anterior (el código que se ejecuta para el mes de febrero):

```julia
return (es_bisiesto(y) ? 29 : 28)
```

Este código significa: "si se cumple `es_bisiesto(y)`, entonces devuelve `29`; en caso contrario devuelve `28`. Una forma alternativa de escribirlo más elaborada, pero equivalente, sería:

```julia
if es_bisiesto(y)
    dias = 29
else
    dias = 28
end
return dias
```

### Expresiones lógicas

La condición asociada a los bloques `if` o `elseif`, así como al operador ternario, ha de expresarse como una variable lógica, de tipo `Bool`, que no es otra cosa que un número binario cuyos valores posibles son `true` o `false`. Estos valores lógicos se pueden obtener de múltiples maneras. Una forma muy habitual cuando se trabaja con números es a partir de comparaciones, por ejemplo:

* `a == b` (devolver `true` si `a` es igual a `b`)
* `a != b` (`true` si `a` es distinto de `b`)
* `a < b` (`true` si `a` es menor que `b`)
* `a > b` (`true` si `a` es mayor que `b`)
* `a <= b` (`true` si `a` es menor o igual que `b`)
* `a >= b` (`true` si `a` es mayor o igual que `b`)

Algunos de estos operadores de comparación pueden escribirse de forma más "elegante", usando los símbolos matemáticos correspondientes. Como dichos símbolos no suelen estar disponibles en los teclados, los principales interfaces para Julia permiten escribirlos a partir de "secuencias de escapes". Los símbolos matemáticos correspondientes a los operadores anteriores son:

|operador | símbolo | sec. de escape |
|:-------:|:-------:|:--------------:|
| `!=`    | `≠`     | `\neq`         |
| `<=`    | `≤`     | `\le`          |
| `>=`    | `≥`     | `\ge`          |

En la documentación oficial de Julia se puede encontrar una lista completa de las secuencias de escape disponibles para [caracteres Unicode](https://docs.julialang.org/en/v1/manual/unicode-input).

!!! tip

    Los cálculos realizados pueden introducen imprecisiones numéricas, por lo que comparaciones como `sqrt(5)^2 == 5` dan como resultado `false`, cuando teóricamente debería ser `true`. Para evitar estos problemas se puede usar la función `isapprox` o el operador de comparación `≈` (con la secuencia de escape `\approx`), así como su variante negativa `≉` (`\napprox`). Por ejemplo en `sqrt(5)^2 ≈ 5`, que da el resultado esperado.

También es habitual hacer comprobaciones relativas a valores singulares, perdidos, etc.:

* `isnan(x)` devuelve `true` si `x` es un "not-a-number" (`NaN`), por ejemplo el resultado de `0/0`.
* `isinf(x)` devuelve `true` si `x` es un valor infinito (sea positivo o negativo), por ejemplo el resultado de `1/0`.
* `isfinite(x)` es devuelve el valor opuesto a `isinf(x)`.
* `ismissing(x)` devuelve `true` si `x` es un "valor perdido" (`missing`).

Cuando se trabaja con conjuntos de datos (*arrays*, etc.), se pueden hacer comprobaciones como las siguientes:

* `a in x` devuelve `true` si el elemento `a` está entre los valores de `x`.
* `isempty(x)` devuelve `true` si `x` está "vacío" (no tiene ningún elemento).
* `all(x)` devuelve `true` si todos los elementos de `x` son `true`.
* `any(x)` devuelve `true` si cualquier elemento de `x` es `true`.

Las funciones `all` y `any` solo funcionan sobre conjuntos de elementos de tipo `Bool`. A menudo estos conjuntos proceden de operaciones lógicas (p.ej. comparaciones) realizadas sobre todos los elementos de otro conjunto de datos. Esto se puede hacer, como cualquier otra operación, utilizando la "notación con punto" sobre funciones y operadores como los que se han visto antes. Por ejemplo, para verificar que ningún número del vector `x` es negativo:

```@repl
x = [1, 2, 3, 4];
b = x .> 0
all(b)
x[1] = -1;
b = x .> 0
all(b)
```

### Composición de expresiones lógicas

A menudo se generan expresiones lógicas complejas, que son el resultado de combinar varias expresiones más sencillas. Para algunas operaciones de comparación esta combinación se reduce a concatenarlas, como cuando comprobamos si el número de un día está dentro del rango válido para un mes:

```julia
1 ≤ dia_mes ≤ ndias
```

Sin embargo lo más frecuente es usar conectores lógicos, como los siguientes:

* Negación (`!`): Si `a` es `true`, entonces `!a` es `false`, y viceversa.
* Conjunción lógica o *and* (`&`): `a & b` es `true` solo si tanto `a` como `b` son `true` a su vez.
* Disyunción lógica o *or* (`|`): `a | b` es `true` si cualquiera de `a` o `b` son `true`.

Las operaciones *and* y *or* se suelen hacer más a menudo mediante los "operadores de cortocircuito", escritos con el símbolo duplicado (`&&` y `||` respectivamente). Reciben este nombre porque las expresiones combinadas se van evaluando de izquierda a derecha, pero la evaluación se interrumpe tan pronto como se llega a un resultado inequívoco. Concretamente:

* En `a && b`, la expresión `b` solo se evalúa si `a` es `true`. En caso contrario se devuelve `false` sin evaluar `b`.
* En `a || b`, la expresión `b` solo se evalúa si `a` es `false`. En caso contrario se devuelve `true` sin evaluar `b`.

Este comportamiento es útil cuando una de las condiciones a comprobar solo tiene sentido en función de que se cumpla la otra o no. Por ejemplo, supongamos que llegados a un punto de un programa, tenemos un *array* `x` de tamaño indeterminado, que incluso podría estar vacío, y queremos comprobar si el primer elemento --en caso de que exista-- es cero. Esta condición se podría formular del siguiente modo:

```julia
!isempty(x) && (x[1] > 0)
```

Si no se cumpliese la primera condición (`!isempty(x)`, es decir que `x` no esté vacío), evaluar la segunda (`x[1] > 0`) generaría un error, ya que no se podría acceder al elemento `x[1]`. Pero el "cortocircuito" del operador `&&` evitaría llegar a ese punto.

Este comportamiento es equivalente al de un bloque `if` simple, del mismo modo que el operador ternario es equivalente a un `if`-`else`. Por este motivo, a veces se pueden encontrar programas que utilizan `&&` para abreviar bloques condicionales con expresiones muy sencillas, por ejemplo, si una función hubiera de interrumpirse si la variable `x` adopta el valor `0`, esto podría escribirse como:

```julia
x == 0 && return
```

## Bucles

Los bucles son fragmentos de código que se han de ejecutar repetidamente un número determinado de veces o hasta que se cumpla cierta condición. Junto con las funciones, son una de las herramientas principales para simplificar y reducir el código de un programa.

!!! tip

    En algunos lenguajes de programación como Matlab/Octave, Python (con Numpy) y R, se recomienda "vectorizar" las operaciones para evitar los bucles si es posible. Esto significa realizar todas las operaciones con una sola instrucción usando vectores o matrices, en lugar de repetir múltiples veces una misma operación sobre números escalares o vectores pequeños. Esto se debe a que cada línea de código que se ejecuta cuesta un tiempo de "interpretación", además del coste que tiene ejecutar la operación en sí, y en los bucles este coste se multiplica por el número de iteraciones. En Julia este coste extra se concentra en la primera vez que se realiza el cálculo, por lo que no hace falta evitar los bucles. De hecho, repetir operaciones sencillas con variables pequeñas suele ser más eficiente que realizar una operación compleja con grandes matrices de datos. 

En el ejemplo del calendario tenemos varios bucles. Algunos son del tipo `for`, como el que se se emplea para rellenar la fila de cabecera del calendario:

```julia
for nombre_dia = listadias
    tablahtml *= "<td>$(uppercase(nombre_dia))</td>"
end
```

Este bloque significa: "asigna a la variable `nombre_dia` los valores contenidos en `listadias`, uno a uno, y con cada uno de esos valores de `nombre_dia` ejecuta el código que sigue hasta el `end`".

!!! tip

    En las líneas que encabezan el bucle for, el símbolo `=` es intercambiable por `in`. Es decir, en el ejemplo anterior podría haberse escrito `for nombre_dia in listadias`. Utilizar `=` o `in` en este caso es una mera cuestión de estilo.

A menudo se desea repetir un bloque de código un número determinado de veces independiente de otras variables (por ejemplo, repetirlo 100 veces). En estos casos se suele utilizar un rango que sirve de contador de las iteraciones:

```julia
for i = 1:100
    # Código a repetir
end
```

O si el número que sirve de contador en estos casos no se va a utilizar en el bucle, se puede utilizar el guión bajo (`_`) para asignar el contador a una "variable de descarte", como se hace al rellenar las otras filas del calendario:

```julia
for _ = 1:7
    if 1 ≤ dia_mes ≤ ndias # Celdas con número dentro del mes
        tablahtml *= "<td>$dia_mes</td>"
    else # Celdas en blanco al principio y al final
        tablahtml *= "<td></td>"
    end
    dia_mes += 1
end
```

Los valores asignados a la variable de descarte `_` no quedan guardados, por lo que no se pueden utilizar posteriormente. Este truco se utiliza cuando por alguna razón es necesario hacer una asignación (como ocurre con los bucles `for`), pero realmente no interesa utilizar el valor asignado.

Por otro lado, a veces se quiere iterar sobre los contenidos de una variable --como el vector con nombres de días de la semana en el primer ejemplo--, pero a la vez tener un contador. Esto se puede conseguir con la función `enumerate`, como en el siguiente ejemplo:

```@example
for (contador, valor) = enumerate(["a", "b", "c"])
   println("Elemento número $contador: $valor")
end
```

Si el número de veces que se tiene que repetir el bucle no está predeterminado por un número o la longitud de una variable, se pueden utilizar los bucles de tipo `while`, como el utilizado para rellenar las filas con números del calendario:

```julia
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
```

En este bucle (que asimismo contiene el bucle `for` que rellena las columnas de cada fila), se comprueba si el número `dia_mes` ha llegado al último valor válido (`dia_mes <= ndias`). Si es así, se crea una nueva fila, y en caso contrario se da el bucle por finalizado.

En los bucles `while` se necesita utilizar alguna variable definida anteriormente para definir la condición de finalización. En la mayoría de casos el código que se ejecuta en el bucle será, directa o indirectamente, el que modifique esa variable para que se cumpla la condición y el bucle termine.

### Variables locales de los bucles

Es importante tener en cuenta que, tal como ocurre en las funciones, las variables creadas dentro de bucles `for` o `while` son variables locales al bucle, y que estas se "olvidan" al finalizar cada iteración. Es decir, que no pueden ser empleadas fuera del bucle, y ni siquiera en siguientes iteraciones, antes de volver a definirlas. Por ejemplo, el siguiente código daría lugar a un error:

```julia
for i = 1:10
    if i == 1
        x = 1
    else
        x = x + i
    end
end
```
```
ERROR: UndefVarError: x not defined
```

En la primera iteración se ejecutaría la línea `x = 1`, y en la segunda intentaría ejecutarse `x = x + i`; pero al tratarse de una iteración nueva, el valor de `x` no estaría definido de antemano y esa línea no se podría ejecutar.

Para hacer algo así, sería necesario definir primero la variable `x` *antes* del bucle. Esto es lo que se hace, por ejemplo, con la variable `tablahtml`, que se redefine dentro de varios bucles en el ejemplo del calendario.

Hay algunas excepciones y matices que comentar en relación con el contexto de las variables en funciones, bucles y otras estructuras, que se comentan más detalladamente en la sección sobre [Variables globales y locales](@ref) en el capítulo 8.

### Interrupción de bucles

El flujo habitual de los bucles se puede alterar mediante los comandos `break` y `continue`, que suelen ir en un `if` dentro del bucle. El comando `break` interrumpe el bucle en el punto en que se encuentre, y devuelve el control al punto del código desde el que se lanzó el bucle, como si este hubiera terminado. Por otro lado, `continue` solo interrumpe una iteración, y salta al comienzo de la siguiente. Veamos un ejemplo práctico, en una función para calcular números primos mediante una implementación literal de la ["criba de Eratóstenes"](https://es.wikipedia.org/wiki/Criba_de_Eratóstenes):

*Se forma una tabla con todos los números naturales comprendidos entre 2 y n, y se van tachando los números que no son primos de la siguiente manera: Comenzando por el 2, se tachan todos sus múltiplos; comenzando de nuevo, cuando se encuentra un número entero que no ha sido tachado, ese número es declarado primo, y se procede a tachar todos sus múltiplos, así sucesivamente. El proceso termina cuando el cuadrado del mayor número confirmado como primo es mayor que n.*

```julia
"""
    primos_eratostenes(n)

Devuelve un vector con los números primos entre 2 y n,
utilizando el método de la criba de Eratóstenes.
"""
function primos_eratostenes(n)
    # Utilizamos como "criba" un vector lógico,
    # con todos los valores inicialmente definidos como `false`
    eliminados = falses(n)
    # Comenzando por 2...
    for m = 2:n
      # Si el número (m) ha sido eliminado, pasar al siguiente
      if eliminados[m]
        continue
      end
      # Eliminar los múltiplos 2m, 3m ... menores que n
      k = 2
      while (mxk = m*k) ≤ n
        eliminados[mxk] = true
        k += 1
      end
      # Terminar si el cuadrado de m es mayor que n
      if m^2 > n
        break
      end
    end
    # Extraer las posiciones no eliminadas de la criba
    return findall(.!eliminados)
end
```

En este ejemplo, el bucle se interrumpe con `continue` si el número `m` ya ha sido eliminado en alguna de las iteraciones anteriores, y se finaliza con `break` antes de que `m` llegue a `n`, si el cuadrado de un número identificado como primo supera el valor de `n`.

## try ... catch ... finally

Para finalizar vamos a comentar brevemente una estructura de control que resulta de utilidad para gestionar posibles errores en la ejecución de un programa. Esta estructura tiene la siguiente forma:

```julia
try
    # Código que puede dar error
catch
    # Código a ejecutar si ha habido un error
finally
    # Operaciones de "limpieza"
end
```

En general, si alguna de las operaciones del bloque `try` da lugar a un error, este error no terminará la ejecución del programa ni se mostrará en pantalla, como suele ocurrir. En lugar de eso, se interrumpirá solo ese bloque y continuará ejecutándose el resto del programa. Los sub-bloques `catch` y `finally` son opcionales. El `catch` se ejecuta solo si ha habido algún error dentro del `try`, mientras que el `finally` se ejecuta siempre después de los dos bloques anteriores, tanto si ha habido un error como si no. El bloque `finally` se suele utilizar para operaciones de "limpieza" necesarias debido a posibles interrupciones del código anterior, como cerrar archivos que hayan quedado abiertos, etc.

Sin embargo, es importante tener en cuenta que el código del `finally` debe ser ejecutable independientemente de si el `try` ha fallado --y de *en qué punto* ha fallado--, por lo que no puede depender de las variables definidas dentro del `try` (ni del `catch`, si este existe). Para que esto sea así, cada uno de los sub-bloques `try`, `catch` y `finally` introduce su propio contexto local para variables, que se olvidan al finalizar el sub-bloque y no están disponibles en el resto del programa.

Así pues, no es conveniente abusar de los bloques `try-catch` como una herramienta para hacer programas "tolerantes a fallos". Esta estructura está pensada más bien para circunstancias en las que la terminación del programa debida a un error pueda suponer un problema más o menos grave, y el código incluido en estos bloques debería limitarse al necesario para prevenir esos problemas.

Cuando los errores sean previsibles, es mejor comprobar las condiciones que pueden dar lugar a esos errores con bloques condicionales (`if-else`, etc.). Por ejemplo, la función `isfile` sirve para comprobar si una cadena de texto corresponde a la ruta de un archivo existente, `isa` puede servir para comprobar que una variable es de tipo compatible con las operaciones a realizar (p.ej. `x isa Int` para comprobar que `x` es un número entero), etc.

Por otro lado, en el caso de los errores imprevisibles a menudo es mejor dejar que ocurran, porque suelen venir acompañados de información útil para mejorar el programa. Esto se verá más detalladamente en el capítulo dedicado al *debugging*.

## Sumario del capítulo

En este capítulo hemos visto el uso de funciones y estructuras de control (bloques condicionales y bucles), centrándonos en:

* La definición de "docstrings" para documentar las funciones.
* Los distintos tipos de argumentos de entrada: posicionales y con nombre, requeridos o con valores por defecto.
* Cómo agrupar y desagrupar argumentos con los puntos suspensivos (*splatting*).
* Cómo obtener varias salidas de una función.
* Los contextos global y local de las variables, y el uso de la palabra `global` para poder redefinir variables globales en entornos locales.
* Las distintas formas de definir bloques condicionales (`if`, `else`, `elseif` y el operador ternario).
* Bucles de tipo `for` y de tipo `while`.
* El uso de `enumerate` para crear un contador de iteraciones en los bucles `for`.
* La interrupción de bucles con `break` y `while`.
* Las estructuras `try-catch-finally` para gestionar errores fortuitos.

También hemos visto algunas operaciones y funciones que son de utilidad para trabajar con funciones, condiciones y bucles, aunque tienen un uso más general:

* Los operadores lógicos *and* (`&`) y *or* (`|`), sus alternativas "con cortocircuito" (`&&`, `||`), y el operador *not* (`!`).
* Operaciones de comparación, y funciones con resultado lógico como `isnan`, `isinf`, `isfinite` o `ismissing` (para números), así como `in`, `issempty`, `all` o `any` (para conjuntos de valores).
* La "variable de descarte" `_` para la asignación de valores que no requieren usarse.
* El uso de la variable `nothing` como salida nula de una función.

Finalmente, en los distintos ejemplos también hemos visto otras operaciones y funciones nuevas, como:

* La función `findfist` para buscar el primer valor no nulo de una colección.
* La concatenación de textos con el operador `*`.
* La función `uppercase` para convertir textos a mayúsculas.
* La función `joinpath` para crear rutas de archivos.
* La función `split` para descomponer cadenas de texto separadas por un delimitador.
* La función `parse` para convertir texto en números.
* La función `HTML` para convertir un texto en código HTML.
* La función `isfile` para comprobar si existe un archivo con una ruta determinada.
* La función `isa` para comprobar que una variable es de un tipo determinado.
