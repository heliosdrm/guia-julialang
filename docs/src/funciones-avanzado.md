# Capítulo 8. Uso avanzado de funciones

La forma en la que Julia maneja las funciones es probablemente uno de sus aspectos más destacables. En este capítulo vamos a ver las distintas formas de funciones en Julia y de trabajar con ellas eficientemente, para sacarles el máximo provecho. En lo que sigue se asume que ya se conocen algunos conceptos, como la forma habitual de definir una función y sus argumentos de entrada y salida, así como los distintos contextos de variables (global vs. local), que se explican en el [capítulo 3](funciones-control.md).

## No dejes las funciones para el final

Cuando se comienza a trabajar en un proyecto con datos que se han de procesar o analizar, lo primero que se suele hacer es explorar los datos, ver algunos de muestra,  [representarlos en gráficos](graficos.md), etc. Esto suele hacerse en un entorno interactivo, que da mucha flexibilidad al usuario para crear nuevas variables, modificarlas de forma arbitraria, y hacer operaciones paso a paso, viendo lo que pasa después de cada operación antes de proceder a la siguiente.

Las funciones, por otro lado, están pensadas para un flujo de trabajo mucho más sistemático, con una secuencia de operaciones concreta aplicadas a un conjunto cerrado de variables, que se van generando y modificando conforme a un guión predefinido. Esto podría hacer pensar que no vale la pena crear funciones hasta que los algoritmos a emplear en el proyecto estén suficientemente claros, o al menos hasta que se hayan definido rutinas lo suficientemente largas y repetitivas como para que guardar el código de la función suponga un ahorro de trabajo significativo.

Sin embargo, en general es ventajoso y una buena práctica empezar a encapsular el código en pequeñas funciones desde casi el principio, y en particular esta es una práctica que en Julia proporciona varios beneficios. La ventaja más obvia, que es independiente del lenguaje de programación empleado, es que encapsular secuencias de operaciones en funciones hace que los pasos realizados durante el análisis, incluso en las primeras fases exploratorias, sean más repetibles y menos propensos a errores. Además, esto suele hacer que el código sea más conciso, más modular y fácil de leer y entender más adelante por el propio autor o por otros.

En el caso de Julia, otra ventaja es que al tener delimitado el conjunto de variables a manipular y una secuencia clara de operaciones, el código de las funciones normalmente se puede *compilar*, es decir transformarlo en una serie de instrucciones de bajo nivel ("código máquina") que el ordenador puede ejecutar de forma muy eficiente. Por lo tanto, las operaciones escritas dentro de una función a menudo se ejecutan muy rápidamente --excepto la primera vez, en la que el código se ha de interpretar y compilar--. Esto es la famosa "compilación a tiempo real" que suele destacarse como uno de los puntos fuertes de Julia.

Un motivo por el que mucha gente demora el paso de pasar el código a funciones es que estas no muestran por defecto lo que pasa dentro de las mismas. Esto es deseable cuando ya se tiene seguridad de que las operaciones intermedias son correctas, pero al comienzo es bueno prestar atención a los detalles y los pasos intermedios. Ese es un buen motivo para no apresurarse a escribir funciones que sean muy complejas, con decenas de líneas de código que puedan llevar por varios caminos; de hecho, es recomendable evitar ese tipo de funciones en cualquier momento, no solo al principio. Sin embargo, trabajar con funciones pequeñas desde el primer momento ayuda precisamente a que el código no se acumule en enormes funciones, y que los programas finales sean más sencillos.

Por otro lado, hay diferentes técnicas de *debugging* que permiten detenerse en puntos intermedios de las funciones, explorar las variables locales e incluso manipularlas. Estas técnicas, así como otras como el *unit testing*, que se comentarán en un capítulo dedicado a este tema son muy útiles, y resultan especialmente eficaces cuando se trabaja con funciones sencillas. 

## Formas de definir una función

En el capítulo introductorio a las funciones se han mostrado dos formas habituales de definir una función. Utilizando el mismo ejemplo de la suma aritmética que se presentó en ese capítulo, estas dos formas son:

