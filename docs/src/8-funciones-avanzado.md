# Capítulo 8. Uso avanzado de funciones

La forma en la que Julia maneja las funciones es probablemente uno de sus aspectos más destacables. En este capítulo vamos a ver las distintas formas de definir funciones en Julia y de trabajar con ellas eficientemente, para sacarles el máximo provecho. En lo que sigue se asume que ya se conocen algunos conceptos, como la forma habitual de definir una función y sus argumentos de entrada y salida, así como los distintos contextos de variables (global vs. local), que se explican en el [capítulo 3](3-funciones-control.md).

## Formas de definir una función

En el capítulo introductorio a las funciones se han mostrado dos formas habituales de definir una función. Utilizando el mismo ejemplo de la suma aritmética que se presentó en ese capítulo, estas dos formas son:

```julia
# 1. Forma "estándar"
function suma_aritmetica(n)
    return n * (n + 1) / 2
end

# 2. Forma "abreviada"
suma_aritmetica(n) = n * (n + 1) / 2
```

Hay una tercera forma de definir esta función, que es como una función "anónima". Se parece mucho a la forma abreviada, pero se omite el nombre de la función, y el signo `=` se cambia por `->`.

```julia
(n) -> n * (n+1) / 2
```

### Uso de las funciones anónimas

Las funciones anónimas se usan a menudo de forma auxiliar, dentro de otras funciones. Por ejemplo en `mapslices`, que sirve para aplicar una función dada a lo largo de las filas o columnas de una matriz.[^1] Así, para calcular la norma de los vectores definidos en las columnas de una matriz --con la función `norm` del módulo `LinearAlgebra`-- podemos escribir:

```@repl c8
using LinearAlgebra
matriz = [1  0.6  -0.5;
  2 -0.15  0.3;
  3 -0.4  -0.1;
  4 -0.15 -0.4;
  5  0.6   0.1]
mapslices(norm, matriz, dims=1)
```

[^1]: De forma más general, `mapslices` aplica una función a lo largo de "porciones" de un *array*, que se definen por una o más dimensiones. Las operaciones con vectores más habituales, por ejemplo `sum`, `prod`, `maximum`, `minimum`, etc., pueden hacerse por filas, columnas u otras dimensiones añadiéndoles el argumento con nombre `dims`; `mapslices` generaliza esta forma de aplicarse a cualquier otra función.

Otros cálculos no tienen una función predefinida, y tendríamos que crearla *ad hoc*. Pero si esa función no tiene un uso específico más allá de ese contexto, no vale la pena crearla de la forma habitual, y resulta práctico pasarle una función anónima. Por ejemplo, para calcular las sumas de cuadrados de las columnas de `matriz`:


```@repl c8
mapslices(x -> sum(x.^2), matriz, dims=1)
```

Es habitual que el código de las funciones anónimas sea suficientemente sencillo como para condensarlo en una expresión corta, como es este caso. Pero también podría tratarse de un código algo más largo, que incluso ocupe varias líneas. Pongamos, por ejemplo, que quisiéramos calcular la suma de cuadrados de las columnas, pero sustrayendo el valor medio cuando este es más pequeño que el menor de los valores individuales.

Para poner varias líneas de código en una sola expresión, estas se pueden delimitar con las palabras claves `begin` y `end`, de modo que la función anónima para el cálculo mencionado podría ser:

```julia
x -> begin
    media = mean(x)
    if abs(x) < minimum(abs.(s))
        return sum((x .- media).^2)
    else
        return sum(x.^2)
    end
end
```

Sin embargo, escribir ese código como argumento de entrada a `mapslices` no resultaría muy práctico. Por esta razón, Julia facilita una forma cómoda de pasar funciones anónimas complejas, cuando estas ocupan el primer argumento de otra función, como es el caso. Consiste en escribir el código de la función anónima *después* de la función que la utiliza, tras la palabra `do` y el nombre de los argumentos de entrada. El ejemplo anterior tomaría esta forma:

```@repl c8
using Statistics
mapslices(matriz, dims=1) do x
    media = mean(x)
    if abs(media) < minimum(abs.(x))
        return sum((x .- media).^2)
    else
        return sum(x.^2)
    end
end
```

Una situación en la que resulta muy habitual usar la sintaxis `do`-`end` es al operar con un archivo que se abre con la función `open`, como se ha visto en el capítulo anterior:

