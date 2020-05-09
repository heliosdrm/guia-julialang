# Capítulo 7. Cadenas y archivos de texto

Las cadenas de texto, conocidas en inglés como *strings*, son un tipo de variable con el que hay que trabajar en casi cualquier proyecto, aunque sea simplemente porque son la forma habitual de identificar los archivos desde los que se leen los datos y en los que se guardan los resultados. Además, hay muchos casos en los que la información a procesar es de tipo textual.

Julia tiene numerosas herramientas y funciones para trabajar con cadenas de texto, de las cuales ya hemos usado algunas en capítulos anteriores, como la concatenación de cadenas, interpolación de variables, secuencias de escape, etc. En este capítulo vamos a ver más detalles sobre estas y otras utilidades más avanzadas para trabajar con cadenas de texto, transformarlas, extraer partes de ellas, etc.

## Representación textual de variables

Todas las variables en Julia tienen lo que se llama una "representación canónica", que es la forma más simple de mostrarla en forma de texto. En la mayoría de los casos es una forma semejante o igual a la que se ve cuando se muestra su valor en el REPL. Para cualquier variable `x`, la operación `string(x)` devuelve esta representación canónica en forma de cadena de texto.

Los números enteros son un caso especial, para el que la función `string` admite dos argumentos con nombre opcionales:

* `pad`: el número mínimo de dígitos que ha de ocupar la cadena de texto, añadiendo ceros a la izquierda si hace falta. P.ej. `string(1, pad=3)` crea la cadena de texto `"001"`.
* `base`: la base numérica en la que está expresado el número. Normalmente expresamos los números en base 10, y otras bases habituales son 2 (binaria) y 16 (hexadecimal). Pero este argumento permite cualquier base entre 2 y 62 (usando las cifras del 0 al 9, y las 26 letras del alfabeto ASCII en mayúsculas y minúsculas):

```@repl
string(3000, base=2)  # binario
string(3000, base=8)  # octal
string(3000, base=16) # hexadecimal (con letras `a-f`)
string(3000, base=36) # hexatrigesimal (con letras `a-z`)
string(3000, base=62) # duosexagesimal (con letras `A-Z` más `a-z`)
string(0xff, base=10) # decimal (independientemente del tipo de entero)
```

La operación inversa a `string` se realiza con `parse`, que requiere dos argumentos: primero el tipo de variable que se quiere crear, y luego la cadena de texto que la representa (evidentemente ha de ser una cadena interpretable como ese tipo de variable). En el caso de números enteros de cualquier tipo, también se puede añadir el argumento con nombre `base` para resolver amigüedades (por defecto se asume una base 10).

```@repl
parse(Float64, "30")      # número decimal
parse(Int, "30")          # número entero
parse(Int, "30", base=16) # número entero en notación hexadecimal
```

Cuando se representan números decimales en forma de texto, a veces se desea mostrar menos cifras decimales, sacrificando parte de la precisión para mejorar la legibilidad. Una manera de hacerlo es redondear o truncar el número con las funciones `round` o `trunc`, respectivamente, fijando la cantidad de cifras significativas con el argumento `sigdigits`:

```@repl c7
numero = exp(1)
string(round(numero, sigdigits=5))
string(trunc(numero, sigdigits=5))
```

Alternativamente, se puede emplear la "notación compacta" que se muestra en el REPL cuando el contexto requiere acortar los números decimales (por ejemplo, los números dentro de un vector):

```@repl c7
[numero, numero]
```

Así como la función `string` se usa para crear una cadena con la representación canónica de una variable, la forma exacta presentada en el REPL se puede obtener con la función `repr`. Y la notación compacta se puede forzar definiendo el contexto como `:compact=>true`: 

```@repl c7 
repr(numero, context=:compact=>true)
```

## Concatenación y separación de textos

Si a la función `string` se le pasa más de una variable, además de crear sus respectivas cadenas de texto, las concatena en una sola.:

```@repl
string("La raíz de 2 es ", sqrt(2))
```

El operador de interpolación de texto (`$`) sirve para hacer esto mismo de forma directa:

```@repl
"La raíz de 2 es $(sqrt(2))"
```

