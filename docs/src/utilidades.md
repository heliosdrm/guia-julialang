## Capítulo 9. Utilidades para simplificar código

En este capítulo vamos a ver, antes de pasar a aspectos más avanzados de programación en Julia, algunos recursos para hacer el código algo más conciso. Su uso es principalmente cuestión de estilo: los programas no funcionan necesariamente mejor, ni más rápido, porque el código sea más breve o extenso. A lo que sí puede afectar esto es a su legibilidad, aunque no siempre del mismo modo. A veces puede ser más sencillo leer y entender la secuencia de operaciones de un código más breve; aunque si se abusa de la concisión, también puede resultar más críptico.

En definitiva, los trucos que se presentan en este capítulo son herramientas completamente optativas; no hay ninguna situación en la que realmente se *necesiten*, aunque para muchos usuarios resultan convenientes y las usan a menudo. 

## *Array* y *dictionary comprehensions*

Lo que en inglés se llaman *array comprehensions* son una forma abreviada de bucles `for` diseñados para crear *arrays*. Para explicarlos, consideremos el siguiente código, que crea un vector de textos que reproduce la "tabla del 7":

```@repl
tabla7 = Vector{String}(undef, 10)
for i = 1:10
    tabla7[i] = "7×$i = $(7*i)"
end
tabla7
```

El código anterior se podría haber reducido al uso de la `map`, con una función anónima: 

```@repl
map(i -> "7×$i = $(7*i)", 1:10)
```

Pero también podemos crear el *array* con la siguiente expresión, que hace exactamente lo mismo, si bien su significado resulta algo más fácil de comprender, usando la sintaxis del lenguaje natural (al menos en inglés):

```@repl
["7×$i = $(7*i)" for i=1:10]
```

Los *array comprehensions* vienen muy bien, sobre todo, para crear *arrays* de varias dimensiones. Por ejemplo, podemos crear una matriz con las tablas del 1 al 10 simplemente combinado dos iteradores tras el `for`:

```@repl
["$(j)×$(i) = $(j*i)" for i=1:10, j=1:10]
```

!!! tip

    Este tipo de iteradores combinados también se puede utilizar en los bucles `for` convencionales. Los dos siguientes bucles son equivalentes:
    
    ```julia
    for i=1:n
        for j=1:m
            # código
        end
    end
    
    for i=1:n, j=1:m
        # código
    end
    ```

Además, también se pueden crear diccionarios mediante *comprehensions*. Por ejemplo, partamos de un vector con elementos repetidos:

```@repl c9
frase = "como poco coco como poco coco compro"
palabras = split(frase)
```

Para crear un diccionario que indique las veces que se encuentra cada elemento, podríamos usar el siguiente bucle:

```@repl c9
cuentas = Dict{typeof(palabras), Int}()
for p in unique(palabras)
    cuentas[p] = count(palabras .== p)
end
cuentas
```

Pero la siguiente expresión hace lo mismo de forma más eficiente:

```@repl c9
cuentas = Dict(p => count(palabras .== p) for p=unique(palabras))
```

!!! tip

    La función `count` en ejemplo anterior devuelve el número de elementos de `palabras .== p` que contiene el valor `true` (es decir, el número de elementos de `palabras` que coincide con `p`). Una forma más eficiente de usar la función `count` (aunque no tan fácil de leer) sería con una función anónima que diga cuándo un elemento del vector es `true`: `count(s -> s == p, palabras)`. Esta segunda expresión es más eficiente, porque evita crear el vector `palabras .== p`.


## Definición abreviada y concatenación de funciones