```julia
# 3. Forma "estándar"
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

Las funciones anónimas se usan a menudo de forma auxiliar, dentro de otras funciones. Por ejemplo, la función `findfirst` da el primer índice de una colección de valores que cumplen una condición, y esta condición puede venir dada por una función que devuelve un valor lógico (`true` o `false`). Así, para encontrar el primer valor par podría pasársele la función `iseven` (o `isodd` para los impares):

```@repl
findfirst(iseven, [15, 7, 12, 4, 9])
```

Pero otras condiciones no tienen una función predefinida, y tenemos que crearla *ad hoc*. Si esa función no tiene un uso específico más allá de ese contexto, no vale la pena crearla de la forma habitual, y resulta práctico pasarle una función anónima. Por ejemplo, para encontrar el primer valor menor de 10:

```@repl
findfirst(x -> (x < 10), [15, 7, 12, 4, 9])
```

Cuando se definen funciones que utilizan otra función como argumento de entrada, es práctica habitual en Julia hacer como en este ejemplo, que la función auxiliar ocupe el lugar del primer argumento. En esos casos, Julia facilita una forma cómoda de pasar funciones anónimas más complejas, incluso con varias líneas; consiste en escribir el código de la función anónima *después* de la función que la utiliza, tras la palabra `do` y el nombre de los argumentos de entrada. El ejemplo anterior tomaría esta forma:

```julia
findfirst([15, 7, 12, 4, 9]) do x
    x < 10
end
```

Para una operación tan sencilla, esta forma de utilizar funciones anónimas no aporta una gran ventaja, pero esto cambia cuando se trabaja con rutinas más complejas. Un caso de uso habitual es el de las operaciones de escritura sobre un archivo que se abre con la función `open`, el cual se ha visto en el capítulo anterior:

```julia
open("archivo.txt", "w") do io
    # Múltiples operaciones de escritura
