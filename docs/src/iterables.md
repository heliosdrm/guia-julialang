# Capítulo 6. Colecciones y objetos iterables

Los *arrays* que hemos visto en el capítulo anterior son una forma de representar conjuntos de datos, pero no la única. Hay muchos otros tipos de objetos que se califican como "colecciones" porque contienen series de datos organizadas, o también como "iterables" porque se pueden utilizar en bucles `for` o estructuras similares para generar un dato nuevo en cada iteración. En este capítulo veremos con detalle los principales tipos de estas variables, algunos de los cuales ya se han introducido en capítulos previos.

## Rangos

Anteriormente ya hemos visto el uso de rangos para crear iteradores en los bucles `for` y para indexar *arrays*. La forma más compacta de crear rangos es mediante la expresión `a:p:b`, donde `a` es el primer valor del rango, `b` el límite del rango, y `p` el "paso" o intervalo entre dos números seguidos del rango.

Por ejemplo, `1:1.5:6` representa los números 1.0, 2.5, 4.0 y 5.5 (el 6 es el límite superior, que no entra en el rango). El intervalo también puede ser negativo: por ejemplo `5:-1:3` representa los números contados "hacia atrás" 5, 4 y 3.

!!! note

    El operador `:` usado en estas expresiones tiene menos precedencia que los operadores aritméticos como la suma (`+`), la multiplicación (`*`), etc. Esto significa que por ejemplo `4 + 1:10` es lo mismo que `5:10`. Para sumar 4 a todos los valores del rango `1:10` se habría de escribir `4 .+ (1:10)`. (Nótese también que es necesario hacer el [*broadcasting*](arrays.md#Broadcasting-1) al operador de la suma.)

Para mayor flexibilidad también se puede usar la función `range`, cuyo primer argumento es el valor en el que comienza el rango, y el resto de valores se define mediante una combinación de los argumentos con nombre `stop`, `length` y `step`, como en los siguientes ejemplos:

```julia
range(1, stop=6)           # equivale a 1:6
range(1, length=6)         # equivale a 1:6
range(1, stop=6, step=2)   # equivale a 1:2:6
range(1, stop=6, length=3) # equivale a 1:2.5:6
range(1, step=3, length=4) # equivale a 1:3:10
```

En los ejemplos anteriores solo se han presentado rangos de números, pero también es posible crear y utilizar rangos con otros tipos de variables para las que se puedan definir un orden y cuantificar la distancia entre ellas. Un caso particular son los caracteres de texto (letras sueltas, no cadenas de texto), que están ordenados según el estándar Unicode. Por ejemplo:

```@repl
minusculas = 'a':'z'
minusculas[3]
```

Hay múltiples tipos de rangos, todos ellos englobados dentro del "supertipo" `AbstractRange`. Los rangos se comportan en muchas operaciones como vectores, aunque a diferencia de ellos son inmutables, es decir no se pueden ampliar, ni modificar sus valores, etc. Además, el único espacio que ocupan en memoria es el de los valores de referencia (el valor inicial, el paso, etc.). Los valores concretos que extraen al referirse a sus posiciones, iterar con ellos en un bucle `for`, etc., se calculan automáticamente, sin tener que guardarlos en memoria.

En caso de necesidad, los valores individuales de un rango (así como de otro tipo de colecciones) se pueden guardar en un vector a través de la función `collect`:

```@repl
r = 1:4
collect(r)
```

### Diccionarios

Los diccionarios (objetos de tipo `Dict`) son colecciones de datos que, al contrario que los *arrays* y los rangos, no identifican sus elementos por su posición en el conjunto, sino a través de una tabla de "claves" (*keys*). Hay muchas circunstancias en las que es interesante emplear estas series asociativas, aunque los diccionarios son particularmente útiles cuando el conjunto de claves no está predeterminado ni sigue un orden específico. Un buen ejemplo puede ser un conjunto de datos como la siguiente tabla de población por continente (datos de 2010, en millones de personas, según [bases de datos de la ONU](https://population.un.org/wpp/Download/Standard/Population/)).

| Continente | Población |
|:----------:|:---------:|
| África     | 1022      |
| América    | 944       |
| Asia       | 4170      |
| Europa     |  735      |
| Oceanía    |   36      |

Esto podría hacerse con un vector de países y otro de datos:

```@example c6
continentes = ["África", "América", "Asia", "Europa", "Oceanía"]
poblacion = [1044, 944, 4170, 735, 36]
nothing # hide
```

Pero extraer, por ejemplo, el valor correspondiente a Europa, requiere buscar el índice correspondiente en `continentes` y utilizarlo para indexar `poblacion`:

```@repl c6
poblacion[continentes .== "Europa"]
```

Además, esta operación no devuelve el resultado como un escalar, sino como un vector (aunque sea con un solo elemento), ya que nada impediría que hubiera varios elementos del vector `continentes` iguales a `España`. Para extraer un escalar, se podría utilizar la función `findfirst` que da el índice de solo la primera coincidencia:

```@repl c6
poblacion[findfirst(continentes .== "Europa")]
```

Sin embargo, el uso de un diccionario aquí simplifica las cosas. El constructor de diccionarios `Dict` puede usarse con parejas de claves y valores asociadas con el símbolo `=>` (a modo de flecha):

```@repl c6
dic_poblacion = Dict(
    "África" => 1044, 
    "América" => 944,
    "Asia" => 4170,
    "Europa" => 735,
    "Oceanía" => 36
)
dic_poblacion["Europa"]
```

Un primer detalle que llama la atención es que el orden de los elementos en la presentación del diccionario no coincide con el orden en el que se han especificado en la creación. Esto destaca lo que ya se ha señalado, que los valores del diccionario *no* se pueden identificar por posición, sino por su asociación con las claves.

La forma de ampliar los diccionarios también es distinta a como se haría con un *array*. Las funciones que se emplean con éstos, como `push!`, `append!`, etc., no sirven para los diccionarios. Añadir un elemento a un diccionario es más sencillo; por ejemplo, si quisiéramos añadir al diccionario la población de la Antártida (que se reduce a poco más de mil habitantes temporales), bastaría escribir:

```julia
dic_poblacion["Antártida"] = 0
```

Por otro lado, para eliminar una entrada a partir de su clave se utiliza la función `delete!`:

```julia
delete!(dic_poblacion, "Antártida")
```

El conjunto de claves presentes en un diccionario no es algo tan sencillo de delimitar como las posiciones válidas de un *array*. Por esta razón existe la función `haskey`, que permite averiguar si un diccionario tiene alguna clave en particular:

```@repl
haskey(dic_poblacion, "Asia")
haskey(dic_poblacion, "Norteamérica")
```

Además, con la función `get` se puede "preguntar" de forma segura a un diccionario por el valor asociado a una clave, definiendo un valor por defecto para los casos en los que dicha clave no exista:

```@repl
get(dic_poblacion, "Norteamérica", -1)
```

### Iterar con diccionarios

La forma de iterar con diccionarios en un bucle `for` también es distinta a como se haría con un rango o un vector, ya que los contenidos de los diccionarios no siguen un orden determinado. Sin embargo, en cada iteración tenemos dos variables en lugar de una (la clave y el valor), que asignamos como sigue::

```@example c6
for (k, v) = dic_poblacion
    println("$k: $v millones de personas")
end
```

También se puede iterar únicamente con las claves o los valores del diccionario, extrayéndolos con las funciones `keys` y `values`, respectivamente:

```@repl c6
claves = keys(dic_poblacion)
valores = values(dic_poblacion)
```

Estas funciones devuelven variables que se asemejan a vectores con las claves y valores extraídos del diccionario, en un orden indeterminado pero coherente entre sí. Sin embargo hay que señalar un par de detalles importantes:

* Aunque se puede iterar sobre esas variables (por ejemplo con un bucle `for`), sus elementos no pueden indexarse; por `claves[1]` no es una operación válida.
* Los contenidos de esas variables son referencias al diccionario original; si por ejemplo se modifica el valor de un elemento o se añade una nueva clave, las variables `claves` y `valores` que hemos definido arriba cambiarán al mismo tiempo.

Una utilidad de extraer las claves es poder reorganizarlas de forma arbitraria, por ejemplo en este caso en el que las claves son etiquetas textuales, para presentar los resultados en orden alfabético. Para ello hemos primero hemos de convertir el conjunto de claves a un *array*, de tal modo que podamos ordenarlo con la función `sort!`:


```@example c6
claves = collect(keys(dic_poblacion))
sort!(claves)
for k = claves
    v = dic_poblacion[k]
    println("$k: $v millones de personas")
end
```

!!! note

    La función `sort!` sirve para sustituir los valores del *array* original por los del ordenado. Para conservar el *array* original y crear otro con los valores ordenados, se puede usar la función `sort` (sin exclamación en el nombre).

!!! tip

    Para casos en los que sea importante trabajar con claves ordenadas, también se puede recurrir a los "diccionarios ordenados" que proporciona el paquete ["DataStructures"](https://juliacollections.github.io/DataStructures.jl/stable/), aunque son más lentos que los diccionarios básicos.

### Formas de construir diccionarios

Antes se ha señalado cómo construir diccionarios con la sintaxis `Dict(k1 => v1, k2 => v2...)`, donde `k1`, `k2`... son las claves, y `v1`, `v2`... son los valores. Pero hay otras formas de hacerlo, que pueden ser convenientes en distintas circunstancias.

Si las parejas de claves y valores están recogidas en una variable, esta se puede pasar directamente al constructor `Dict`, como en el siguiente ejemplo:

```@repl
glosas = [
    ["es", "libro"],
    ["en", "book"],
    ["de", "buch"]
]
Dict(glosas)
```

También puede darse el caso en el que tengamos las claves y los valores por separado, como los vectores `continentes` y `poblacion` usadas anteriormente. En casos como ese, podemos usar la función `zip` para combinar los dos vectores en otro objeto iterable de la misma longitud, cuyo primer elemento recoge el primer elemento de cada vector, en el segundo recoge los segundos, etc.:

```@repl c6
claves_y_valores = zip(continentes, poblacion);
Dict(claves_y_valores)
```

Los diccionarios están determinados por los tipos de sus claves y valores, como ocurre con los *arrays*. El diccionario `dic_poblacion` es del tipo `Dict{String, Int64}`, dado que lo hemos definido con cadenas de texto (`String`) como claves, y números enteros (`Int64`) como valores. Esto significa que no se podrían introducir entradas con otro tipo de claves o valores.

A la hora de definir un diccionario pueden especificarse otros tipos de claves y valores, siempre que sean compatibles con los datos introducidos. Por ejemplo, podríamos haber forzado que los valores sean números decimales (`Float64`), a pesar de que todos los que le hemos pasado son enteros:

```@repl
dic_poblacion = Dict{String, Float64}(
    "África" => 1044, 
    "América" => 944,
    "Asia" => 4170,
    "Europa" => 735,
    "Oceanía" => 36
)
```

## Tuplas

Las tuplas (objetos de tipo `Tuple`) son series de variables separadas por comas --y a menudo enmarcadas entre paréntesis, aunque esto se hace solo por claridad o para evitar ambigüedades, como en otros usos de los paréntesis--. Por ejemplo:

```@repl c6
unos = 1, 1.0, 1+0im, true
```

Las tuplas se parecen a los vectores en que sus elementos vienen determinados por su posición en la serie; por ejemplo el número entero del ejemplo anterior es `unos[1]`, el número complejo es `unos[3]`, etc. Sin embargo tienen algunas diferencias importantes.

En un vector (y en general en cualquier *array*) todos los elementos han de ser del mismo tipo (aunque sea un "supertipo" como `Any`, que comprende todos los tipos posibles). Por el contrario, cada elemento de una tupla puede ser de un tipo distinto: 

```@repl c6
typeof(unos)
```

Además, al contrario que los *arrays*, las tuplas son objetos "inmutables"; es decir, que una tupla no se puede ampliar ni reducir, ni se puede cambiar uno de sus elementos por otro (aunque se puede sustituir la tupla completa por otro contenido).

Hay que destacar, sin embargo, que esta inmutabilidad solo afecta a la tupla en sí: técnicamente no se puede cambiar un elemento por otro, pero puede parecer lo contrario si se trata de un elemento que *sí* es mutable, por ejemplo un *array*:

```@repl
x = [1,2]; y = [3,4];
tup = x, y
tup[1] = [0.1, 0.2] # No se puede modificar la tupla
tup[1][1] = 10; # Pero sus elementos sí son modificables...
x[2] = 20; # ... porque son objetos mutables en sí mismos.
tup
```

Estas dos diferencias entre tuplas y vectores son las que determinan cuándo es preferible usar una cosa u otra: si la colección de datos ha de modificarse en algún punto del programa es mejor usar vectores. De lo contrario, a menudo es más eficiente usar tuplas, especialmente si se desea tener un conjunto heterogéneo de datos agrupados.

Anteriormente hemos visto como la función `collect` se puede emplear para crear vectores a partir de otras colecciones o variables iterables. La tuplas pueden crearse de modo semejante usando el constructor `Tuple`. Alternativamente, se puede emplear la operación de *splatting* con puntos suspensivos, como cuando se reparten los contenidos de una variable entre los argumentos de una función (véase la sección sobre [Agrupaciones de argumentos](@ref) en el capítulo introductorio sobre las funciones). La diferencia es que hay que añadir una coma tras los puntos suspensivos --y también usar los paréntesis, para que no parezca una expresión inacabada--:

```@repl
numeros = 1:3
t1 = Tuple(numeros)
t2 = (numeros..., )
```

La coma final es también obligatoria para crear tuplas con un solo elemento:

```@repl
t3 = (10, )
```

Por otro lado la expresión empleada para agrupar variables en una tupla se puede usar de forma simétrica, para "desempaquetar" los contenidos de una colección de datos (un *array*, tupla, etc.) y asignarlos a distintas variables. Por ejemplo:

```@repl
x, y = (1, 2)
x
y
```

Este uso ya lo hemos visto con funciones que devuelven más de un resultado (que en realidad lo que hacen es devolver una tupla), y en el iterador de los bucles `for` cuando se aplica a diccionarios (el iterador es una pareja "clave/valor", que se pueden asignar a distintas variables).

## Tuplas con nombre

Del mismo modo que las tuplas "normales" representan un conjunto ordenado de variables, las llamadas "tuplas con nombre" (`NamedTuple`) representan conjuntos de variables que vienen identificadas por un nombre, como los [Argumentos "con nombre"](@ref) que aceptan algunas funciones. De hecho, estas tuplas se suelen definir del mismo modo que dichos argumentos con nombre:

```@repl c6
unos_nom = (entero=1, decimal=1.0, imaginario=1+0im, bool=true)
```

Hay distintas formas de referirse a los elementos de este tipo de tuplas:

```@repl c6
unos_nom.decimal   # Añadiendo el nombre tras un punto
unos_nom[:decimal] # Indexando con el nombre escrito en forma de símbolo
unos_nom[2]        # Indexando con la posición del elemento
```

Hasta cierto punto las tuplas con nombres se pueden ver como diccionarios inmutables, cuyas claves han de ser siempre símbolos. De hecho, funciones como `get`, `haskey`, `keys` y `values` se pueden usar con las tuplas con nombre del mismo modo que en los diccionarios. Sin embargo, hay otras otras diferencias importantes entre tuplas con nombre y diccionarios:

* Los elementos de una tupla con nombre mantienen el orden en el que se definieron, y se pueden indexar por su posición.
* Cuando se itera sobre una tupla con nombres, el elemento resultante de cada iteración no es la pareja nombre + valor, sino solo el valor.

Las tuplas con nombre se pueden crear a partir de colecciones o iteradores que contengan las parejas de nombres y valores correspondientes, mediante la operación de *splatting*. Al contrario que en el caso de las tuplas normales, no es necesario añadir una coma tras los puntos suspensivos, sino un punto y coma *antes* de la colección, como cuando se definen los argumentos con nombre en una función. Esta forma de crear tuplas con nombre se aplica a menudo con diccionarios en los que las claves sean símbolos, como en el siguiente ejemplo:

```@repl c6
diccionario = Dict(:a => 1, :b=>2)
parejas = (diccionario..., ) # Esto es una tupla ordenada de parejas
parejas[1]
tupla = (; diccionario...) # Y esto una tupla con nombres
tupla[1]
tupla.a
```

Como al iterar sobre tuplas con nombre no se extraen los nombres, esta operación no es simétrica. Para crear un diccionario a partir de una tupla con nombres, primero hay que convertirla en una coleccion de parejas. Esto se puede hacer mediante la función `pairs`:

```@repl c6
Dict(pairs(tupla))
```

## Generadores de colecciones y *comprehensions*

Hay circunstancias en las que para crear una colección la solución más directa es un bucle que genere sus contenidos elemento a elemento. Por ejemplo, pongamos que queremos crear un vector con cadenas de texto que expresen una tabla de cuadrados, al estilo de `"1² = 1"`, `"2² = 4"`, etc. Esto se podría hacer del siguiente modo para los cuadrados del 1 al 10:

```@example
cuadrados = Vector{String}(undef, 10)
for i = 1:10
    cuadrados[i] = "$(i)² = $(i^2)"
end
cuadrados
```

Una forma más compacta de hacer esto esto es mediante lo que en inglés se llama *comprehension*. Este recurso se suele utilizar cuando contenido de un bucle `for` es una línea cuya única finalidad es "rellenar" una colección. En este caso, el código equivalente a todo lo anterior sería:

```julia
cuadrados = ["$(i)² = $(i^2)" for i=1:10]
```

Esta expresión podría leerse como "crear un vector con las cadenas de texto `"$(i)² = $(i^2)"`, para cada valor de `i` entre 1 y 10". El código escrito entre los corchetes crea lo que se llama un "generador", que sirve tanto para crear *arrays* (si se encierra entre corchetes, como en este ejemplo) como otros tipos de colecciones. Por ejemplo, en lugar de un vector podríamos crear una tupla --con el constructor `Tuple` o mediante *splatting*, como se ha explicado anteriormente--:

```@repl
Tuple("$(i)² = $(i^2)" for i=1:10)
(("$(i)² = $(i^2)" for i=1:10)..., )
```

Si la expresión genera parejas de "clave/valor", también se puede usar para crear diccionarios. Por ejemplo, el siguiente código sería una alternativa a usar la función `zip` para crear un diccionario a partir de los vectores de claves y valores:

```@repl c6
Dict(continentes[i] => poblacion[i] for i=1:5)
```

### *Array comprehensions* con varias dimensiones

Hay una forma especial de usar *comprehensions* para crear *arrays* de varias dimensiones, cuando cada dimensión va asociada a un iterador distinto, y estos iteradores se combinan de forma independiente. Esto se explica más fácilmente con un ejemplo:

Supongamos que queremos ampliar la tabla de potencias, para que además de los cuadrados incluya otros exponentes. Esto se podría expresar en una matriz, cuyas filas se asociasen a las bases y las columnas a los exponentes. Podríamos hacer una tabla con las bases del 1 al 10 y los exponentes 2 y 3 (cuadrado y cubo, respectivamente), con dos bucles anidados como sigue:

```@example c6
exponentes = [2,3]
superindices = ["²", "³"]
potencias = Array{String}(undef, 5, 2)
for i = 1:5
    for j = 1:2
        potencias[i, j] = "$(i)$(superindices[j]) = $(i^exponentes[j])"
    end
end
potencias
```

!!! tip
    
    Los superíndices numéricos que se han utilizado para expresar los exponentes son caracteres especiales, que se pueden escribir en la REPL de Julia con las secuencias de escape `\^2`, `\^3`, etc., seguidas del tabulador.

Pero en casos como estos, en los que las operaciones del bucle interno no dependen de lo que se ha hecho en el externo, podemos hacer el conjunto de bucles más compacto con un solo `for` combinado:

```julia
potencias = Array{String}(undef, 5, 2)
for i=1:5, j=1:2
    potencias[i, j] = "$(i)$(superindices[j]) = $(i^exponentes[j])"
end
```

Y la sintaxis de las *comprehensions* permite crear esta matriz en una sola línea, aplicando cada uno de los iteradores combinados en el `for` a un eje distinto:

```julia
potencias = ["$(i)$(superindices[j]) = $(i^exponentes[j])" for i=1:5, j=1:2]
```

## Sumario del capítulo

En este capítulo hemos visto cómo se crean y cómo se trabaja con diversos tipos de colecciones y objetos iterables:

* Rangos de números y otras variables que se pueden disponer linealmente, como caracteres de texto.
* Diccionarios.
* Tuplas y tuplas con nombre.

Además, se ha explicado cómo utilizar *comprehensions* para generar distintos tipos de colecciones, y se han presentado algunas funciones nuevas que son útiles para trabajar con estos tipos de variables:

* `collect` para agrupar cualquier tipo de colección finita en un vector.
* `haskey` para determinar si un diccionario o tupla con nombre tiene una clave o nombre en particular.
* `get` para extraer un elemento de un diccionario o una tupla con nombre, con un valor por defecto para claves/nombres inexistentes.
* `keys` y `values` para extraer las claves y valores de los diccionarios, respectivamente --o los nombres y valores de tuplas con nombre--.
* `delete!` para eliminar un elemento de una colección mutable identificado por su clave (p.ej. en diccionarios).
* `sort` y  `sort!` para ordenar los elementos de una colección.
* `zip` para convertir dos o más colecciones de datos en un solo iterador que agrupa los elementos individuales de cada colección, uno a uno.