```julia
open("archivo.txt", "w") do io
    # Múltiples operaciones de escritura
end
```

Aquí se está aprovechando un método especial de la función `open`, que toma como primer argumento una función con las operaciones de lectura o escritura, aunque en la práctica estemos "sacando" el código de esas operaciones fuera de los argumentos de `open`.

Finalmente, cabe señalar que las funciones anónimas también se pueden asignar a una variable, y utilizarlas como funciones "con nombre", por ejemplo:


```julia
sumadecuadrados = x -> sum(x.^2)
```

## Expresiones `let`

Aunque no se trata realmente de funciones, las expresiones `let` son estructuras de código que se comportan de forma semejante a funciones anónimas "de usar y tirar". Por ejemplo, para calcular la suma de cuadrados con media ajustada que hemos definido antes, aplicándola específicamente al vector `[1,2,3]`, podríamos escribir:


```@repl c8
resultado = let (x = [1,2,3])
    media = mean(x)
    if abs(media) < minimum(abs.(x))
        return sum((x .- media).^2)
    else
        return sum(x.^2)
    end
end
```

Este bloque de código es equivalente a declarar: "define la variable `resultado` del siguiente modo: tomando una variable `x = [1,2,3]`, calcula su media, y en función de su valor calcula la suma de cuadrdos de `x` o la suma de cuadrados de `x` menos la media".

Una diferencia entre las expresiones `let` y las funciones es que el código de las primeras se ejecuta en el mismo punto en el que se define --y por lo tanto siempre es necesario proporcionarle un valor a los "argumentos" (las variables que se declaran justo después de la palabra `let`)--. Por otro lado, al no ser realmente una función, no se debe usar `return` para devolver el resultado de la expresión; el valor devuelto es siempre el que se calcula en la última línea del bloque.