end
```

Aquí se está aprovechando un método especial de la función `open`, que toma como primer argumento una función con las operaciones de escritura, aunque en la práctica estemos "sacando" el código de esas operaciones fuera de los argumentos de `open`.

Finalmente, cabe señalar que las funciones anónimas también se pueden asignar a una variable, y utilizarlas como funciones "con nombre", por ejemplo:


```julia
suma_aritmetica = (n) -> n*(n+1)/2
suma_aritmetica(3) # == 6, igual que con una función "normal"
```

## Métodos

Una misma función puede hacer cosas distintas, según los argumentos que se le pasen. A cada variante de una función se le llama un "método" de la misma, y en Julia es muy habitual que las funciones tengan más de un método.

De hecho, cuando se define una función con argumentos opcionales, se están definiendo distintos métodos de la misma (uno que requiere que se le pasen todos los argumentos, otro que no requiere ninguno, etc.). Así, retomando el ejemplo del capítulo introductorio que se usó para explicar los argumentos con valores por defecto:

```@repl
incrementar(x, inc=1) = x + inc
```

La descripción de esta función `incrementar` señala que tiene dos métodos, porque hubiera sido lo mismo (aunque no tan compacto) definir explícitamente dos métodos de la función con el nombre `incrementar`:

```julia
incrementar(x, inc) = x + inc
incrementar(x) = x + 1
```

Los métodos de una función también pueden tratar de forma completamente diferente los distintos argumentos que se le pasan. Por ejemplo, en el primer capítulo presentamos la función [`gauss_diasemana`](primerospasos.md#gauss_diasemana) para determinar el día de la semana que corresponde a una fecha determinada, dada por los números del día, el mes y el año:

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
    año = month(fecha)
    return gauss_diasemana(dia, mes, año)
end

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

!!! note

    `AbstractString` es, como indica su nombre, un tipo abstracto definido para referirse tanto a objetos de tipo `String` como a otros que también puedan interpretarse y manipularse como cadenas de texto. Normalmente es recomendable diseñar funciones con métodos que sean todo lo genéricos que se pueda, es decir que no estén demasiado restringidos a unos tipos de argumentos concretos. Esto ayuda a que las funciones sean útiles en aplicaciones más amplias que las que se hubieran podido pensar en un principio. Si por alguna razón resulta necesario definir métodos condicionados por el tipo de variables, como en el ejemplo, es mejor utilizar tipos abstractos que recojan la mayor cantidad posible de casos de uso. 

!!! note

    A la hora de definir métodos condicionados por el tipo de variables solo cuentan los posicionales, al igual que ocurre con el número de argumentos. Es válido cualificar el tipo de los argumentos con nombre, p.ej. `fun(a, b; c::Int=1)`, pero eso solo sirve para obligar a que el argumento con nombre `c` sea de tipo `Int` (de lo contrario se emitirá un error). Esa definición  no podría coexistir con, por ejemplo, `fun(a, b; c::Float64=1.0)`.

## Estabilidad de tipos

Algunos lenguajes de programación como C, Java y similares, requieren que al definir funciones se declaren los tipos de todas los argumentos de entrada --y también el del valor devuelto por la función, así como los de *todas las variables* que se usan en el cuerpo de una función o un programa--. Tener claramente definidos los tipos de variables a usar es importante a la hora de compilar una función o un programa (traducir las instrucciones al "lenguaje de la máquina"), pues permite definir de forma correcta y optimizada las operaciones a realizar a bajo nivel, reservar la cantidad de memoria adecuada para las variables, etc.

Por ese motivo, las personas con experiencia en esos lenguajes de programación pueden sentirse inclinadas a anotar los tipos de todos los argumentos en las funciones de Julia. Sin embargo, hay que insistir en que esto no es necesario, y ni siquiera deseable. Como se ha señalado arriba, es bueno usar métodos genéricos, pues resultan más flexibles y fáciles de extender que los que son muy específicos. Y omitir los tipos de variables requeridos por los métodos no significa que el código no se pueda compilar tal como se hace en C, Java, etc.

De hecho, a bajo nivel Julia genera un código distinto y específico para cada combinación concreta de tipos de argumentos, se hayan definido estos de forma genérica o no. Por ejemplo, si una función es declarada como `f(a, b)`, Julia generá un código determinado para el caso en que tanto `a` como `b` sean números de tipo `Int`, otro cuando `a` sea un `Int` y `b` un `Float64`, un distinto cuando `a` sea un `String`... y así para cualquier combinación de dos tipos que pueda ser procesada por las instrucciones escritas en la función.

Como las combinaciones posibles de tipos de argumentos (que potencialmente son infinitas) no pueden determinarse a priori, esta interpretación del código se hace "a demanda", cada vez que se llama a la función `f` con una combinación nueva de tipos para `a` y `b`. Pongamos que en una sesión de Julia ya se ha utilizado `f` con dos argumentos de tipo `Int`. Esto sería como si se hubiera definido un método `f(a::Int, b::Int)`, de tal manera que si se vuelve a llamar a `f` con otros dos argumentos del mismo tipo (aunque sea con otros valores), ese método ya estaría disponible para su uso directo.

!!! note

    Esto ocurre a bajo nivel, de forma transparente para el usuario, aunque no del todo imperceptible. De hecho, esta es una de las razones por las que Julia es eficiente para hacer programas complejos, con numerosísimas operaciones, pero que pueden costar de "arrancar" comparado con otros lenguajes: la primera vez que Julia se encuentra con una función y unos tipos particulares para sus argumentos de entrada, tiene que definir el código de bajo nivel para esos tipos y compilarlo. Pero una vez hecho esto, repetir la operación con nuevos argumentos del mismo tipo es a menudo mucho más rápido.

Para que Julia pueda compilar las funciones y sacar el máximo rendimiento de ellas, lo más importante no es definir los tipos de los argumentos de entrada, sino asegurarse de que las operaciones dentro del cuerpo de la función dan resultados con "tipos estables". Esto significa que para cualquier operación, si las variables con las que se opera son de unos tipos concretos, el resultado sea también de un tipo concreto, y predecible incluso sin conocer los valores.

!!! note

    La estabilidad de tipos es la razón por la que, por ejemplo, la división de los números enteros `6/3` da como resultado el número decimal `2.0`, aunque este caso particular bien pudiera haber sido representado como otro entero. (Para obtener el entero `2` se podría utilizar `div(6, 3)`.) Por el mismo motivo, la raíz cuadrada (`sqrt`) falla cuando se aplica a un número real negativo, en lugar de dar un número complejo. (Para obtener la raíz imaginaria de `-1`, por ejemplo, habría que pasarlo como un número complejo: `sqrt(-1 + 0im)` o `sqrt(Complex(-1))`.) 

En general, todas las operaciones y funciones básicas cumplen este requisito. Tomando la multiplicación `z = x * y` como ejemplo:

* Si `x` e `y` son dos números de cualquier tipo común, `z` será un número del mismo tipo.
* Si `x` e `y` son dos tipos distintos de números enteros, p.ej. `Int32` e `Int64`, `z` será del tipo de entero que pueda representar los valores de ambos (en este caso `Int64`).
* Si `x` es un `Float64` e `y` es un *array* de `Int`s, `z` será un *array* de `Float64`.
* Si `x` e `y` son dos cadenas de texto (`String`s), `z` será otro `String` que concatena `x` seguido de `y`.
* Etc.

Del mismo modo, una función que conste únicamente de una serie de operaciones de tipos estables, será ella misma una función de tipo estable. El problema puede darse con estructuras de código como los bloques condicionales o los bucles, que pueden añadir incertidumbre al tipo de los resultados. Por ejemplo, en la siguiente función:

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

Otro ejemplo de inestabilidad de tipos, esa vez a causa de un bucle:

```julia
function sumaserie(valores)
    y = 0
    for (k, x) in valores
        y += k * x
    end
    return y
