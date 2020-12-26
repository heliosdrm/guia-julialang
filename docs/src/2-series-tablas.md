# Capítulo 2. Series y tablas de datos

```@setup c2
cp("../../datos/", "./datos")
```

## Un ejemplo para empezar

En un uso productivo de un lenguaje de programación no nos limitamos a introducir datos con el teclado y leer los resultados en pantalla. Usamos series largas de datos, tablas numéricas... que normalmente se leen a partir de archivos de texto u hojas de cálculo. La salida también pueden ser archivos de ese tipo, o bien gráficas (que veremos en el [capítulo 4](4-graficos.md)). Vamos a ver como se leen, escriben y estructuran esos datos.

```@raw html
<div id="ejemplo_series" />
```

Pongamos el siguiente caso. Tenemos unas medidas de un experimento, consistente en 30 series de datos semejantes a la mostrada abajo -- aunque en algunos casos la señal aparece invertida--. Estos datos se encuentran grabados en los archivos de texto contenidos en la carpeta `datos/series/` en el repositorio de esta guía [https://github.com/heliosdrm/guia-julialang](https://github.com/heliosdrm/guia-julialang/).

Cada uno de estos archivos tiene 100 líneas con dos columnas de números separadas por tabuladores: la primera columna es una línea de tiempos equiespaciada que varía entre 0.01 y 1.00, y la segunda contiene los valores de las medidas.

```@example c2
using DelimitedFiles, Plots # hide
datos = readdlm("datos/series/sA12.txt") # hide
plot(datos[:,1],datos[:,2]) # hide
```

En todos los casos las series tienen una forma semejante: comienzan fluctuando ligeramente en torno a cero, hasta que en un momento la curva asciende (o desciende) hasta un valor máximo (positivo o negativo) y luego vuelve a un esado de reposo cercano a cero. Supongamos que en nuestro estudio el hecho de que el extremo sea positivo o negativo es irrelevante (podría ser causado por haber invertido el sistema de medida), y que queremos crear una tabla con el valor extremo de cada serie y el instante en el que se alcanza. El código para construir la tabla de datos, que iremos analizando a lo largo del capítulo, es el siguiente:

```@example c2
# Leemos los nombres de los archivos del directorio "series"
directorio = "datos/series"
archivos = readdir(directorio)
# ¿Cuantos archivos tenemos?
n = length(archivos)
# Creamos dos vectores de números con tantos ceros como archivos hay:
# uno para los valores extremos y otro para los tiempos:
extremos = zeros(n)
tiempos = zeros(n)
# Ahora vamos explorando los archivos uno a uno y rellenando datos
# Necesitaremos el módulo `DelimitedFiles` para poder leer los archivos
using DelimitedFiles
for i=1:n
    rutaarchivo = joinpath(directorio,archivos[i])
    # Leemos el contenido del archivo completo en la variable `datos`
    datos = readdlm(rutaarchivo)
    # Utilizamos `x` e `y` para extraer las dos columnas de datos
    x = datos[:,1]
    y = datos[:,2]
    # Buscamos el máximo absoluto de `y`
    (valor_maximo, indice_maximo) =  findmax(abs.(y))
    # Asignamos los datos que corresponden a los resultados
    tiempos[i] = x[indice_maximo]
    extremos[i] = valor_maximo
end
#=
Para terminar escribimos los datos en una matriz con tres columnas:
1: el nombre del archivo
2: el instante del extremo
3: el valor del extremos
=#
resultados = [archivos tiempos extremos]
```

Si tienes experiencia previa en programación, este código probablemente sea lo bastante intuitivo como para seguirlo sin más explicaciones que los comentarios incorporados. En caso contrario, lo mejor para entenderlo es ejecutarlo línea a línea y ver los resultados en una sesión interactiva de Julia.

La única parte en la que esto servirá de poca ayuda es en el fragmento indentado entre `for i=1:n` y `end`. Se trata de un "bucle `for`", que sirve para repetir ese fragmento de código múltiples veces (una por cada uno de los archivos de datos). Todo ese código se trata en bloque, como si fuera una gran instrucción, y no se pueden examinar los valores intermedios. (Véase la sección del siguiente capítulo sobre [bucles](3-funciones-control.md#Bucles-1) para más detalles.)

Una forma de ver lo que pasa es sustituir la línea `for i=1:n` por `i = 1`, y eliminar la línea con `end`. Esto será como ejecutar únicamente la primera iteración del bucle (la correspondiente al primer archivo), pudiéndolo hacer paso a paso, como el resto del código.

## Números escalares y series de números

Cuando se habla de "datos" o "variables", lo más inmediato es pensar en números, que son también el tipo de datos con los que es más sencillo trabajar en la mayoría de lenguajes de programación, incluyendo Julia.[^1] Incluso para los principantes generalmente no hace falta dar demasiadas explicaciones sobre cómo programar operaciones con variables numéricas: los nombres de las funciones y la sintaxis de las operaciones numéricas son iguales que en muchos otros lenguajes de programación, y en esencia son una transposición a texto simple de las fórmulas matemáticas que se desean implementar. Por ejemplo, para sumar los logartimos de las variables `a` y `b`, y asignar el resultado a la variable `x`, se escribe `x = log(a) + log(b)`, etc.

En Julia, la capacidad de escribir código imitando fórmulas matemáticas se lleva incluso más lejos que en otros lenguajes; por ejemplo:

* Si `a` es el nombre de una variable, `2a` significa "2 veces `a`" (y lo mismo con cualquier otro número, sea entero, decimal o de otro tipo). Esto es posible gracias a que los nombres de variables no pueden comenzar por números, por lo que no hay ambigüedad posible. En otros lenguajes es obligatorio expresarlo como un producto explícito, es decir `2*a`.
* Se pueden utilizar símbolos matemáticos de Unicode para representar algunos operadores matemáticos habituales que no están en el conjunto de caracteres ASCII: `≠` para "no es igual que" (equivalente a `!=` cuando se escribe solo con ASCII), o `≤` y `≥` para "menor que" y "mayor que", respectivamente (equivalentes a `<=`, `>=`). Como dichos símbolos no suelen estar disponibles en los teclados, los principales interfaces para Julia permiten escribirlos a partir de "secuencias de escapes". Por ejemplo, el símbolo de "no es igual" (`≠`) se escribiría con la secuencia de escape `\neq` (del inglés *not equal*), pulsando el tabulador a continuación para convertirla en el símbolo deseado. En la documentación oficial de Julia se puede encontrar una lista completa de las secuencias de escape disponibles para [caracteres Unicode](https://docs.julialang.org/en/v1/manual/unicode-input).
* Es posible escribir comparaciones lógicas concatenadas, como `0 ≤ x ≤ 1` para comprobar si la variable `x` se encuentra entre `0` y `1`. (En otros lenguajes es necesario expresarlo de forma más compleja, como `(0 <= x) && (x <= 1)`.

[^1]: Los números son también el "vocabulario natural" de los ordenadores. Toda la información procesada en un programa informático se representa en última instancia mediante números, en particular como números binarios, y se manipula mediante operaciones matemáticas.  

Por otro lado, con mucha frecuencia las variables con las que interesa trabajar no representan números escalares, sino series organizadas de números. Esto ocurre con las siguientes variables del ejemplo anterior:

* `datos`: matrices de 100×2 que contienen los datos numéricos leídos directamente de los archivos.
* `x`, `y`: vectores de 100 números con cada una de las dos columnas de `datos`.
* `tiempos` y `extremos`: vectores de `n` elementos (30) que contienen los resultados que buscamos para cada uno de los archivos.

En Julia los vectores y matrices (junto con las "hipermatrices" de más de dos dimensiones) son casos específicos de *arrays*, que se pueden definir en general como conjuntos de datos ordenados (numéricos o también de otros tipos, como veremos después). Su manejo es un tema extenso, que se trata de forma más detallada en el [capítulo 5](5-arrays.md). Por ahora, como introducción solo veremos superficialmente los vectores (*arrays* unidimensionales). En el ejemplo hemos leído los datos a partir de archivos grabados en disco, como es habitual, pero un vector también se puede definir "a mano" a partir del conjunto de datos que contiene, encerrados entre corchetes y separados por comas:

```@repl c2
primos = [1,3,5,7,11,13,17];
```

Es posible extraer un valor concreto del vector, utilizando también los corchetes para señalar el "índice" que se quiere tomar. Estos índices pueden ser números enteros, o las palabras clave `begin` y `end` para referirse al primer o al último elemento, respectivamente:

```@repl c2
primos[3]
primos[1] # cambiar a begin
primos[end]
primos[end-1]
```

!!! note

    El uso de `begin` como índice para referirse al primer elemento no funciona en versiones anteriores a Julia 1.4.

En el programa para analizar las señales del ejemplo, vemos el uso de los corchetes para referirse a elementos particulares de un vector en líneas como las siguientes:

```julia
tiempos[i] = x[indice_maximo]
extremos[i] = valor_maximo
```

Así, por ejemplo, la expresión `x[indice_maximo]` sirve para extraer el valor del vector de tiempos (`x`) en el punto donde se da el valor extremo de la señal (`indice_maximo` se obtiene a través de la función `findmax`, aplicada al vector con los valores absolutos de `y`).

También vemos que cuando estas expresiones se ponen a la izquierda del símbolo `=` lo que se hace no es "leer" un valor del vector, sino asignarle el valor calculado en la parte derecha de la ecuación, como ocurre con `tiempos[i] = ...` y `extremos[i] = ...`. A la hora de modificar un vector hay que tener en cuenta dos restricciones importantes: solo se pueden incorporar datos del mismo tipo que el vector original, y no se puede "rebasar" el tamaño del vector original. Por ejemplo:

```jldoctest c2
julia> numeros = [1,2,3,4,5,6];

julia> numeros[1] = 0   # Esto no es problema
0

julia> numeros[1] = 0.5 # Pero esto sí, porque eran números enteros
ERROR: InexactError: Int64(0.5)
[...]

julia> numeros[7] = 10  # Esto también, porque el vector solo tenía 6 elementos
ERROR: BoundsError: attempt to access 6-element Array{Int64,1} at index [7]
```

La lectura y asignación de valores se puede hacer elemento a elemento, o también sobre varios elementos a la vez, utilizando un "vector de índices" para referirse a los elementos de interés. Para abreviar, un rango de índices correlativos se puede expresar como `a:b`, que significa "desde `a` hasta `b`.

Por ejemplo, estas son dos formas alternativas para extraer los tres primeros números del vector `primos`:

```@repl c2
primos[ [1,2,3] ]
primos[1:3]
```

Para referirse a "todos los elementos" puede utilizarse el rango `begin:end` (es decir, "desde el primero hasta el final"), o de forma abreviada los dos puntos sin más (`:`). Esto se emplea a menudo cuando se trabaja con matrices, para referirse a "todas las filas" o "todas las columnas". Aunque las operaciones con matrices las veremos con más detalle en el capítulo 5, en el ejemplo anterior ya podemos observar esto, en las líneas donde se extraen las dos columnas de la matriz `datos`. Por ejemplo, `x = datos[:,1]` expresa que a la variable `x` le asignamos "todas las filas de la primera columna" de `datos`.

Finalmente, también se puede aplicar una misma operación a todos los elementos de un *array* a la vez. Podemos ver un ejemplo de esto en la línea donde se busca el valor extremo de la señal:

```julia
(valor_maximo, indice_maximo) =  findmax(abs.(y))
```

La función `abs` calcula el valor absoluto de un número. Pero en este caso queremos calcular el valor absoluto de *todos* los valores de `y`, que se pasan en forma de otro vector a la función `findmax` para extraer el máximo de ellos. Para hacer este cálculo "elemento a elemento" (lo que se conoce como *vectorizar el código*), se ha añadido un punto tras el nombre de la función `abs`.

Esta sintaxis no vale solo para las funciones, sino también para los operadores como la suma (`+`), multiplicación (`*`), etc., e incluso para la asignación (`=`), aunque en estos casos el punto se añade antes del símbolo.

Por ejemplo, si `x` e `y` fuesen las coordenadas de un vector, el módulo de ese vector se podría calcular con la expresión `sqrt.(x.^2 + y.^2)`; y si tuviéramos otro vector `m` de la longitud adecuada, este resultado podría asignarse a ese vector --sin tener que crear otro nuevo--, del siguiente modo:

```julia
m .= sqrt.(x.^2 + y.^2)
```

Como regla general, al vectorizar una operación todas las variables empleadas han de tener el mismo tamaño, pero estas variables también pueden combinarse con números escalares. En ese caso los números escalares operan por igual sobre todos los elementos de los otros vectores, como si se "expandieran" a vectores de la misma longitud con valores repetidos (lo que se conoce como *broadcasting*). Esto es lo que ocurre cuando `x` e `y` se elevan al cuadrado como `x.^2`, `y.^2` (usando un solo `2` escalar, en lugar de un vector). Esta forma de operar con vectores y matrices se explica con más detalle en la sección de [Broadcasting](@ref) del capítulo 5.

## Cadenas de texto y símbolos

Julia es un lenguaje pensado especialmente para trabajar con números, pero también tiene múltiples herramientas para manejar cadenas de texto (*strings*), que son un tipo importante de datos en muchas aplicaciones. De hecho, en casi cualquier programa es necesario hacer algún tratamiento de textos, aunque solo sea para definir las rutas de los archivos de entrada o salida. Así pues, aunque las cadenas de texto se trata con más profundidad en el [capítulo 7](7-strings.md), aquí introduciremos algunos conceptos fundamentales para empezar a trabajar con este tipo de variables. 

Las cadenas de texto son un tipo de datos más, que al igual que los números pueden organizarse en *arrays*; así, los nombres de los 30 archivos tratados en el ejemplo anterior se agrupan en el vector de *strings* llamado `archivos`, de tal modo que el nombre del primer archivo es `archivos[1]`, etc.

Las cadenas de texto son secuencias de letras que se presentan delimitadas por comillas dobles (`"`). En parte se pueden comparar a vectores de letras, ya que es posible extraer letras aisladas o partes del texto con la misma sintaxis que se utiliza con los *arrays*. Por ejemplo, supongamos que queremos extraer el nombre del archivo sin la extensión `.txt` del archivo que está en la posición `i` de la lista. Se trata de una operación que ya está programada en la función `splitext`; pero como la extensión que queremos eliminar tiene cuatro letras, se podría asignar el nombre sin extensión a la variable `sinextension` del siguiente modo:

```@setup c2
archivos = ["sA01.txt"]
```

```@repl c2
i = 1;
nombrearchivo = archivos[i]
sinextension = nombrearchivo[1:end-4]
# O en una sola línea:
sinextension = archivos[i][1:end-4]
```

Si extraemos una sola letra, como el carácter `A` o `B` que aparece en segunda posición del nombre archivo, podemos ver cómo las letras individuales se delimitan con comillas simples (`'`), en lugar de las dobles usadas para las cadenas de texto:

```@repl c2
letra = nombrearchivo[2]
```

!!! note

    Esta forma de extraer partes de una cadena de texto solo funciona de forma general con textos compuestos exclusivamente de caracteres ASCII. En el [capítulo 7](7-strings.md) se explica cómo operar con cadenas que incluyen otro tipo de caracteres.

Sin embargo, al contrario que los *arrays* convencionales, las cadenas de texto son objetos "inmutables", y no es posible modificar sus letras de la misma manera que haríamos con los contenidos de un vector:

```jldoctest c2; setup = :(nombrearchivo = "sA01.txt")
julia> nombrearchivo[2] = 'C'
ERROR: MethodError: no method matching setindex!(::String, ::Char, ::Int64)
```

Lo que sí se puede hacer es crear una nueva cadena de texto a partir de trozos de otras, concatenándolas con el símbolo de la multiplicación (`*`). La transformación que se intentaba hacer en el ejemplo anterior, reemplazando la segunda letra de `"sA01"` por una `'C'`, podría conseguirse del siguiente modo:

```@repl c2
nombrearchivo[1] * 'C' * nombrearchivo[3:end]
```

Hay muchos otros métodos y funciones para manipular cadenas de texto, las más importantes de las cuales se comentan en el capítulo dedicado a este tema. Pero hay otra forma de componer cadenas de texto que es especialmente práctica y vale la pena adelantar: la "interpolación". Dada una variable `x`, sea numérica, de texto o cualquier otro tipo, su contenido puede insertarse dentro de un texto utilizando el signo del dólar (`$`) para marcarla. También se puede interpolar una expresión más compleja encerrándola entre paréntesis:

```@repl c2
x = 2;
txt1 = "uno más uno es igual a $x"
txt2 = "y $x al cuadrado es $(x^2)"
```

El uso de `$` para interpolar datos en una cadena de texto impide que se pueda escribir tal cual, si lo que queremos es incluir ese signo en el texto. Para este y otros casos se utilizan "secuencias de escape", que generalmente comienzan con una barra invertida (`\`). Las secuencias de escape más útiles son:

  * `\$` para el signo del dólar.
  * `\\` para la barra invertida.[^2]
  * `\"` para las comillas dobles.
  * `\t` para el tabulador.
  * `\n` para el carácter de nueva línea.
  * `\r` para el carácter de "retorno de carro" (normalmente combinado como `\r\n` para definir una nueva línea en Windows).

Por ejemplo, para escribir la cadena de texto `"El símbolo del dólar es "$""` tendría utilizarse el código: `"El símbolo del dólar es \"\$\""`.

[^2]: El hecho de que la barra invertida sea el marcador de las secuencias de escape es lo que complica escribir rutas de archivos en Windows, que utiliza precisamente ese símbolo como separador de directorios. Por eso los nombres de rutas de Windows se escriben con barras invertidas dobles (`\\`), que en realidad representan una sola barra invertida.

Finalmente haremos mención a un tipo especial de cadenas de texto, los *símbolos*: se trata de secuencias de caracteres alfanuméricos o signos que pueden representar nombres de variables, funciones u operadores, que se escriben precediéndolas de dos puntos (`:`) para distinguirlas de cadenas de texto convencionales. Los símbolos pueden referirse a operaciones o variables existentes como `:+`, `:log`, `:include`, o también inexistentes. Están particularmente pensados para procesos de metaprogramación, es decir para manipular y crear código programáticamente, que es una forma de uso particularmente avanzado de Julia, que no se trata en esta guía. Pero incluso en el uso cotidiano nos encontraremos de vez en cuando con este tipo de símbolos, como veremos a continuación, y por eso vale la pena introducirlos ahora.

## Matrices de datos

Además de los vectores (*arrays* unidimensionales), otra forma habitual de estructurar los datos es en forma de matrices (*arrays* de dos dimensiones, con filas y columnas), como las matrices numéricas que en el ejemplo se asignan a la variable `datos`, así como la matriz que se genera al final, `resultados`, que contiene los siguientes valores:

```@example c2
resultados # hide
```

Esta matriz no es puramente numérica ni de cadenas de texto, sino que combina ambos tipos de datos, usando un "supertipo" llamado `Any` que engloba todo tipo de objetos definidos en Julia.

A menudo, como ocurre con los datos de entrada en el ejemplo anterior, estas matrices se crean leyendo archivos de texto. La forma más directa de hacerlo es mediante la función `readdlm` del módulo estándar `DelimitedFiles`, que en principio interpreta el archivo como una matriz en la que cada línea de texto representa una fila de datos, con columnas delimitadas por uno o más caracteres de separación (espacios en blanco o tabuladores). Los espacios dentro de las cadenas de texto no se interpretan por defecto como separadores si el archivo enmarca dichas cadenas entre comillas dobles.

Esta especificación general puede crear ambigüedades y problemas a la hora de leer ciertas matrices. Podríamos tener una matriz con columnas separadas por comas en lugar de espacios, o bien cadenas de texto con espacios que no habrían de interpretarse como separadores de columnas  (por ejemplo en una columna de nombres de países, que podría incluir algunos como "Estados Unidos"). Para evitar estos problemas se puede añadir un segundo argumento a la función, con el carácter que se utiliza como separador de columnas. Por ejemplo, si queremos especificar que las columnas del archivo `ejemplo.txt` están separadas específicamente por tabuladores o por comas:

```julia
matriz = readdlm("ejemplo.txt", '\t')   # Separada por tabuladores
matriz = readdlm("ejemplo.txt", ',')    # Separada por comas
```

También se puede especificar, seguido del carácter de separación, otro argumento que indique el carácter que marca el fin de línea --que puede diferir entre sistemas operativos, aunque esto no suele ser tan problemático--.

La función `readdlm` también admite muchos otros argumentos opcionales para controlar cómo se interpreta el texto, que vienen explicados en su documentación. Hay dos de ellos, `skipstart` y `header`, que son particularmente útiles cuando el archivo contiene un encabezado, que a menudo incorpora los nombres de las columnas.

Por ejemplo consideremos una pequeña tabla con los datos de esperanza de vida en los países del mundo clasificados por continente y género, que tenemos en el archivo `"esperanzadevida.txt"` (valores calculados a partir de los datos de las Naciones Unidas en 2017):[^3]

```
continente     género   media  desv_tip
África         Todos    60.23  7.25
África         Hombres  58.58  6.91
África         Mujeres  61.90  7.71
Asia           Todos    71.82  5.34
Asia           Hombres  69.95  5.41
Asia           Mujeres  73.79  5.54
Europa         Todos    77.22  3.61
Europa         Hombres  73.66  4.55
Europa         Mujeres  80.70  2.81
Latinoamérica  Todos    74.65  3.70
Latinoamérica  Hombres  71.38  3.85
Latinoamérica  Mujeres  77.96  4.11
Norteamérica   Todos    79.17  2.05
Norteamérica   Hombres  76.79  2.28
Norteamérica   Mujeres  81.50  1.79
Oceanía        Todos    77.92  6.33
Oceanía        Hombres  75.70  5.66
Oceanía        Mujeres  80.20  5.55
```

[^3]: Para practicar, este y otros archivos de datos también se encuentran en el repositorio de esta guía ([https://github.com/heliosdrm/guia-julialang/](https://github.com/heliosdrm/guia-julialang/)).

Podríamos ignorar la primera línea o extraerla como un vector de nombres, usando una de estas dos opciones:

```julia
# Para ignorar la primera línea especificamos `skipstart=1`
datos_un = readdlm("datos/esperanzadevida.txt", skipstart=1)
# Para guardar la primera línea como un vector de nombres: `header=true`
(datos_un, nombres) = readdlm("datos/esperanzadevida.txt", header=true)
```

Ambos argumentos se pueden combinar, si el encabezado contiene más líneas con otro tipo de información. En este caso `skipstart` indicaría el número de líneas a ignorar antes de leer los nombres de las columnas. Ambos son "argumentos con nombre" o "con clave" (en inglés *keyword arguments*), que pueden ponerse en cualquier orden después de los argumentos principales, pero tienen que ser llamados por su nombre para evitar confusiones. Por ejemplo, si hay dos líneas de texto con "metadatos" antes de la fila de nombres:

```julia
# Todas estas expresiones son equivalentes
(datos_un, nombres) = readdlm("datos/esperanzadevida.txt", skipstart=2, header=true)
(datos_un, nombres) = readdlm("datos/esperanzadevida.txt", header=true, skipstart=2)
(datos_un, nombres) = readdlm("datos/esperanzadevida.txt", '\t', skipstart=2, header=true)
```

Las matrices también pueden construirse "a mano" a partir de un conjunto de datos, de forma semejante a como se hace con los vectores. Si un vector se define escribiendo la serie de valores entre corchetes, separados por comas, las columnas de una matriz se pueden concatenar separándolas entre espacios, como se hace en la última línea del ejemplo al inicio del capítulo:

```julia
resultados = [archivos tiempos extremos]
```

Asimismo, se pueden concatenar valores por filas separándolas por puntos y comas. Por ejemplo los datos de África de la tabla de esperanzas de vida anterior (dejando de lado los nombres de las variables y la columna con el nombre del continente) se podría escribir del siguiente modo:

```@repl c2
datos_africa =["Todos" 60.23 7.25; "Hombres" 58.58 6.91; "Mujeres" 61.9 7.71]
```

Como ya se ha visto antes, la forma de acceder a un elemento o una submatriz para leer o modificar sus valores es una generalización de lo que se hace con los vectores. Los elementos a los que se quiere acceder se indican por su posición en la matriz, que viene dada por las filas y columnas correspondientes (separadas por una coma).

Por ejemplo, a continuación se indica cómo se podría calcular la esperanza de vida media de los ciudadanos europeos, o la máxima esperanza de vida --teniendo en cuenta que los datos de esperanza de vida están en la columna 3--:

```@setup c2
using DelimitedFiles
datos_un = readdlm("datos/esperanzadevida.txt", skipstart=1)
```

```@repl c2
vida_europeo_medio = datos_un[7,3] # fila 7
maxima_esperanza = maximum(datos_un[:,3])
```

## *Data frames* (tablas de datos)

En términos coloquiales se puede usar indistintamente el término "matriz" y el de "tabla" de datos, como ocasionalmente hemos hecho en la sección anterior, para hablar de conjuntos de números, cadenas de texto u otro tipo de variables dispuestos en una estructura regular de filas y columnas. Pero en términos más formales, todos los ejemplos que hemos visto hasta ahora son *arrays* de dos dimensiones, aunque por abreviar también se les da el nombre de matrices. El término de "tabla de datos" (*data frame* en inglés) se reserva para unas estructuras más sofisticadas que vienen definidas en el paquete [DataFrames](http://juliadata.github.io/DataFrames.jl/stable/), y que se pueden leer y guardar en archivos de texto a través del paquete [CSV](https://juliadata.github.io/CSV.jl/stable/), entre otros.[^4]

[^4]: Las versiones de los paquetes empleados son DataFrames v0.22 y CSV 0.8.

Una tabla de datos es parecida a una matriz; también se puede leer a partir de un archivo de texto mediante la función `CSV.File`, al igual que hacíamos con `readdlm` para las matrices, con algunas diferencias entre las cuales podemos destacar las siguientes:

* La primera línea se interpreta por defecto como la lista de nombres de las columnas. Al leer el archivo estos nombres se incorporan a la propia tabla, en lugar de devolverse como una variable aparte.

* El carácter de separación entre columnas considerado por defecto por `CSV.File` es una coma; para especificar un carácter de separación distinto se utiliza el argumento con nombre `delim`. Si las columnas están separadas por más de un espacio en blanco, hay que añadir también el argumento `ignorerepeated=true`.

* Si el tipo de datos (números decimales, enteros, cadenas de texto...) es consistente en cada columna del archivo de entrada, dichos tipos se mantienen en las distintas columnas de la tabla resultante, mientras que `readdlm` crearía una matriz homogénea de tipo `Any`.

* Las columnas pueden contener valores perdidos (`missing`), que por defecto se representan mediante posiciones "vacías" (dos delimitadores seguidos). Los argumentos `missingstrings` y `allowmissing` se pueden usar para personalizar cómo se interpretan y gestionan dichos valores perdidos.

Podemos ver cómo los nombres de las columnas están incorporados en la tabla leyendo el archivo "esperanzadevida.txt" como sigue (el resultado de `CSV.File` se pasa a un `DataFrame` para visualizarlo y manejarlo mejor):

```julia-repl
julia> using CSV, DataFrames

julia> tabla_un = DataFrame(CSV.File("datos/esperanzadevida.txt", delim=' ', ignorerepeated=true))
18×4 DataFrame
│ Row │ continente    │ género  │ media   │ desv_tip │
│     │ String        │ String  │ Float64 │ Float64  │
├─────┼───────────────┼─────────┼─────────┼──────────┤
│ 1   │ África        │ Todos   │ 60.23   │ 7.25     │
│ 2   │ África        │ Hombres │ 58.58   │ 6.91     │
│ 3   │ África        │ Mujeres │ 61.9    │ 7.71     │
│ 4   │ Asia          │ Todos   │ 71.82   │ 5.34     │
│ 5   │ Asia          │ Hombres │ 69.95   │ 5.41     │
│ 6   │ Asia          │ Mujeres │ 73.79   │ 5.54     │
│ 7   │ Europa        │ Todos   │ 77.22   │ 3.61     │
⋮
│ 11  │ Latinoamérica │ Hombres │ 71.38   │ 3.85     │
│ 12  │ Latinoamérica │ Mujeres │ 77.96   │ 4.11     │
│ 13  │ Norteamérica  │ Todos   │ 79.17   │ 2.05     │
│ 14  │ Norteamérica  │ Hombres │ 76.79   │ 2.28     │
│ 15  │ Norteamérica  │ Mujeres │ 81.5    │ 1.79     │
│ 16  │ Oceanía       │ Todos   │ 77.92   │ 6.33     │
│ 17  │ Oceanía       │ Hombres │ 75.7    │ 5.66     │
│ 18  │ Oceanía       │ Mujeres │ 80.2    │ 5.55     │
```

Además, tal como se ha señalado, el país o el género son series de cadenas de texto (datos de tipo `String`) mientras que los datos numéricos son números decimales (`Float64`). Se puede hacer referencia a las distintas columnas por su posición en la tabla al igual que en las matrices, pero también por sus nombres):

```@setup c2
using CSV, DataFrames
tabla_un = CSV.File("datos/esperanzadevida.txt", delim=' ', ignorerepeated=true) |> DataFrame
```
```@repl c2
tabla_un[:, "media"]   # Equivale a ... tabla_un[:,3]
```

!!! tip "Acceso a columnas completas de los `DataFrames`"

    Para acceder a las columnas completas se puede utilizar la sintaxis `tabla_un[!, "media"]`, con una exclamación en lugar de los dos puntos. La diferencia es que el resultado es el propio vector de datos que hay en la columna seleccionada de la tabla, en lugar de una copia del mismo, lo cual resulta más eficiente. Un efecto secundario es que las modificaciones que se hagan en el resultado se reflejarán en la tabla original.

Este tipo de tablas también se pueden crear a mano, con la función "constructora" `DataFrame` del paquete DataFrames. La forma normal de construir estas tablas es introduciendo los datos por columnas, a cada una de las cuales se le asigna un nombre. Por ejemplo, la última línea del ejemplo inicial de este capítulo podría haberse cambiado para crear una tabla de este tipo:

```julia
tabla_resultados = DataFrame(archivo=archivos, tiempo=tiempos, extremo=extremos)
```

## Guardar datos

Naturalmente, además de leer datos a partir de archivos de texto, normalmente también interesa *escribir* archivos con los resultados generados. Si estos resultados están en forma de matrices o vectores, se pueden guardar a través de la función `writedlm` de `DelimitedFiles`, que funciona de forma simétrica a `readdlm`. Por ejemplo, para guardar la matriz `resultados` creada en el primer ejemplo de este capítulo en el archivo "tabla.txt", usando el punto y coma como separador entre columnas:

```julia
writedlm("tabla.txt", resultados, ';')
```

Si solo se introduce el nombre del archivo y la matriz o vector de datos, por defecto `writedlm` separa las columnas con un carácter de tabulación. En el caso de tener una tabla del tipo `DataFrame`, se puede utilizar `CSV.write` para volcarla en un archivo de texto, empleando los mismos argumentos con nombre que emplea `CSV.File` para la lectura; por ejemplo:

```julia
CSV.write("tabla.txt", tabla_resultados; delim=';')
```

La diferencia más notable entre `writedlm` y `CSV.write`, además del tipo de tabla de entrada, es que `CSV.write` también escribe una primera línea con los nombres de las columnas. (Se puede omitir usando el argumento opcional `header=false`).

Guardar conjuntos de datos en archivos de texto es especialmente útil para emplearlos posteriormente, copiando la tabla en un informe, abriéndola con una hoja de cálculo, o importándola en cualquier otro programa. Pero para reutilizar los datos en una sesión de Julia posterior, también viene bien poder guardarlos en un archivo binario que conserve las propiedades de las variables originales. Paquetes como [BSON](https://github.com/JuliaIO/BSON.jl) o [JLD2](https://github.com/JuliaIO/JLD2.jl) contienen las utilidades necesarias para salvar y cargar datos de este tipo.[^5]

[^5]: Las versiones de los paquetes referidos son BSON v0.3 y JLD2 0.2.

Ambos paquetes proporcionan métodos semejantes para salvar y guardar datos. Por ejemplo, para salvar las variables `archivos` y `resultados`, en un archivo llamado "datos" -- y para cargarlas después a partir del archivo--, en ambos casos se podría escribir:

```julia
@save("datos", archivos, resultados) # para salvar
@load("datos", archivos, resultados) # para cargar
```

Normalmente al nombre del archivo se le añade una extensión según el tipo de archivo correspondiente. En el caso del paquete JLD2 esta extensión sería `jld2`, y en el de BSON sería `bson`. Ambos son tipos de archivo binarios, el primero específio para Julia y el segundo un estándar más genérico y robusto. Puede consultarse la documentación de estos paquetes para más detalles, y otras formas de guardar y cargar datos.


## Sumario del capítulo

En este capítulo hemos hecho una introducción a los siguientes aspectos de Julia, en los que se profundizará más en próximos capítulos:

* La forma de expresar operaciones algebraicas y comparaciones básicas en la sintaxis de Julia.
* El uso de *arrays*, en particular los vectores (*arrays* unidimensionales) y matrices (*arrays* bidimensionales), incluyendo:
    + Métodos para componer *arrays* a partir de datos numéricos.
    + Expresiones para identificar un rango de elementos, filas o columnas de un *array*.
    + Cómo extraer una sección de un *array* y modificar sus valores.
    + Las expresiones "con punto" para aplicar una operación a cada uno de los elementos de un *array*.
* El uso del módulo `DelimitedFiles` y los paquetes DataFrames y CSV para trabajar con datos tabulados.
* Fundamentos sobre las cadenas de texto (*strings*), letras aisladas (caracteres) y variables de tipo "símbolo".
* La concatenación y la interpolación de variables en cadenas de texto.
* Los paquetes BSON y JLD2 para salvar y recuperar las variables de una sesión de trabajo.
* El uso de funciones con argumentos identificados por un nombre o palabra clave.

Además podemos destacar el uso de las siguientes funciones:

* `findmax` para localizar el valor máximo de una variable.
* `length` para obtener la longitud de un *array* u otra estructura con múltiples datos.
* `readdir` para obener una lista de cadenas de texto con los nombres de los archivos de un directorio.
* `splitext` para separar la extensión de un nombre de archivo.
* `readdlm` y `CSV.File` (esta última del paquete CSV) para leer datos tabulados, más las correspondientes `writedlm` y `CSV.write` para escribirlos en un archivo de texto.
* `zeros` para crear un array lleno de ceros al inicio.
* `abs` para obtener el valor absoluto de un número.
* `sqrt` para calcular la raíz cuadrada de un número.
* La "macro" `@save` para salvar variables del espacio de trabajo actual en un fichero `bson` o `jld2`, y `@load` para la operación inversa.

```@setup c2
rm("datos", recursive=true) # hide
```