En este sentido, los bloques `let` también se parecen a las expresiones compuestas entre `begin` y `end`. La principal diferencia entre unas y otras es que las expresiones `let` introducen su propio contexto de variables, que se destruyen al finalizar el bloque (véase la sección sobre variables locales y globales más abajo.


## Métodos

Una misma función puede hacer cosas distintas, según los argumentos que se le pasen. A cada variante de una función se le llama un "método" de la misma, y en Julia es muy habitual que las funciones tengan más de un método.

De hecho, cuando se define una función con argumentos opcionales, se están definiendo distintos métodos de la misma (uno que requiere que se le pasen todos los argumentos, otro que no requiere ninguno, etc.). Así, consideremos por ejemplo la siguiente función para incrementar el valor de un número, usando la unidad como incremento por defecto:

```@repl
incrementar(x, inc=1) = x + inc
```

La descripción de esta función `incrementar` señala que tiene dos métodos, porque hubiera sido lo mismo (aunque no tan compacto) definir explícitamente dos métodos de la función con el nombre `incrementar`:

```julia
incrementar(x, inc) = x + inc
incrementar(x) = x + 1function incrementar(x, inc)
```

Los métodos de una función también pueden tratar de forma completamente diferente los distintos argumentos que se le pasan. Por ejemplo, en el primer capítulo presentamos la función [`gauss_diasemana`](1-primerospasos.md#gauss_diasemana) para determinar el día de la semana que corresponde a una fecha determinada, dada por los números del día, el mes y el año:

```@setup c8
include("../../scripts/calc_diasemana.jl")
```
```@example c8
gauss_diasemana(11, 8, 2018)
```

Podríamos crear un método que tome un solo argumento, asumiendo que es un objeto de tipo `Date`, definido dentro del módulo estándar `Dates`. A partir de un objeto de este tipo, se pueden extraer los números del día, mes y año usando las funciones `day`, `month` y `year`. Por lo tanto, nuestro nuevo método podría ser como sigue:

```@example c8
function gauss_diasemana(fecha)
    dia = day(fecha)
    mes = month(fecha)
    año = year(fecha)
    return gauss_diasemana(dia, mes, año)
end

using Dates
fecha = Date("11-8-2018", "dd-mm-yyyy")
gauss_diasemana(fecha)
```

!!! note

    A la hora de definir distintos métodos de una función, solo cuentan los argumentos "posicionales". Si se definen varias versiones de una misma función con los mismos argumentos posicionales, cambiando solo los argumentos "con nombre" (p.ej. `fun(a, b; c=1)` y `fun(a, b; c=1, d=2)`, lo que se hará es sobreescribir el mismo método.
    
Supongamos ahora que también quisiéramos un método para procesar una fecha escrita en una cadena de texto. Podríamos definir un método con dos argumentos (la fecha en forma de texto y el patrón de formato):

```julia
gauss_diasemana(fecha, formato) = gauss_diasemana(Date(fecha, formato))
```

¿Pero y si quisiéramos tener un formato por defecto, por ejemplo el de `"dd-mm-yyyy"` que hemos usado antes? Ya tenemos un método de `gauss_diasemana` con un solo argumento, por lo que no podríamos distinguir los dos métodos según el número de argumentos. Sin embargo, Julia permite definir métodos teniendo en cuenta no solo el número de argumentos, sino también su *tipo*.

Así pues, podríamos definir uno o más métodos especiales para los casos en los que el primer argumento es de tipo `String`, o mejor, cualquier tipo dentro de `AbstractString`, del siguiente modo:

```julia
function gauss_diasemana(fecha::AbstractString, formato="dd-mm-yyyy")
    dat = Date(fecha, formato)
    return gauss_diasemana(dat)
end
```

!!! tip "Escoge tipos genéricos para definir los argumentos"

    `AbstractString` es, como indica su nombre, un tipo abstracto definido para referirse tanto a objetos de tipo `String` como a otros que también puedan interpretarse y manipularse como cadenas de texto. Normalmente es recomendable diseñar funciones con métodos que sean todo lo genéricos que se pueda, es decir que no estén demasiado restringidos a unos tipos de argumentos concretos. Esto ayuda a que las funciones sean útiles en aplicaciones más amplias que las que se hubieran podido pensar en un principio. Si por alguna razón resulta necesario definir métodos condicionados por el tipo de variables, como en el ejemplo, es mejor utilizar tipos abstractos que recojan la mayor cantidad posible de casos de uso. 

!!! note

    A la hora de definir métodos condicionados por el tipo de variables solo cuentan los posicionales, al igual que ocurre con el número de argumentos. Es válido cualificar el tipo de los argumentos con nombre, p.ej. `fun(a, b; c::Int=1)`, pero eso solo sirve para obligar a que el argumento con nombre `c` sea de tipo `Int` (de lo contrario se emitirá un error). Esa definición  no podría coexistir con, por ejemplo, `fun(a, b; c::Float64=1.0)`.

## Estabilidad de tipos

Algunos lenguajes de programación como C, Java y similares, requieren que al definir funciones se declaren los tipos de todas los argumentos de entrada --y también el del valor devuelto por la función, así como los de *todas las variables* que se usan en el cuerpo de una función o un programa--. Tener claramente definidos los tipos de variables a usar es importante a la hora de compilar una función o un programa (traducir las instrucciones al "lenguaje de la máquina"), pues permite definir de forma correcta y optimizada las operaciones a realizar a bajo nivel, reservar la cantidad de memoria adecuada para las variables, etc.

Por ese motivo, las personas con experiencia en esos lenguajes de programación pueden sentirse inclinadas a anotar los tipos de todos los argumentos en las funciones de Julia. Sin embargo, hay que insistir en que esto no es necesario, y ni siquiera deseable. Como se ha señalado arriba, es bueno usar métodos genéricos, pues resultan más flexibles y fáciles de extender que los que son muy específicos. Y omitir los tipos de variables requeridos por los métodos no significa que el código no se pueda compilar tal como se hace en C, Java, etc.

De hecho, a bajo nivel Julia genera un código distinto y específico para cada combinación concreta de tipos de argumentos, se hayan definido estos de forma genérica o no. Por ejemplo, si una función es declarada como `f(a, b)`, Julia generá un código determinado para el caso en que tanto `a` como `b` sean números de tipo `Int`, otro cuando `a` sea un `Int` y `b` un `Float64`, un distinto cuando `a` sea un `String`... y así para cualquier combinación de dos tipos que pueda ser procesada por las instrucciones escritas en la función.

Como las combinaciones posibles de tipos de argumentos (que potencialmente son infinitas) no pueden determinarse a priori, esta interpretación del código se hace "a demanda", cada vez que se llama a la función `f` con una combinación nueva de tipos para `a` y `b`. Pongamos que en una sesión de Julia ya se ha utilizado `f` con dos argumentos de tipo `Int`. Esto sería como si se hubiera definido un método `f(a::Int, b::Int)`, de tal manera que si se vuelve a llamar a `f` con otros dos argumentos del mismo tipo (aunque sea con otros valores), ese método ya estaría disponible para su uso directo.[^2]

[^2]: Esto ocurre a bajo nivel, de forma transparente para el usuario, aunque no del todo imperceptible. De hecho, esta es una de las razones por las que Julia es eficiente para hacer programas complejos, con numerosísimas operaciones, pero que pueden costar de "arrancar" comparado con otros lenguajes: la primera vez que Julia se encuentra con una función y unos tipos particulares para sus argumentos de entrada, tiene que definir el código de bajo nivel para esos tipos y compilarlo. Pero una vez hecho esto, repetir la operación con nuevos argumentos del mismo tipo es a menudo mucho más rápido.

Para que Julia pueda compilar las funciones y sacar el máximo rendimiento de ellas, lo más importante no es definir los tipos de los argumentos de entrada, sino asegurarse de que las operaciones dentro del cuerpo de la función dan resultados con "tipos estables". Esto significa que para cualquier operación, si las variables con las que se opera son de unos tipos concretos, el resultado sea también de un tipo concreto, y predecible incluso sin conocer los valores.

En general, todas las operaciones y funciones básicas cumplen este requisito. Tomando la multiplicación `z = x * y` como ejemplo:

* Si `x` e `y` son dos números de cualquier tipo común, `z` será un número del mismo tipo.
* Si `x` e `y` son dos tipos distintos de números enteros, p.ej. `Int32` e `Int64`, `z` será del tipo de entero que pueda representar los valores de ambos (en este caso `Int64`).
* Si `x` es un `Float64` e `y` es un *array* de `Int`s, `z` será un *array* de `Float64`.
* Si `x` e `y` son dos cadenas de texto (`String`s), `z` será otro `String` que concatena `x` seguido de `y`.
* Etc.

!!! note

    La estabilidad de tipos es la razón por la que, por ejemplo, la división de los números enteros `6/3` da como resultado el número decimal `2.0`, aunque este caso particular bien pudiera haber sido representado como otro entero  --para obtener el entero `2` se podría utilizar `div(6, 3)`--. Por el mismo motivo, la raíz cuadrada (`sqrt`) falla cuando se aplica a un número real negativo, en lugar de dar un número complejo --para obtener la raíz imaginaria de `-1`, por ejemplo, habría que pasarlo como un número complejo: `sqrt(-1 + 0im)` o `sqrt(Complex(-1))`--.

Las funciones que constan únicamente de una serie de operaciones de tipos estables, son por extensión funciones de tipo estable. El problema puede darse con estructuras de código como los bloques condicionales o los bucles, que pueden añadir incertidumbre al tipo de los resultados. Por ejemplo, en la siguiente función:

```julia
function fun(x, y)
    if y > 1
        z = x/y
    else
        z = x*y
    end
    return z
end
```

Si tanto `x` como `y` son números enteros, la operación `x*y` dará lugar a otro entero, pero `x/y` dará un número decimal. Por lo tanto, aunque esas operaciones sean de tipo estable individualmente, no se puede predecir de qué tipo será el resultado `z` antes de conocer los valores de los argumentos.

Otro ejemplo de inestabilidad de tipos, esta vez a causa de un bucle que trata de reproducir lo que hace la función `sum`:

```julia
function suma(valores)
    y = 0
    for x in valores
        y += x
    end
    return y
end
```

En este caso, la variable `y` se define inicialmente como un número del tipo de `0` (un `Int`), pero una vez se entra en el bucle, se le asignan nuevos valores que pueden ser de otro tipo, dependiendo del tipo de los elementos contenidos en `valores`. Así pues, tampoco se podrá saber a priori de qué tipo será finalmente `y`.

Cuando alguna operación dentro de una función no da un resultado de tipo estable, dicha función no podrá compilarse. Esto no significa que no se vaya a poder ejecutar, sino que no se verá acelerada gracias a la compilación de las instrucciones a bajo nivel. Dependiendo del papel que juegue la función, este problema puede ser relevante y valdrá la pena cuidar la estabilidad de los tipos, o podrá pasarse por alto.

Un recurso para ayudar a que las funciones sean de tipo estable, es forzar que las variables generadas sean de un tipo consistente en bloques condicionales y en bucles, más o menos como se hace al declarar los tipos en C o Java. Por ejemplo, se puede forzar que el número asignado a `z` sea un `Float64`, escribiendo `z = Float64( ... )`, o `z::Float64 = ...`.

También se puede forzar que el resultado devuelto por una función determinada sea de un tipo determinado, anotando la definición de la función. Por ejemplo, definiendo una función como `fun(x)::Int` se fuerza que el valor devuelto se convierta al tipo `Int`.

## Métodos paramétricos

Los tipos requeridos en los métodos de una función, además de declararse explícitamente, también pueden describirse tras la palabra `where` después de definir los argumentos. Las dos siguientes declaraciones son equivalentes:

```julia
function fun(x::Real)
    # código de la función
end

function fun(x::T) where {T <: Real}
    # código de la función
end
```

La expresión `T <: Real` significa "`T` es el tipo `Real`" (o dado que `Real` es un tipo abstracto, "`T` es un subtipo de `Real`"; véase la sección sobre [tipos de elementos](5-arrays.md#Tipos-de-elementos) en el capítulo 5). Obviamente, en este caso no parece muy práctica esta forma alternativa de señalar el tipo del argumento. Pero hay otras situaciones en las que sí resulta útil. Por ejemplo, hay casos en los que el tipo o conjunto de tipos a especificar tienen una definición muy larga, y esta es una forma de evitar que la declaración de los argumentos se alargue en exceso (sobre todo si hay varios argumentos).

Pongamos el caso de una función llamada `siguiente`, de la que queremos definir un método específico para números enteros y otro para caracteres de texto. Los distintos tipos de números enteros se encuentran englobados por el tipo abstracto `Integer`, y también existe un tipo `AbstractChar` para referirse a todos los tipos de caracteres. Sin embargo no existe un tipo abstracto para la unión de estos dos, así que tenemos que recurrir a una declaración explícita de esa unión, como `Union{<:Integer, <:AbstractChar}`. De este modo, la función `siguiente` podría definirse como sigue:

```@example c9
function siguiente(x::T) where {T <: Union{<:Integer, <:AbstractChar}}
    return x + 1
end
```
```@repl c9
siguiente(1)
siguiente('a')
```

!!! note

    `Union{<:Integer, <:AbstractChar}` significa "la unión de los tipos `Integer`, `AbstractChar`, *y también los subtipos* comprendidos por ellos. Escribir `Union{Integer, AbstractChar}` no hubiera funcionado, porque esa definición no incluye los subtipos, que es lo que aplicará normalmente. Por ejemplo, al llamar `siguiente(1)` se hubiera buscado el método para valores de tipo `Int`, que es un subtipo de `Integer` pero no coincide con `Integer` ni con `AbstractChar`. 


Por otro lado, los métodos paramétricos también son útiles para poder operar con los tipos de los argumentos. Por ejemplo, la función `mismotipo` que se define a continuación devuelve `true` si sus dos argumentos son del mismo tipo, y `false` en caso contrario --sean cuales sean esos tipos, que no hace falta concretar--.

```@example c8
function mismotipo(x::T1, y::T2) where {T1, T2}
    return (T1 == T2)
end
```
```@repl c8
mismotipo(1, 2)
mismotipo(1, 2.0)
```

A modo de curiosidad, se muestra una definición alternativa de la misma función, a través de dos métodos distintos: uno en el que se especifica que los dos argumentos sean del mismo tipo `T`, y otro genérico para todos los demás casos. Nótese que como no se procesan los valores de los argumentos, sino solo sus tipos, ni siquiera hace falta señalar nombres de variables para asignarlos.

```julia
mismotipo(::T, ::T) where {T} = true
mismotipo(_, _) = false
```

## Variables globales y locales

Dentro de las funciones se puede distinguir entre variables "locales" y las "globales".[^3] Normalmente el tratamiento de estas variables no reviste grandes complicaciones, y basta con tener en cuenta los conceptos básicos mencionados en la [sección correspondiente del capítulo 3](3-funciones-control.md#Cuerpo-de-la-función-variables-locales-y-globales-1). Sin embargo hay algunas situaciones particulares que pueden dar lugar a confusión, por lo que a continuación se explica esta cuestión en detalle.

[^3]: Utilizamos aquí el término "variables" por simplificar, para referirnos a cualquier variable, constante, función u otro tipo de objeto de datos.

Los contextos (*scopes* en ingles) son los fragmentos de código en los que "viven" las distintas variables de un programa, es decir, donde se reconocen sus nombres y se puede operar con ellas. Una variable dada puede pertenecer a un contexto global o a uno local.

Aunque esta nomenclatura puede hacer pensar que el contexto global es único, en una sesión de Julia pueden manejarse varios contextos globales simultáneamente, aunque en lo que sigue solo vamos a ocuparnos de uno de ellos, el llamado `Main`. Durante una sesión de trabajo interactiva, cada vez que creamos una variable, por ejemplo mediante una asignación como `x = 1`, la variable toma este contexto, y decimos que es una "variable global".

!!! tip "Nombre de los contextos"

    Los contextos globales siempre tienen un nombre, como es el caso de `Main`, que puede usarse para designar a los objetos contenidos en él. A esta variable `x` que pertenece a `Main` podría hacérsele referencia como `Main.x`.
    
Los contextos locales vienen definidos por los límites de distintas estructuras, entre las que se cuentan las funciones, los bucles, los bloques `try-catch` y las expresiones `let` (véase la sección del manual de Julia sobre el [contexto de las variables](https://docs.julialang.org/en/v1/manual/variables-and-scoping/) para más detalles). En un contexto local, las variables globales del contexto circundante conviven con variables locales, más efímeras, que no perviven más allá de la ejecución de la función o de cada iteración del bucle en cuestión, ni se puede acceder a ellas "desde fuera".

Las variables que tienen carácter local son:

* En el caso de las funciones y las expresiones `let`, los argumentos de entrada.
* En los bucles `for`, las variables usadas como iteradores.
* En todos los contextos locales, las variables a las que se les asigna algún valor. (Por ejemplo con una instrucción como `x = 1` escrita dentro de la función o bucle en cuestión).

Los contextos locales siempre están dentro de uno global. Pero a menudo también se dan contextos locales anidados entre sí, como un bucle dentro de una función. Pongamos, por ejemplo esta función para construir una [serie de Fibonnaci](https://es.wikipedia.org/wiki/Sucesión_de_Fibonacci) de longitud `n`:

```julia
fib_iniciales = (Int[], [0], [0,1])

function fibonnaci(n)
    if n < 3
        return fib_iniciales[n+1]
    end
    # sigue si n >= 3
    fib = zeros(Int, n)
    fib[2] = 1
    for i = 3:n
        fn1 = fib[i-1]
        fn2 = fib[i-2]
        fib[i] = fn1 + fn2
    end
    return fib                                               
end
```

Aunque se trata de un código muy poco optimizado, nos sirve para explicar cómo funcionan los contextos anidados. Tenemos una variable global, `fib_iniciales`, definida fuera de la función, con los vectores a devolver para los valores de `n` más bajos. Todas las demás variables son locales:

* En el contexto de la función `fibonnaci` se crean las variables `n` (argumento de entrada) y `fib` (asignada en la quinta línea).
* En el contexto del bucle, dentro de la función, se crean las variables `i` (el iterador), `fn1` y `fn2`.

Cada variable es reconocible por todo el código dentro de los límites de su contexto. Así pues, `i`, `fn1` y `fn2` pueden usarse dentro del bucle, pero al terminar cada iteración, esas variables se destruyen; una vez acabado el bucle, ninguna de ellas podría usarse en el resto de la función. Por otro lado, `n` y `fib` puede usarse en cualquier punto de la función, incluyendo dentro del bucle, con total libertad, pero fuera de la función es como si no existieran. Finalmente, la global `fib_iniciales` es visible por todo el código, dentro y fuera de la función.

### Coincidencia de nombres en distintos contextos

Como las variables de un contexto local solo "viven" dentro del mismo, no es ningún problema definir variables con el mismo nombre en distintos bucles, funciones, etc. Se puede escribir `x = 1` en una función y `x = "abc"` en otra, sin que haya ningún tipo de interferencia entre ellas. Dicho en términos más técnicos, cada contexto local tiene su propio "espacio de nombres".

Pero además, el espacio de nombres de un contexto local también es independiente del de su contexto global. Esto significa que a una variable local se le puede dar el mismo nombre que a otra de su conexto global, sin que una afecte a la otra. Cuando se escribe `x = 1` dentro de una función, la variable `x` para esa función será una nueva variable local, y se ignorará cualquier otra `x` que pudiera existir en el contexto global. Por verlo con un ejemplo sencillo:

```@repl
x = 1
function incrementar(x)
    x += 1
    return x
end
incrementar(x)
x
```

En este ejemplo la variable `x` de la función es una variable local --introducida como argumento--. Por eso la `x` global, definida al principio con el valor `1`, permanece inalterada aunque la `x` local se cambie dentro de la función.

!!! note

    Esta independencia de nombres se da solo entre el contexto global y uno local contenido en él, *no* entre contextos locales anidados. Si en una función se escribe `x = 1` y en un bucle dentro de la misma se escribe `x = 2`, ambas líneas harán referencia a la misma `x` local, y la segunda sobreescribirá la primera.
    
Si por algún motivo particular se desea crear o redefinir una variable global en un contexto local, esta debe identificarse explícitamente como global. Hay dos maneras de hacerlo:

* Declarándola como `global x` antes de utilizarla.
* Identificándola con el nombre del contexto, como `Main.x`. Esta alternativa tiene la ventaja de que `Main.x` puede convivir con una variable `x` local.

También se podría escribir `local x` para declarar explícitamente que `x` es una variable local. Esto no es generalmente necesario dentro de los contextos locales, pero puede ayudar a evitar confusiones cuando hay coincidencia de nombres.

### Conflictos de nombres locales y globales en el REPL

Para programar de foma eficiente es recomendable encapsular la mayor cantidad de operaciones posibles en funciones, lo cual minimiza el uso de variables globales. También se aconseja no redefinir las variables globales dentro de las funciones, lo cual reduce la necesidad de declarar variables globales dentro de los contextos locales.

Sin embargo, cuando se están prototipando programas, o haciendo análisis sencillos, a menudo se hacen operaciones de forma interactiva, en el REPL, que producen variables en el contexto global `Main`. Podría darse, por ejemplo, el caso en que quisiéramos probar de forma interactiva la secuencia de operaciones usadas para calcular el término `n`-ésimo de la serie de Fibonnaci:


```@repl
fib = 1
fib1 = 0
n = 5
for i = 3:n
    fib += fib1
    fib1 = fib
end
```

Dentro de una función este código funcionaría sin problemas, pero cuando trabajamos en el REPL, `fib` y `fib1` se crean primero como variables globales, y luego se intenta redefinirlas en un contexto local (el bucle `for`).

Según las reglas presentadas arriba, esto haría que `fib` y `fib1` se considerasen variables distintas dentro y fuera del bucle, y el código no funcionaría como dentro de una función. Pero como se trata de una situación habitual al trabajar de forma interactiva, en el REPL se hace una excepción y las reglas se cambian para que el comportamiento del código sea más parecido a lo que ocurre dentro de una función.

Concretamente, en un caso como este se asume que `fib` y `fib1` dentro del bucle hacen referencia a las variables globales del mismo nombre, aunque se redefinan en el código del contexto local --mostrando un *warning* para avisar de la posible inconsistencia--. Esta excepcional inversión de las reglas facilita que se pueda "copiar y pegar" código de la REPL al interior de las funciones, a pesar de que los contextos sean distintos.

!!! warning "Diferencias entre versiones de Julia"

    Esta regla especial para facilitar el uso de bucles en el REPL se introdujo en la versión 1.5 de Julia. En versiones anteriores, entre la 1.0 y la 1.4, habría que declarar explícitamente a `fib` y `fib1` como `global` dentro del bucle.

## Sumario del capítulo

En este capítulo se han explicado cómo se definen y usan las funciones anónimas, y cómo se puede hacer que una misma función tenga múltiples métodos, dependiendo de tipos de variables que se pasen como argumentos. También se ha explicado el concepto de "estabilidad de tipos", y el funcionamiento de los contextos de variables globales y los locales, introducidos por funciones y otras estructuras.

Por otro lado, se han visto algunas herramientas nuevas como:

* El módulo `Dates` para trabajar con variables que representan fechas.
* Los bloques `begin`-`end` y las expresiones `let`.
* La función `mapslices` para aplicar otra función a lo largo de porciones de un *array*.