end
```

En este caso, la variable `y` se define inicialmente como un número del tipo de `0` (un `Int`), pero una vez se entra en el bucle, se le asignan nuevos valores que pueden ser de otro tipo, dependiendo del tipo de los elementos contenidos en `valores`. Así pues, tampoco se podrá saber a priori de qué tipo será finalmente `y`.

Cuando alguna operación dentro de una función no da un resultado de tipo estable, dicha función no podrá compilarse. Esto no significa que no se vaya a poder ejecutar, sino que no se verá acelerada gracias a la compilación de las instrucciones a bajo nivel. Dependiendo del papel que juegue la función, este problema puede ser relevante y valdrá la pena cuidar la estabilidad de los tipos, o podrá pasarse por alto.

Un recurso para ayudar a que las funciones sean de tipo estable, es forzar que las variables generadas sean de un tipo consistente en bloques condicionales y en bucles, más o menos como se hace al declarar los tipos en C o Java. Por ejemplo, se puede forzar que el número asignado a `z` sea un `Float64`, escribiendo `z = Float64( ... )`, o `z::Float64 = ...`.

También se puede forzar que el resultado devuelto por una función determinada sea de un tipo determinado, anotando la definición de la función. Por ejemplo, definiendo una función como `fun(x)::Int` se fuerza que el valor devuelto se convierta al tipo `Int`.

## Métodos paramétricos

Los tipos requeridos en los métodos de una función, además de declararse explícitamente, también pueden describirse tras la palabra `where` después de definir la función. Las dos siguientes declaraciones son equivalentes:

```julia
function fun(x::Real)
    # código de la función
end

function fun(x::T) where {T <: Real}
    # código de la función
end
```

La expresión `T <: Real` significa "`T` es el tipo `Real`" --o como `Real` es un tipo abstracto, "`T` es un subtipo de `Real`"-- (véase la sección sobre [tipos de elementos](arrays.md#Tipos-de-elementos) en el capítulo 5). Obviamente, en este caso no parece muy práctica esta forma alternativa de señalar el tipo del argumento. Pero hay otras situaciones en las que sí resulta útil. Por ejemplo, hay casos en los que el tipo o conjunto de tipos a especificar tienen una definición muy larga, y esta es una forma de evitar que la declaración de los argumentos se alargue en exceso (sobre todo si hay varios argumentos).

Pongamos el caso de una función llamada `siguiente`, de la que queremos definir un método específico para números enteros o un caracteres de texto. Los distintos tipos de números enteros se encuentran englobados por el tipo abstracto `Integer`, y también existe un tipo `AbstractChar` para referirse a todos los tipos de caracteres. Sin embargo no existe un tipo abstracto para la unión de estos dos, así que tenemos que recurrir a una declaración explícita de esa unión, como `Union{<:Integer, <:AbstractChar}`. De este modo, la función `siguiente` podría definirse como sigue:

```@example c9
function siguiente(x::T) where {T <: Union{<:Integer, <:AbstractChar}}
    return x + 1