Cuando el cuerpo de una función es tan sencillo que se puede reducir a una sola línea, se puede simplificar la forma de definirla, eliminando la clave `function` y el finalizador `end`. Por ejemplo, las siguientes definiciones de la [función de densidad de una distribución normal](https://es.wikipedia.org/wiki/Distribución_normal) son equivalentes:


```@example c9
function densidadnormal(x)
    return exp(-x^2/2) / sqrt(2*pi)
end

densidadnormal(n) = exp(-x^2/2) / sqrt(2*pi)
```

Por otro lado, hay una sintaxis especial para concatenar funciones, cuando estas reciben un solo argumento. Supongamos que tenemos un número `x` tomado de una distribución normal con media `m` y desviación típica `s`, del que queremos conocer su densidad de probabilidad. Para eso podríamos usar la función `densidadnormal` que acabamos de definir, aplicándola a su valor normalizado. Esta normalización se podría hacer con la siguiente función:

```@example c9
normalizar(x, m, s) = (x - m)/s
```

Así pues, el cálculo que queremos hacer sería (tomando como media `m=1` y desviación `s=0.8`):

```@repl c9
x = 0.5
d = densidadnormal(normalizar(x, 1, 0.8))
```

Pero alternativamente, las funciones `normalizar` y `densidadnormal` se podrían concatenar del siguiente modo:

```@repl c9
d = normalizar(x, 1, 0.8) |> densidadnormal
```

El operador `|>` se conoce como *pipe* ("tubería" en inglés), y se puede usar cuando la expresión de la izquierda es el único argumento que se ha de pasar a la función de la derecha. Esta forma de encadenar funciones requiere la misma cantidad de código, pero puede hacerlo más legible, especialmente si la primera expresión es más compleja, o si se encadenan muchas funciones.

Al igual que otros operadores, este también se puede usar con *[Broadcasting](@ref)*, con un punto previo. Si `x` fuese un vector de números:

```julia-repl
d = normalizar.(x, 1, 0.8) .|> densidadnormal


## Símbolos matemáticos

En la mayoría de lenguajes de programación las operaciones matemáticas se escriben usando la notación matemática convencional, o adaptándola donde es necesario para que se pueda escribir en "texto plano". Así, la suma de `a` y `b` se escribe como `a + b`, una división como `a / b`, `a < b` significa "`a` es menor que `b`", etc. En Julia, este principo se lleva incluso más lejos que en otros lenguajes; por ejemplo:

  * Si `a` es el nombre de una variable, `2a` significa "2 veces `a`" (y lo mismo con cualquier otro número, sea entero, decimal o de otro tipo).
  * Es posible escribir comparaciones lógicas concatenadas, como `0 < x < 1` para comprobar si la variable `x` se encuentra entre `0` y `1`. (En otros lenguajes es necesario expresarlo de forma más compleja, como `(0 < x) && (x < 1)`.
  * Existe una amplia cobertura de símbolos matemáticos en forma de caracteres Unicode, para representar algunos operadores, variables y funciones habituales que no están en el conjunto de caracteres ASCII. Los principales interfaces para Julia permiten escribirlos apartir de "secuencias de escape" que comienzan por la barra invertida `\`, pulsando el tabulador después de escribir la secuencia, para convertirla en el símbolo deseado. A continaución se presentan algunos ejemplos que pueden usarse habitualmente (véase una lista completa de los caracteres de escape en la [página de documentación oficial](https://docs.julialang.org/en/v1/manual/unicode-input)).
  

| texto plano | Unicode | sec. de escape | significado                  |
|:-----------:|:-------:|:--------------:|:----------------------------:|
| `!=`        | `≠`     | `\neq`         | no es igual a                |
| `<=`        | `≤`     | `\le`          | menor o igual que            |
| `>=`        | `≥`     | `\ge`          | mayor o igual que            |
| `isapprox`  | `≈`     | `\approx`      | approximadamente igual a     |
| `!isapprox` | `≉`    | `\napprox`     | no es aproximadamente igual a |
| `pi`        | `π`     | `\pi`          | número pi                    |
| `sqrt`      | `√`     | `\sqrt`        | raíz cuadrada                |
| `in`        | `∈`     | `\in`          | está en...                   |
| `!in`       | `∉`     | `\notin`       | no está en...                |
| `dot`       | `⋅`     | `\cdot`        | producto escalar             |
| `cross`     | `×`     | `\times`       | producto vectorial           |


(Las dos últimas funciones son parte del módulo estándar `LinearAlgebra`.)

Estos símbolos permiten escribir operaciones y funciones de forma muy expresiva y elegante. Por ejemplo, combinándolas con la forma abreviadada de definir funciones, podemos escribir la función de densidad de probabilidad normal de este modo:

```julia
ϕ(x) = exp(-x^2/2) / √(2π)
```

Hay que tener en cuenta, sin embargo, que escribir símbolos que no están directamente disponible en el teclado es más engorroso, y los usuarios pueden tener que escribir código con herramientas que no lo faciliten. Por eso, aunque el uso de estos símbolos puede estar bien para escribir el código fuente de un programa, no es tan buena idea emplearlo en nombres de funciones, variables u otros elementos con los que tengan que interactuar otros.

## Expresiones condicionales con operadores lógicos

Para finalizar, comentaremos un tipo de expresión que se emplea con relativa frecuencia para sintetizar bloques condicionales. Se trata de un uso análogo al del operador ternario como sustituto del `if-else-end`, que ya se presentó en la sección del capítulo 3 sobre [Bloques condicionales](@ref).

Como `a && b` es una operación "con cortocircuito" (`b` se evalúa solo si `a` da como resultado `true`), también sirve como equivalente a la expresión `if a; b; end`. (La única diferencia relevante es que si `a` es `false`, `a && b` devolverá `false`, mientras que el bloque `if` devolverá `nothing`.) Del mismo modo, `a || b` sería equivalente a `if !a; b; end`.

Por esta razón, los operadores `&&` y `||` se utilizan a veces para abreviar bloques condicionales con expresiones muy sencillas, sobre todo en condiciones para interrumpir funciones o bucles. Por ejemplo, si una función hubiera de interrumpirse en el caso de que la variable `x` adopte el valor `0`, esto podría escribirse como:

```julia
x == 0 && return
```