Las variables interpoladas siempre se añaden en su representación canónica por defecto. Los programadores con experiencia en C u otros lenguajes que usan la función [`printf`](http://www.cplusplus.com/reference/cstdio/printf/), pueden encontrar una alternativa interesante en la macro `@sprintf`, dentro del módulo `Printf`:

```@repl
using Printf
@sprintf("La raíz de 2 es %0.3f", sqrt(2))
```

La concatenación de cadenas de texto también se puede llevar a cabo usando el operador de la multiplicación (e.g. `"a" * "b"` para obtener `"ab"`). Y para repetir una cadena de texto varias veces se puede utilizar la función `repeat`, que siguiendo la analogía matemática también se puede expresar como una potencia por un número entero:

```@repl
repeat("Abc", 3)
"Abc"^3
```

Por otro lado, para unir un conjunto de cadenas de texto con un separador común se puede usar la función `join`, que también admite un separador especial para el último elemento a unir:

```@repl c7
frase = join(["bueno", "bonito", "barato"], ", ", " y ")
```

La operación inversa (dividir una cadena en un vector de cadenas teniendo en cuenta un texto de separación común) se realiza con la función `split`. Por defecto esta función utiliza cualquier carácter en blanco (espacios, tabuladores, cambios de línea...) como separador, pero se le puede pasar un separador de forma explícita como segundo argumento, a modo de cadena de texto, carácter o conjunto de caracteres:

```@repl c7
split(frase) # Separación por defecto
split(frase, (',', ' ')) # Por comas y espacios
```

Se puede observar que en este último caso se ha añadido una cadena vacía, porque después de `"bueno"` había dos caracteres de separación juntos. Para evitar esto se podría añadir el argumento con nombre `keepempty=false` (que está en ese modo por defecto cuando no se indica ningún separador explícito):

```@repl c7
split(frase, (',', ' '); keepempty=false) 
```

Un caso de uso muy habitual para unir y separar cadenas de texto en base a una serie de caracteres delimitadores es en el análisis y descomposición de rutas de archivos. Por este motivo hay un conjunto de variantes de `join` y `split` dedicadas a estas operaciones particulares:

* `joinpath` para juntar nombres de directorios y archivos.
* `splitdir` para dividir una ruta en nombre de directorio y nombre de archivo (se puede usar recursivamente sobre el nombre del directorio para separar el último nivel de los anteriores).
* `splitext` para separar la extensión de un nombre de archivo (la extensión incluye el punto separador).
* `splitdrive` para separar el nombre de unidad de disco de la ruta de un archivo (solo en sistemas Windows).


## Secuencias de escape

Las secuencias de escape son combinaciones de caracteres que se usan para representar otros caracteres distintos. Julia reconoce las [secuencias de escape de C](https://en.wikipedia.org/wiki/Escape_sequences_in_C#Table_of_escape_sequences) (e.g. `\n` para nueva línea, `\t` para tabulador, `\"` para las comillas...), y añade la secuencia `\$` para el símbolo del dólar --ya que `$` sin la barra invertida se usa como operador de interpolación--.

Cuando se presentan cadenas de texto en el REPL, estas se muestran con un formato que incluye las comillas que las delimitan y muestra las secuencias de escape literales. Las funciones `print` y `println` permiten ver su forma canónica, con las secuencias de escape transformadas en los caracteres que representan (`println` se diferencia en que añade una nueva línea al final). Por ejemplo:

```@repl
s = "A\tB\n\$c\$\t\"d\""
print(s)
```

En ocasiones se tiene un texto con los caracteres especiales que suelen representarse de esta manera (comillas, tabuladores, etc.), e interesa generar la cadena de texto que se utilizaría para escribirla en un fragmento de código, con secuencias de escape incluidas. Esto supondría, por ejemplo, sustituir las tabulaciones por la secuencia `\t` (una barra invertida seguida de la letra *t*). Esto se puede hacer con la función `escape_string`. La operación inversa se consigue con la función `unescape_string`:

```@repl
cadena = "texto\tseparado" # Aquí \t representa un tabulador
println(cadena)
cadena2 = escape_string(cadena) # Cambia el tabulador por la secuencia de escape
println(cadena2)
cadena == unescape_string(cadena2)
```

!!! note "`escape_string` vs. `repr`"

    La función `escape_string` convierte los caracteres especiales en sus secuencias de escape literales, pero lo que no hace es añadir las comillas que delimitan la cadena a la hora de escribirla. Si se quiere generar una cadena con el texto *exacto* que habría que escribir, se puede usar la función `repr` que se ha comentado antes.
    
Por otro lado, cuando se quiere escribir un texto que contiene varias barras invertidas (por ejemplo rutas de archivos en Windows) o símbolos del dólar, puede resultar engorroso añadir las barras "extra" que se necesitan para crear las secuencias de escape. Esto se puede evitar etiquetando las cadenas con el prefijo `raw`, como en el ejemplo que sigue:

```@repl
s = raw"C:\Windows\xxx.txt"
print(s)
```

## Textos "multilínea"

En los textos que se extienden a lo largo de varias líneas también se puede evitar ahorrar la escritura de la secuencia de escape `\n`. En su lugar se puede sencillamente introducir una nueva línea antes de cerrar las comillas:

```@repl
"Este es un texto
que ocupa dos líneas"
```

!!! note "Cambio de línea en Windows"

    Esta forma de introducir nuevas líneas solo inserta el carácter `\n`. En ciertos sistemas como Windows es habitual que la nueva línea se preceda del carácter de "retorno de carro" (`\r`). Para reproducir este comportamiento es necesario escribir la secuencia `\r` explícitamente.

Los textos multilínea a menudo se delimitan con triples comillas (`"""`), en lugar de una, tal como se vio en la definición del [Docstring](@ref) de las funciones. Delimitar las cadenas de texto con triples comillas tiene dos ventajas:

* Se pueden escribir comillas simples dentro de la cadena de texto sin utilizar la secuencia de escape `\"`.
* Se ignora el indentado inicial común a todas las líneas (excluyendo la que contiene las comillas de apertura y las líneas vacías).

Por ejemplo:

```@repl
texto = """
        Curiosidades matemáticas:
           El resultado de "56^2-45^2" es $(56^2-45^2),
           El resultado de "556^2-445^2" es $(556^2-445^2),
           etc.
        """;
print(texto)
```

Como se puede apreciar, aunque al definir la variable `texto` hemos introducido múltiples espacios al principio de cada línea para hacer el código más limpio y legible, la cadena resultante no tiene ningún espacio en la primera línea (`"Curiosidades matemáticas"`), y solo tiene tres espacios en las demás. Estos tres espacios son el indentado "extra" que tienen las líneas siguientes respecto al conjunto de líneas completo.

También se puede ver que la primera línea, al no contener nada más que las comillas de apertura, se ignora a todos los efectos. La línea con las comillas de cierre sí se tiene en cuenta, aunque en este caso no contiene texto.


## Modificación de cadenas

En las secciones anteriores hemos visto cómo crear cadenas de texto, juntarlas y separarlas, pero hay muchas otras transformaciones habituales que vamos a ver en esta sección con diversos ejemplos. Las cadenas de texto son un tipo de variable inmutable, por lo que estas operaciones realmente no *transforman* las cadenas originales, sino que sirven para crear otras nuevas a partir de las originales.

### Cambios de mayúsculas a minúsculas

```@repl
uppercase("convertir en mayúsculas")
lowercase("CONVERTIR EN MINÚSCULAS")
uppercasefirst("poner en mayúscula solo la primera letra")
lowercasefirst("Lo mismo, pero ponerla en minúscula")
titlecase("poner en mayúscula la primera letra de cada palabra")
```

### Modificación de caracteres de espacio

```@repl
chomp("Elimina el carácter de cambio de línea final\n")
lpad("Alarga con espacios a la izquierda", 40)
rpad("Alarga con espacios derecha", 40)
strip("\t  Elimina espacios iniciales y finales   ")
lstrip("   Elimina solo los iniciales   ")
rstrip("   Elimina solo los finales     ")
```

### Edición de inicio y final de cadena

```@repl
first("Extrae los primeros caracteres", 11)
last("Extrae los últimos", 11)
chop("Elimina el último carácter")
chop("Elimina también algunos del principio"; head=8)
chop("Elimina más del final"; tail=4)
strip("{Elimina los caracteres especificados}", ('{', '}'))
```

(También `lstrip` y `rstrip` para limitar la eliminación al principio o el final de la cadena, respectivamente.)


## "Subindexar" cadenas de texto

Las cadenas de texto están formadas por series ordenada de caracteres, que pueden ser letras, cifras y otros códigos de texto. De hecho, una cadena de texto puede recomponerse como un vector de caracteres, al igual que cualquier otro objeto iterable, mediante la función `collect` -- y también se podría iterar a través de los caracteres con un bucle `for`, etc.--:

```@repl c7
cadena = "palabra";
letras = collect(cadena)
```

Cuando la cadena está formada exclusivamente por caracteres del [conjunto básico de ASCII](http://www.asciitable.com/), se puede extraer un fragmento de la misma subindexándola por el rango de posiciones de los caracteres deseados, igual que como se haría con un vector de números:

```@repl c7
cadena = "palabra";
cadena[1:3]  # Tres primeras letras
```

También se puede extraer un carácter particular de la cadena de texto señalando su posición:

```@repl c7
cadena[1]  # Primera letra
```

Pero un carácter no es lo mismo que una cadena de una sola letra. Para obtener esto último sería necesario definir un rango que solo tenga la posición deseada:

```@repl c7
cadena[1:1]
```

### Cadenas con caracteres Unicode

Julia permite trabajar con el conjunto completo de caracteres [Unicode](https://home.unicode.org/), diseñado para incluir los símbolos de todos los alfabetos del mundo. Distintos diseños de teclado (sobre todo dependiendo de su ámbito regional) proporcionan distintos subconjuntos de caracteres que pueden introducirse directamente. Y según el sistema operativo y el contexto en el que se esté programando (REPL, editor de código, etc.) se puede disponer de herramientas auxiliares para escribir conjuntos más amplios de caracteres. En particular, en el REPL de Julia y en otros entornos que usan sus mismas herramientas, se puede escribir el nombre del carácter como si fuera una secuencia de escape y pulsar el tabulador para convertirlo en el cáracter deseado. La lista de caracteres que se pueden escribir de esta manera y sus secuencias asociadas están publicadas en la sección ["Unicode Input" del manual de Julia](https://docs.julialang.org/en/v1/manual/unicode-input/).

Una cuestión a considerar cuando se usan caracteres que no pertenecen al rango US-ASCII o ASCII básico (los primeros 256 caracteres), es que hay dos formas de medir la longitud de las cadenas de texto:

* El número de caracteres, que viene dado por la función `length`.
* El número de "unidades de código", dado por la función `ncodeunits`.

Dependiendo de los caracteres empleados y la forma de codificarlos, estas dos longitudes pueden ser iguales o distintas. Por defecto Julia utiliza el sistema [UTF-8](https://es.wikipedia.org/wiki/UTF-8), por lo que en las cadenas formadas por caracteres ASCII la longitud es la misma (cada carácter ASCII ocupa solo una unidad de código):

```@repl
length("texto en ASCII")
ncodeunits("texto en ASCII")
```

Pero cuando se introducen otros caracteres (por ejemplo letras con acento, de otros alfabetos, etc.), el número de unidades de código se incrementa:

```@repl c7
texto = "código" 
length(texto)
ncodeunits(texto)
```

La unidad extra en este ejemplo viene dada por la letra acentuada `'ó'`.

Cuando se subindexa una cadena de texto, los índices empleados se refieren a las unidades de código, no a las letras. Por ejemplo, aunque "código" tiene 6 letras, si intentamos extraer los 6 primeros índices de la cadena, nos queda una palabra incompleta:

```@repl c7
texto[1:6]
```

Esto ocurre porque el segundo carácter (`'ó'`) abarca dos unidades de código: las que ocupan la segunda y tercera posición de la cadena. De hecho, en este caso no está permitido referirse al carácter ubicado en tercera posición, ni directa ni indirectamente:

```@repl c7
texto[3]
texto[end-4]
texto[1:3]
```

Si quisiéramos referirnos a la tercera letra desde el principio tenemos varias opciones. Una es utilizar la función `nextind`, de la siguiente manera:

```@repl c7
letra_3 = nextind(texto, 0, 3)
texto[1:letra_3]
```

La otra opción, que es interesante si se quieren localizar múltiples letras por posición, es utilizar la función `eachindex` para crear un iterador con todos los índices válidos, convertirlo en un vector, y usarlo como lista ordenada de índices:

```@repl c7
indices = collect(eachindex(texto))
texto[1:indices[3]]
```

La última letra está en la posición dada por el último índice, que también se puede obtener con la función `lastindex`. (En este caso `lastindex(texto)` coincide con `ncodeunits(texto)` porque la última letra tiene solo una unidad de código.)

```@repl c7
ultima = lastindex(texto)
```

Análogamente a `nextind`, la función `prevind` puede utilizarse para obtener la posición de un carácter contando "hacia atrás" desde el final o desde otra unidad de código.

```@repl c7
antepenultima = prevind(texto, ultima, 2)
texto[antepenultima:end]
```

(El subíndice `end` siempre se refiere a la última posición válida para un carácter.)

Para asegurarse de que cuando se subindexa una cadena con caracteres no ASCII siempre se utilizan posiciones válidas, se puede usar la función `isvalid(texto, posicion)`. De todos modos, estas precauciones son solo necesarias cuando se quiere localizar una letra según el lugar que ocupa en el texto. Cuando se itera a lo largo del texto, por ejemplo con un bucle `for`, las iteraciones van carácter por carácter, independientemente del número de unidades de código que ocupen. Y las funciones de búsqueda que se verán después siempre devuelven la posición de la unidad de código corecta.

!!! tip

    En los ejemplos anteriores nos hemos centrado en fragmentos del comienzo y el final de los textos, por sencillez. En estos casos particulares se podrían usar las funciones `first` y `last`, que cuentan caracteres en lugar de unidades de código. 

## Buscar y reemplazar

A menudo, el fragmento de una cadena sobre el que se quiere trabajar no está determinado por unas posiciones fijas (p.ej. el comienzo, final, o el carácter número *X*), sino por ciertos patrones (caracteres delimitadores, secuencias de letras o cifras concretas, etc.). Hay distintas funciones que sirven para buscar los índices que se corresponden con unos patrones dados:

* `findfirst(fragmento, cadena)` devuelve el primer rango de posiciones en `cadena` donde se encuentra `fragmento`.
* `findlast(fragmento, cadena)` devuelve el último rango de posiciones en `cadena` donde se encuentra `fragmento`.

Por ejemplo, en la cadena `"limón, pera, limones, peras"`, el fragmento `pera` (de cuatro letras) aparece dos veces. La primera es tras los primeros 7 caracteres, pero como uno de ellos es una letra acentuada, cuentan como 8 unidades de código; es decir, que el rango de posiciones ocupado es entre 9 y 12. La segunda vez ocurre despueś de los primeros 22 caracteres (23 unidades de código), ocupando el rango entre 24 y 27:

```@repl
findfirst("pera", "limón, pera, limones, peras")
findlast("pera", "limón, pera, limones, peras")
```

Por otro lado, la función `findnext` busca la primera coincidencia a partir de un determinado índice, y `findprev` la última hasta él:

```@repl
findnext("pera", "limón, pera, limones, peras", 20)
findprev("pera", "limón, pera, limones, peras", 20)
``` 

!!! tip

    Las funciones `findfirst`, `findlast`, `findnext` y `findprev` también sirven para buscar la posición de valores lógicos positivos (`true`) en colecciones indexables por posición, como *arrays* y tuplas formadas por elementos de tipo `Bool`.

Si el fragmento a buscar no está presente en la cadena, estas funciones no devuelven ningún valor --técnicamente, devuelven un `nothing`--. Si el resultado se quiere utilizar para subindexar la cadena, esto podría dar lugar a un error. Una forma de evitar este tipo de errores es comprobar la naturaleza valor resultante (p.ej. `x == nothing`). Alternativamente, se puede verificar con anterioridad si el fragmento está presente en la cadena, con la función `occursin`:

```@repl
occursin("pera", "limón, pera, limones, peras")
occursin("manzana", "limón, pera, limones, peras")
```

Otras funciones semejantes que pueden ser de utilidad son `startswith` y `endswith`, para comprobar si la cadena comienza o termina por el fragmento dado, respectivamente.

Una operación muy habitual con las cadenas de texto consiste en reemplazar el texto buscado por otro. Esto se podría hacer combinando la búsqueda de índices y las operaciones de composición o interpolación. Por ejemplo, si queremos sustituir las peras por manzanas en la lista de frutas:

```@repl c7
s = "limón, pera, limones, peras"
indices = findfirst("pera", s)
s2 = s[1:indices[1]-1] * "manzana" * s[indices[end]+1:end]
```

Sin embargo esto es relativamente farragoso, y solo hemos reemplazado la primera aparición del patrón. La función `replace` permite hacer la sustitución de forma más directa en todas las apariciones, aunque si se quiere limitar a un número máximo se puede hacer con el argumento opcional `count`:

```@repl c7
replace(s, "pera"=>"manzana")
replace(s, "pera"=>"manzana", count=1)
```

Además, en lugar de un texto fijo el reemplazo puede venir dado por una función que transforme una cadena de texto en otra. Por ejemplo podríamos hacer que el texto buscado se presente en mayúsculas:

```@repl c7
replace(s, "pera"=>uppercase)
```

## Expresiones regulares

Los métodos de búsqueda que se han presentado son una forma sencilla de localizar patrones de texto fijos, pero en ocasiones puede interesar buscar patrones más genéricos, como podrían ser secuencias numéricas, direcciones de correo electrónico, textos delimitados por conjuntos variables de caracteres, etc. Para este tipo de búsquedas se pueden usar las [expresiones regulares](https://www.regular-expressions.info/).

Julia permite utilizar expresiones regulares en lugar de cadenas de texto fijas en las funciones `findfirst`, `findlast`, `findnext` y `findprev`, así como en otras funciones que se comentan a continuación. La sintaxis de las series regulares son algo que excede el propósito de esta guía, aunque hay libros y numerosos recursos online con explicaciones, tutoriales y ejemplos para diversos patrones. En Julia, las expresiones regulares se escriben como cadenas de texto precedidas con la etiqueta `r`.

A modo de ejemplo práctico, se presenta a continuación cómo se escribirían en Julia distintas expresiones regulares para encontrar patrones numéricos de complejidad creciente:

* Una cifra suelta: `r"\d"`
* Una secuencia de cifras de longitud fija (p.ej. 3 dígitos): `r"\d{3}"`.
* Una secuencia de cifras de longitud arbitraria: `r"\d+"`.
* Un número entero (con posible signo): `r"-?\d+"`.
* Un número decimal (con posible signo y con números a ambos lados del punto): `r"-?\d+\.\d+"`.
* Un número decimal (con signo y punto opcionales, posiblemente sin cifras a la izquierda del punto): `r"-?(?:(?:\d+(?:\.\d+)?)|\.\d+)"`.
* Un número decimal con posible notación exponencial: `r"-?(?:(?:\d+(?:\.\d+)?)|\.\d+)(?:[Ee]-?\d+)?"`.

Así, en el siguiente ejemplo buscamos el fragmento de texto ocupado por el primer número (entero) de la cadena:

```@repl
findfirst(r"-?\d+", "Peso: 80 kg")
```

Las expresiones regulares no son cadenas de texto normales, y no se pueden componer ni se pueden formar interpolando variables. Lo que sí se puede hacer es generar la expresión regular en forma de cadena de texto al uso, y luego transformarla en expresión regular con el constructor `Regex`. Ahora bien, al generar esas cadenas de texto habrá que tener en cuenta las secuencias de escape necesarias para las barras invertidas que se emplean tan a menudo en las expresiones regulares, así como el símbolo de dólar que se utiliza en algunas de ellas.

Para facilitar su composición se pueden utilizar las cadenas etiquetadas con `raw` que se han introducido antes. Por ejemplo, para encontrar una secuencia de dos números decimales separados por una coma y un número de caracteres de espacio (`\s`) arbitrario podríamos utilizar lo siguiente:

```@repl
regex_numero = raw"-?\d+\.\d+"  # Cadenas normales (con la etiqueta `raw`)
regex_completa = regex_numero * raw"\s*,\s*" * regex_numero
r = Regex(regex_completa)  # Expresión regular resultante
findfirst(r, "Coordenadas: -1.73, 12.4 cm")
```

!!! note "Comillas en las expresiones regulares"

    Las comillas dentro de las expresiones regulares son un caso especial. La sintaxis de las expresiones regulares no requiere utilizar secuencias de escape para ellas, pero en Julia sí se necesitan en todos los casos (tanto si la expresión se construye de forma literal con la etiqueta `r` como si se hace a partir de una cadena normal con el constructor `Regex`), para evitar la confusión con los delimitadores de texto. Alternativamente, si las comillas no están al inicio o al final de la expresión regular, se pueden utilizar las triples comillas.

Hay dos funciones de búsqueda en cadenas de texto específicamente diseñadas para usarse con expresiones regulares. Una de ellas es `match`, que se emplea del mismo modo que `findfirst`, pero que en caso de encontrar una coincidencia con el patrón devuelve un objeto del tipo `RegexMatch` (si no se da la coincidencia, devuelve un `nothing`, como `findfirst` y las otras funciones descritas antes).

Los campos `match` y `offset` de un `RegexMatch` contienen, respectivamente, el fragmento de texto encontrado y la posición de su primer carácter en la cadena. Por ejemplo, `r"#\d+#` busca una serie de dígitos delimitados por almohadillas, lo que da lugar al siguente resultado:

```@repl
m = match(r"#\d+#", "ABC #123#")
m.match
m.offset
```

Además, si la expresión regular contiene partes señaladas para su "captura" (marcadas entre paréntesis), los grupos de caracteres capturados quedan recogidos en el vector `captures`, y sus posiciones iniciales en el vector `offsets`. Modificando ligeramente el ejemplo anterior, podemos usar la expresión regular `r"#(\d+)#"` que busca el mismo patrón, pero además captura la serie de dígitos encontrada:

```@repl
m = match(r"#(\d+)#", "ABC #123#")
m.captures
m.offsets
```

Por otro lado, la función `eachmatch` devuelve un "iterador", que en la primera iteración da el mismo resultado que `match`, y en las siguientes sigue recorriendo la cadena de texto desde la última coincidencia para buscar otras nuevas, hasta que ya no hay más. Por ejemplo:

```@repl
for m in eachmatch(r"#(\d+)#", "ABC #123#; DEF #456#")
    println("$(m.captures[1]) en la posición $(m.offsets[1])")
end
```

### Expresiones regulares para reemplazos

La función `replace` también permite utilizar expresiones regulares en el término de búsqueda. En tal caso, además de un texto fijo o una función, el texto de reemplazo puede ser una expresión regular con [referencias a los grupos capturados](https://www.regular-expressions.info/replacebackref.html) en la búsqueda. Las expresiones a utilizar en este contexto no son del tipo `Regex`, sino del tipo `SubstitutionString`, y se escriben con el prefijo `s` (en lugar de `r`).

Por ejemplo, la expresión `s"¡\1!"` representa el texto del primer grupo capturado (`\1`) entre signos de exclamación. Así podemos realizar la siguiente transformación:

```@repl
replace(
    "Hola, don Pepito. Adiós, don José",
    r"(Hola|Adiós)" => s"¡\1!"
)
```

Los grupos capturados pueden recibir un nombre. Hay varias formas válidas de dar nombre al grupo de captura en la expresión regular; una es añadir la etiqueta `?<x>` al comienzo del grupo, donde `x` es el nombre a asignar. Por ejemplo `r"#(?<num>\d+)#"` buscaría una serie de cifras entre almohadillas, y capturaría las cifras en un grupo llamado `num`. En la cadena de reemplazo usada por `replace` se podría poner el código `\g<num>` en lugar de `\1` para referirse a esta captura. Así pues, las dos operaciones siguientes serían equivalentes:

```@repl
replace("ABC #123#", r"#(\d+)#" => s"(número \1)")
replace("ABC #123#", r"#(?<num>\d+)#" => s"(número \g<num>)")
```

Naturalmente, en un caso como este dar nombre al grupo capturado no añade mucho valor. Pero cuando la cadena de búsqueda contiene múltiples grupos capturados, resulta un recurso muy útil.


## Lectura y escritura en ficheros de texto

Los ficheros de texto son una forma habitual y muy práctica (aunque no la más eficiente) de guardar datos. Como se ha visto en el [capítulo 2](2-series-tablas.md), cuando el texto está estructurado en forma de tabla la información puede leerse y guardarse con las funciones `readdlm` y `writedlm` del módulo `DelimitedFiles`, respectivamente, o con funciones equivalentes de otros paquetes como CSV, etc. A continuación se presentan otras funciones y rutinas para leer y escribir datos en ficheros de texto con estructuras artibrarias.

### Funciones de de lectura

La información de un fichero de texto se puede extraer en una o varias cadenas de texto a través de las funciones `read` o `readlines`, de la siguiente manera:

```julia
textocompleto = read("datos.txt", String)
lineas = readlines("datos.txt")
lineas = readlines("datos.txt", keep=true)
```

Con la primera orden todo el texto del archivo `"datos.txt"` se vuelca en una sola cadena de texto (`textocompleto`). En las otras dos, cada línea del archivo se guarda en un elemento del vector `lineas`. La diferencia entre las dos formas de llamar a la función es que la última (con `keep=true`) conserva el carácter de nueva linea (`\n`) al final de cada línea.

Las funciones `read` o `readlines` proporcionan una forma cómoda y segura de acceder a los contenidos de un archivo de texto, pero pueden ser poco eficientes si no es realmente necesario leer todas las líneas a la vez, especialmente si la extensión del archivo es muy grande. La alternativa es leer la información del archivo secuencialmente. Para esto es necesario "abrir" el archivo antes de comenzar a leerlo, y "cerrarlo" al finalizar, con las funciones `open` y `close`, respectivamente. Por ejemplo:

```julia
io = open("archivo.txt")
# Operaciones secuenciales de lectura ...
close(io)
```

La función `open` crea un objeto de tipo `IOStream`, que es un acceso de entrada o salida al archivo, que sirve para ir recorriéndolo y trabajar con sus contenidos. Dependiendo del sistema operativo, esta operación puede bloquear el acceso de otros programas al archivo para evitar conflictos. La función `close` consolida los contenidos del archivo si ha habido operaciones de escritura y cierra el acceso al archivo en cuestión, devolviéndolo a su estado "natural".

Hay distintos modos de apertura de archivos, que se pueden indicar como segundo argumento de la función `open`, en forma de cadena de texto. El empleado por defecto (como en el ejemplo anterior) es el modo de lectura, que permite extraer datos del archivo pero no modificarlo. Esto se podría haber señalado explícitamente escribiendo `open("archivo.txt", "r")`. Los distintos modos de apertura de archivos son:

* **`"r"`**: modo de lectura (*read*, solo válido para archivos ya existentes).
* **`"w"`**: modo de escritura (*write*), creando el archivo si no existe, o borrando los contenidos previos.
* **`"a"`**: modo de extensión (*append*), creando el archivo si no existe, o escribiendo a partir del final del archivo.

Estos tres modos tienen una variante *extendida* con el símbolo `+` (`"r+"`, `"w+"`, `"a+"`), que permiten tanto las operaciones de lectura como de escritura.

A menudo el archivo se recorre línea a línea. Esto se puede hacer en bucle con la función `readline`, que funciona que igual que su análoga `readlines`, con la diferencia de que el primer argumento ha de ser un `IOStream` y que solo devuelve una cadena de texto. Cada vez que se llama a `readline`, el punto de acceso se desplaza automáticamente para apuntar a la siguiente línea.

Si se quiere recorrer el archivo completo se puede utilizar un bucle `while` que termine al detectarse que se ha llegado al final del archivo con la función `eof` (de *end-of-file*):

```julia
io = open("archivo.txt")
while !eof(io)
    linea = readline(io)
    # Operaciones con `linea`
end
close(io)
```

Una forma más abreviada de hacer lo mismo es mediante la función `eachline`, que crea un "iterador" con el que trabajar en un bucle `for`:

```julia
io = open("archivo.txt")
for linea = eachline(io)
    # Operaciones con `linea`
end
close(io)
```

Y se puede abreviar aún más, pasando el archivo directamente a `eachline` (en este caso no hace falta cerrar explícitamente el archivo; se cierra automáticamente al acabar las iteraciones):

```julia
for linea = eachline("archivo.txt")
    # Operaciones con `linea`
end
```

### Funciones de escritura

La forma más sencilla de volcar una cadena de texto `s` en un archivo de texto (p.ej. `"archivo.txt"`) es mediante la función `write`: 

```julia
write("archivo.txt", s)
```

Esta función también se puede aplicar a un `IOStream` abierto en "modo de escritura" para añadir texto de forma secuencial:

```julia
io = open("archivo.txt", "w")
write(io, s)
# Otras operaciones de escritura ...
close(io)
```

!!! tip

    La función `write` admite que se le pasen múltiples argumentos, de tal manera que `write(io, s1, s2...)` escribe secuencialmente los contenidos de `s1`, `s2` etc. en el archivo referido por `io`.

Otros tipos de variables (por ejemplo números) también se pueden escribir como texto en su representación canónica, usando la función `print` (o `println` para añadir el carácter de nueva línea al final):

```julia
# Escribe "La raíz de 2 es 1.4142135623730951\n"
io = open("archivo.txt", "w")
println(io, "La raíz de dos 2 es ", sqrt(2)")
close(io)
```

Para escribir las variables con un formato más personalizado también se puede utilizar la función `@printf` del módulo `Printf`: 

```julia
# Escribe "La raíz de 2 es 1.414\n"
io = open("archivo.txt", "w")
@printf(io, "La raíz de 2 es %0.3f\n", sqrt(2))
close(io)
```

## Recomendaciones para leer y escribir archivos

Un problema que puede ocurrir a la hora de trabajar con archivos es que el programa falle o se interrumpa prematuramente, antes de cerrar el archivo. Cuando esto ocurre es habitual que la operación de apertura del archivo se haya hecho dentro de la misma función en la que ocurre el fallo, y por lo tanto al terminar la función se pierda el `IOStream` que serviría para acceder al archivo y cerrarlo adecuadamente. Si se habían hecho operaciones de escritura con él, estas pueden no acabar de llevarse a cabo, perdiéndose el trabajo supuestamente realizado.

Una forma de prevenir que esto ocurra es usar una estructura [try ... catch ... finally](@ref) para trabajar con el archivo, como:

```julia
io = open("archivo.txt", "w")
try
    # Operaciones con `io` que pueden fallar
finally
    close(io)
end
```

Esta estructura asegura que, aunque falle el código escrito después del `try`, el programa no se interrumpirá sino que se ejecutará la línea `close(io)`.

Una alternativa más compacta y equivalente es pasarle un "bloque `do`" a la función `open`, del siguiente modo:

```julia
open("archivo.txt", "w") do io
    # Operaciones con `io` que pueden fallar
end
```

Este código se puede interpretar como "abre el archivo y haz con él lo que pone en el bloque de código (refiriéndose al archivo abierto como `io`), asegurando que el archivo se cierra independientemente de lo que pase en el bloque".

Sea como sea, es recomendable que las operaciones de lectura o escritura de los archivos se entrelacen lo menos posible con otras operaciones y cálculos, por dos razones:

1. Mientras más código se escriba mezclado con las operaciones de acceso a los archivos, mayor es el riesgo de que se produzca algún error que interrumpa el programa.
2. Las medidas de seguridad señaladas arriba implican recoger las operaciones de acceso a los archivos dentro de bloques de código que tienen su propio contexto de variables, por lo que las variables que se creen en ese bloque no estarán disponibles fuera de ellos.

Así pues, en el caso de que haya que acceder a un archivo varias veces, con muchas otras operaciones entre medias, puede ser conveniente cerrar el archivo tras las primeras operaciones de lectura/escritura, para volver a abrirlo después de los cálculos intermedios. En qué medida es recomendable hacer esto dependerá de la frecuencia con la que haya que repetir las operaciones de apertura y cierre, que normalmente son rápidas, pero si son demasiado frecuentes pueden ralentizar el programa sensiblemente.

Si a pesar de todo se produce un error que deje un archivo a medias de editar, se puede intentar recuperar su estado, creando un `IOStream` de lectura que apunte al mismo archivo, y forzando las operaciones de escritura pendientes con la función `flush`:

```julia
io = open("archivo.txt")
flush(io)
close(io)
```

## Sumario del capítulo

En este capítulo hemos explorado las principales herramientas de utilidad para trabajar con textos, registrándolos en variables como cadenas de texto (*strings*), e interactuando con el sistema de archivos para leer y escribir dichas cadenas en archivos de texto.

En particular, hemos visto diversas maneras de crear cadenas de texto:

* A partir de otras variables mediante la función `string`, `repr` o la macro `@sprintf` del módulo `Printf`.
* A partir de archivos de texto con las funciones `read`, `readline` o `readlines`, así como con el iterador obtenido por `eachline`.

Y por otro lado hemos visto distintas formas de volcar las cadenas de texto:

* En variables de otro tipo con la función `parse`.
* En pantalla o en archivos de texto con las funciones `write`, `print`, `println` o la macro `@printf` del módulo `Printf`.

También se han tratado las dificultades derivadas de los caracteres que por distintos motivos suelen expresarse como "secuencias de escape", y del uso de caracteres Unicode que ocupan más de un "bloque de código", así como las herramientas que ayudan a solventar esas dificultades:

* Las funciones `escape_string` y `unescape_string`.
* Las distintas formas de delimitar las cadenas de texto, mediante comillas o "triples" comillas.
* Las sintaxis `raw`.
* Las funciones para calcular las posiciones y longitudes de de una cadena y sus caracteres (`nextindex`, `previndex`, `lastindex`, `isvalid`, en combinación con `length` y `ncodeunits`). 

Además, se han presentado numerosas funciones y procedimientos para manipular las cadenas de texto:

* Métodos de concatenación de cadenas e "interpolación" de valores.
* Funciones para unir conjuntos de cadenas y separarlas (`join`, `joinpath`, `split`, `splitdir`, `splitext` y `splitdrive`).
* Funciones para alternar entre mayúsculas y minúsculas (`lowercase`, `uppercase` y `titlecase`).
* Funciones para manipular los caracteres de espacio (`chomp`, `chop`, `strip`, `lstrip`, `rstrip`, `lpad` y `rpad`).
* Métodos para buscar y reemplazar, utilizando patrones de caracteres y expresiones regulares (`findfirst`, `findlast`, `findprev`, `findnext`, `occursin`, `replace` y `match`).

Por último, aunque no están directamente relacionadas con las cadenas de texto, también se han presentado las funciones `round` y `truncate` como métodos para reducir el número de decimales de un número.