end
```
```@repl c9
siguiente(1)
siguiente('a')
```

!!! tip

    `Union{<:Integer, <:AbstractChar}` significa "la unión de los tipos `Integer`, `AbstractChar`, *y también los subtipos* comprendidos por ellos. Escribir `Union{Integer, AbstractChar}` no hubiera funcionado, porque esa definición no incluye los subtipos, que es lo que aplicará normalmente. Por ejemplo, al llamar `siguiente(1)` se hubiera buscado el método para valores de tipo `Int`, que es un subtipo de `Integer` pero no coincide con `Integer` ni con `AbstractChar`. 


Por otro lado, los métodos paramétricos también son útiles para poder operar con los tipos de los argumentos. Por ejemplo, la función `mismotipo` que se define a continuación devuelve `true` si sus dos argumentos son del mismo tipo, y `false` en caso contrario --sean cuales sean esos tipos, que no hace falta concretar--.

```@example c9
function mismotipo(x::T1, y::T2) where {T1, T2}
    return (T1 == T2)
end
```
```@repl
mismotipo(1, 2)
mismotipo(1, 2.0)
```

A modo de curiosidad, se muestra una definición alternativa de la misma función, a través de dos métodos distintos: uno en el que se especifica que los dos argumentos sean del mismo tipo `T`, y otro genérico para todos los demás casos. Nótese que como no se procesan los valores de los argumentos, sino solo sus tipos, ni siquiera hace falta señalar nombres de variables para asignarlos.

```julia
mismotipo(::T, ::T) where {T} = true
mismotipo(_, _) = false
```

## Variables globales y locales

Dentro de las funciones se puede distinguir entre variables "locales" y las "globales". Normalmente el tratamiento de estas variables y objetos no reviste grandes complicaciones, y basta con tener en cuenta los conceptos básicos mencionados en la [sección correspondiente del capítulo 5](funciones-controlmd#Cuerpo-de-la-función-variables-locales-y-globales-1). Sin embargo hay algunas situaciones particulares que pueden dar lugar a confusión, por lo que a continuación se explica esta cuestión en detalle.

Los contextos (*scopes* en ingles) son los fragmentos de código en los que "viven" las distintas variables de un programa, es decir, donde se reconocen sus nombres y se puede operar con ellas. (Utilizamos aquí el término "variables" para referirnos a cualquier variable, constante, función u otro tipo de objeto de datos.) Una variable dada puede pertenecer a un contexto global o a uno local.

Aunque esta nomenclatura puede hacer pensar que el contexto global es único, en una sesión de Julia pueden manejarse varios contextos globales simultáneamente, aunque en lo que sigue solo vamos a ocuparnos de uno de ellos, el llamado `Main`. Durante una sesión de trabajo interactiva, cada vez que creamos una variable, por ejemplo mediante una asignación como `x = 1`, la variable toma este contexto, y decimos que es una "variable global".

!!! tip Nombre de los contextos

    Los contextos globales siempre tienen un nombre, como es el caso de `Main`, que puede usarse para designar a los objetos contenidos en él. A esta variable `x` que pertenece a `Main` podría hacérsele referencia como `Main.x`.
    
Los contextos locales vienen definidos por los límites de distintas estructuras, entre las que se cuentan las funciones, los bucles y los bloques `try-catch` (véase la sección del manual de Julia sobre el [contexto de las variables](https://docs.julialang.org/en/v1/manual/variables-and-scoping/) para más detalles). En un contexto local, las variables globales del contexto circundante conviven con variables locales, más efímeras, que no perviven más allá de la ejecución de la función o de cada iteración del bucle en cuestión, ni se puede acceder a ellas "desde fuera".

Las variables que tienen carácter local son:

* En el caso de las funciones, los argumentos de entrada.
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

* En el contexto de la función `fibonnaci` se crean las variables `n` (argumento de entrada) y `fib` (asignada en la primera línea).
* En el contexto del bucle, dentro de la función, se crean las variables `i` (el iterador), `fn1` y `fn2`.

Cada variable es reconocible por todo el código dentro de los límites de su contexto. Así pues, `i`, `fn1` y `fn2` pueden usarse dentro del bucle, pero al terminar cada iteración, esas variables se destruyen; una vez acabado el bucle, ninguna de ellas podría usarse en el resto de la función. Por otro lado, `n` y `fib` puede usarse en cualquier punto de la función, incluyendo dentro del bucle, con total libertad, pero fuera de la función es como si no existieran. Finalmente, la global `fib_iniciales` es visible por todo el código, dentro y fuera de la función.

### Coincidencia de nombres en distintos contextos

Como las variables de un contexto local solo "viven" dentro del mismo, no es ningún problema definir variables con el mismo nombre en distintos bucles, funciones, etc. Se puede escribir `x = 1` en una función y `x = "abc"` en otra, sin que haya ningún tipo de interferencia entre ellas. Dicho en términos más técnicos, cada contexto local tiene su propio "espacio de nombres".

Pero además, el espacio de nombres de un contexto local también es independiente del de su contexto global. Esto significa que a una variable local se le puede dar el mismo nombre que a otra de su conexto global, sin que se afecten entre ellas. Cuando se escribe `x = 1` dentro de una función, la variable `x` para esa función será una nueva variable local, y se ignorará cualquier otra `x` que pudiera existir en el contexto global. Por verlo con un ejemplo sencillo:

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

### Conflictos de nombres en el REPL

Como se ha comentado al comienzo de este capítulo, para programar de foma eficiente es recomendable encapsular la mayor cantidad de operaciones posibles en funciones, minimizando así el uso de variables globales. También se aconseja no redefinir las variables globales dentro de las funciones, lo cual reduce la necesidad de declarar variables globales dentro de los contextos locales.

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


 






```@example c3
x = [1, 2, 3]

# f1 usa la variable global x
function f1(k)
    y = k*x
    return y
end

# f2 modifica la variable global x
function f2(k)
    y = k*x
    x[1] = 0
    return y
end

# f3 usa una variable local x
function f3(k)
    x = [4, 5, 6]
    y = k*x
    return y
end

# f4 intenta redefinir la variable global x
function f4(k)
    y = k*x
    x = y
end
nothing # hide
```

La función `f1` opera con la variable global `x`, de tal manera que si esta se modifica (por ejemplo por acción de la función `f2`), su comportamiento también cambia.

```@repl c3
f1(5)
f2(5) # hace lo mismo que f1 pero cambia `x`
x
f1(5)
```

La función `f3`, sin embargo, define una variable `x` en su contexto local, que por lo tanto independiente de la variable global del mismo nombre:

```@repl c3
f3(5)
x # no ha cambiado por usar `f3`
```

Finalmente, la función `f4` da un error, ya que la asignación de valores a una variable (con el operador `=`, como en la segunda línea de la función) solo está permitida a variables locales, y esto entra en conflicto con la primera línea, donde `x` se utiliza sin haberla definido, como si fuera una variable global. (Véase la diferencia con `f2`, que no redefine la variable referida como `x`, sino que modifica los valores contenidos en la misma.)

```jldoctest c3; setup = :(f4 = (k)->(y = k*x; x = y))
julia> f4(5)
ERROR: UndefVarError: x not defined
```

Si realmente se desea que una función redefina una variable global, es necesario declararla explícitamente, como en la siguiente forma alternativa de `f4`:

```julia
function f4b(k)
    global x
    y = k*x
    x = y
end
```




## Sumario del capítulo

findfirst
findlast
findall
isodd
iseven


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

