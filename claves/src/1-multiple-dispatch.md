# Capítulo 1. *Multiple dispatch*

```@setup c1
using InteractiveUtils
f(x::Int, y::AbstractString) = 1
f(x::Real, y::String) = 2
```

Una de las características más notables de Julia es su uso de lo que se conoce como *multiple dispatch*, que en esencia significa que una misma función puede definirse de distintas maneras, según el número y el tipo de los argumentos que recibe. Esto es algo que puede pasar desapercibido en un principio, ya que la sintaxis de Julia no obliga a tenerlo en cuenta. Las funciones se pueden definir como secuencias de fórmulas matemáticas, sin preocuparse de cómo se representan en la memoria del ordenador los elementos de esas fórmulas, y sin plantearse significados alternativos de la función. Pero la posibilidad de alterar el comportamiento de las funciones según cómo sean los argumentos es una característica que hace a Julia un lenguaje muy expresivo (capaz de representar distintos algoritmos de forma sencilla y directa) y extensible (capaz de ampliar sus funcionalidades).

Un caso de uso muy habitual de *multiple dispatch*, que a menudo se emplea incluso sin conocer el concepto, es el de las funciones con argumentos opcionales. Por ejemplo, una función como la siguente:

```julia
incrementar(x, inc=1) = x + inc
```

A esta función se le puede llamar con solo un argumento (p.ej. `incrementar(5)`), asumiéndose que la variable `inc` tomará el valor `1` por defecto. Esto es lo mismo que escribir explícitamente los dos métodos siguientes:

```julia
incrementar(x, inc) = x + inc
incrementar(x) = x + 1
```

Pero hay otros mecanismos más sofisticados y versátiles para ampliar los usos de una función, que desarrollaremos a lo largo de este capítulo.

## Tipos de objetos

En todo esto, un concepto central son los tipos (*types* en inglés). Se trata de una propiedad que tiene todo "objeto" representado en memoria que se pueda asignar a una variable, y se puede consultar con la función `typeof`. No es posible dar un listado completo de los tipos de variables u otros objetos que tiene Julia. No solo se trata de que haya muchos; es que además la definición de nuevos tipos es un recurso empleado por numerosos paquetes para ampliar las capacidades del lenguaje, por lo que en la práctica se puede decir que el número de tipos existentes es indefinido.

Incluso limitándonos al módulo básico y las librerías estándar hay muchísimos tipos de variables. Solo entre los tipos númericos definidos en `Base` tenemos todos los representados en el siguiente esquema:

```
Number ─┬───────────────────────────────┤ Complex
        │
        └ Real ─┬───────────────────────┤ Rational
                │
                ├─ AbstractIrrational ──┤ Irrational
                │
                ├─ AbstractFloat ───────┤ BigFloat
                │                       │ Float64
                │                       │ Float32
                │                       │ Float16
                │
                └─ Integer ─┬───────────┤ Bool
                            │
                            ├─ Signed ──┤ BigInt
                            │           │ Int128
                            │           │ Int64
                            │           │ Int32
                            │           │ Int16
                            │           │ Int8
                            │
                            └─ Unsigned ┤ UInt128
                                        │ UInt64
                                        │ UInt32
                                        │ UInt16
                                        │ UInt8
```

Solo los tipos más bajos de esta jerarquía, los que hay más a la derecha del esquema, son tipos "concretos", es decir tipos que definen una estructura de datos concreta. Siempre que utilicemos la función `typeof` con un dato numérico en Julia, el resultado será uno de esos tipos. Todos los demás son tipos "abstractos", que se usan como *alias* para identificar los conjuntos de tipos concretos que tiene conectados a su derecha del esquema. El operador `<:` sirve para comprobar si un tipo dado (sea concreto o abstracto) es un subtipo de otro. Así, por ejemplo:

```@repl
typeof(1) # El resultado es uno de los tipos concretos
typeof(1) == Integer # Integer no es un tipo concreto
typeof(1) <: Integer # Pero es un supertipo de `Int64`
``` 

Los tipos abstractos son útiles para poder identificar de forma sencilla tipos distintos que en ciertos contextos no se diferencian. También existe un supertipo `Any` que engloba todos los demás, de tal manera que `typeof(x) <: Any` siempre es cierto para cualquier `x`.

Para explorar la jerarquía de los tipos existen las funciones `subtypes`, que devuelve un vector con los subtipos inmediatamente debajo de un tipo abstracto cualquiera, y `supertype` que devuelve el tipo que hay por encima de otro:

```@repl
subtypes(AbstractFloat)
subtypes(Float64) # Es un tipo concreto, sin subtipos
supertype(Bool)
```

## Funciones y métodos

Los conceptos de "función" y "método" en Julia están muy relacionados, y en ocasiones se intercambian creando cierta confusión, por lo que vamos a comenzar exponiendo con claridad qué es cada una de estas dos cosas, y en qué se diferencian.

En abstracto, tanto las funciones como los métodos son entidades que representan conjuntos de operaciones con unas posibles entradas y salidas, a las que se les puede "llamar" para ejecutarlas. En términos prácticos, lo que podríamos decir es que la función es el objeto al que se llama, y el método es el que se ejecuta, pudiendo haber múltiples métodos disponibles para cada función, y escogiéndose el que corresponde a los argumentos introducidos.

Así, cuando escribimos algo como `z = f(x, y)`, el símbolo `f` identifica una función. De hecho `f` es, técnicamente, un objeto perteneciente al tipo abstracto `Function`, aunque cada función tiene su propio tipo, único y asociado al nombre de la función. Vemos un ejemplo con una función como la de la división entera `div`:

```@repl
T = typeof(div)
supertype(T)
```

Por otro lado, cuando escribimos un código como:

```julia
function f(x::Int, y::String)
    # una serie de operaciones ...
end
```

... lo que se ha definido ahí es un *método* de la función `f` asociado a dos argumentos, el primero de los cuales (`x`) se ha anotado como de tipo `Int`, y el segundo (`y`) como `String`. Podríamos definir muchos otros métodos con instrucciones diferentes junto al anterior: con otros tipos concretos distintos, o con tipos abstractions como `Real`, `AbstractString`... o incluso `Any`. Por simplicidad, cuando se define un método con argumentos genéricos (de tipo `Any`) no hace falta anotarlos explícitamente; así `f(x, y)` sería equivalente a `f(x::Any, y::Any)`.

Las combinaciones de argumentos con tipos concretos, abstractos o no especificados son completamente libres, y también se pueden crear métodos con más o menos argumentos. Sin embargo, los argumentos con nombre no cuentan: si se definen varias versiones de una misma función con los mismos argumentos posicionales, cambiando solo los argumentos "con nombre" (p.ej. `f(a, b; c=1)` y `f(a, b; c=1, d=2)`, lo que se hará es sobreescribir el mismo método.

Además de esos métodos definidos por el usuario, también están los métodos generados automáticamente por el compilador, que dependen del conjunto específico de tipos que se pasan a una función cada vez que se le llama, y son los que realmente ejecutan las operaciones. Por ejemplo, si se introduce una orden como `f(1, "abc")`, Julia buscará el método de esta categoría asociado a la función `f` y dos argumentos de tipo `Int` y `String`, respectivamente. Si nunca se ha ejecutado esa función con esos tipos de argumentos, se buscaría el método definido por el usuario más adecuado, y su código se compilaría en ese momento, antes de ejecutarse; las siguientes veces se ejecutaría directamente el código compilado, lo cual explica por qué las primeras órdenes que se ejecutan en una sesión de Julia suelen ser sensiblemente más lentas que las siguientes --porque normalmente también incluyen la compilación *just in time* que permite acelerar el código que se ejecuta más adelante--.

Los métodos generados por el compilador siempre operan sobre conjuntos de tipos concretos, mientras que los métodos definidos por el usuario pueden estar anotados con tipos abstractos. Esto es bueno, porque permite escribir código genérico, del que hablaremos después, pero a veces dificulta la búsqueda del método que se tiene que compilar. Siguiendo con el método anterior, supongamos que hay dos métodos definidos por el usuario: `f(x::Int, y::String)`, y `f(x::Real, y::AbstractString)`, y ejecutamos dos operaciones: `f(1, "abc")` y `f(0.5, "abc")` --para esta discusión nos da igual qué es lo que tenga que hacer la función en cada caso--. Suponiendo que no hay aún ningún método compilado, lo primero que hará el compilador es buscar qué métodos definidos por el usuario podrían adecuarse a cada una de las dos operaciones, según se representa en la siguiente tabla:

|               |`f(x::Int, y::String)`|`f(x::Real, y::AbstractString)`|
|---------------|:--------------------:|:-----------------------------:|
|`f(1, "abc")`  |         X            |             X                 |
|`f(0.5, "abc")`|                      |             X                 |

Los tipos de la primera operación son compatibles con los dos métodos, mientras que segunda solo es compatible con el método definido para tipos abstractos (en particular porque el número `0.5` es un `Float64`, y `Float64 <: Real`, pero es incompatible con `Int64`). Así pues, para la segunda operación no hay duda de qué método se tiene que compilar, ¿pero cuál corresponde a la primera?

En casos como este, se aplica la regla del "método más específico": si entre todos los métodos compatibles hay uno cuyos tipos estén por debajo de los demás en la jerarquía de tipos abstractos, se escogerá ese método. En este caso, `Int <: Real` y `String <: AstractString`, por lo que el primer método es más específico y será el escogido para la primera operación.

Si no se puede encontrar un método más específico que todos los demás, se considerará que el conjunto de métodos disponibles es ambiguo y se emitirá un error aconsejando qué método adicional se debería definir. Por ejemplo, si los métodos definidos fueran `f(x::Int, y::AbstractString)` y `f(x::Real, String)`, la operación `f(1, "abc")` también sería compatible con ambos. Pero el método más específico es distinto para cada uno de los dos argumentos, por lo que no se puede dar prioridad a ninguno de los dos, y el resultado será el siguiente: 

```@repl c1
f(1, "abc")
```

## Anotación de tipos

En los ejemplos anteriores hemos visto que los tipos de los argumentos se anotan como `x::T`, donde `x` es el nombre del argumento y `T` el del tipo admitido. Las variables en el cuerpo de una función también se pueden anotar de ese modo para forzar que sean de un tipo particular, e incluso la propia función se puede anotar para especificar el tipo del valor devuelto. Podemos ver un ejemplo con las dos siguientes variaciones de la función `incrementar`, que devuelven el resultado como un número de tipo `Float64`:

```julia
function incrementar(x)
    y::Float64 = x + 1
    return y
end

function incrementar(x)::Float64
    return x + 1
end
```

En el caso de los argumentos de entrada, la anotación puede hacerse de forma abstracta usando una expresión con `where`, como en este ejemplo:

```@example c1
function intercambiartipos(x::T1, y::T2) where {T1, T2}
    return (T2(x), T1(y))
end
nothing #hide
```

Esta función admite dos argumentos de tipos cualesquiera, pero gracias a que los tenemos identificados como `T1` y `T2` podemos usarlos en el cuerpo de la función para operar con ellos (en este caso, intercambiar los tipos de las entradas):

```@repl c1
intercambiartipos(1, 2.0)
```

En la expresión `where`, además de identificar los tipos de los argumentos también se pueden definir condiciones respecto a ellos. Por ejemplo, si los dos hubieran de ser números podríamos haber especificado `where {T1<:Number, T2<:Number}, etc.

Un uso habitual de esta forma de anotar los tipos se da cuando se desea operar con colecciones (por ejemplo *arrays*) de algún conjunto de tipos. Por ejemplo, un método de la función `f` que se aplique a vectores de números reales se podría definir como:

```julia
function f(x::Vector{T}) where {T<:Real}
    ...
end
```

O de forma más compacta, podría haberse anotado como `f(x::Vector{<:Real})`, para admitir argumentos tanto de tipo `Vector{Real}` como `Vector{AbstractFloat}`, `Vector{AbstractInteger}`, y en general todos los vectores cuyos elementos sean de un subtipo de `Real`.

### Anotar tipos sin valores

Hay ocasiones en las que una operación requiere especificar una variable que en realidad no nos interesa usar, por ejemplo cuando una función devuelve una tupla con dos valores pero solo queremos uno de ellos. Para esos casos se puede utilizar la "variable de descarte" que se identifica con un guión bajo (`_`). Tomando el ejemplo de la función con salida múltiple, si la función `f` devolviese dos valores pero solo nos interesase operar con el primero, podríamos escribir:

```
a, _ = f(x)
```

Al hacer eso, el primer valor se asignaría a la variable `a`, y el segundo se descartaría, evitando así ocupar memoria con una variable que no vamos a usar.

En principio parecería absurdo que esto pueda pasar también con los argumentos de las funciones: si una función no va a usar una variable, ¿qué motivo habría para que forme parte de los argumentos de entrada? Sin embargo, a veces ocurre que con saber *el tipo* del argumento es suficiente, y su valor es realmente irrelevante. En esos casos, no hace falta siquiera escribir el guión bajo para identificar la variable; para especificar el argumento basta con la anotación del tipo.

Esta circunstancia se suele dar cuando tratamos con lo que se conoce como tipos "solitarios" (en inglés *singleton types*), que no admiten distintos valores, con lo que conociendo el tipo de la variable conocemos también su valor. Dos casos típicos son los de los tipos `Nothing` y `Missing`, que se usan para representar un objeto nulo, que "no es nada" (`nothing`) y un valor perdido (`missing`), respectivamente:

```@example c1
quiensoy(::Nothing) = println("El valor introducido es `nothing`")
quiensoy(::Missing) = println("El valor introducido es `missing`")
nothing #hide
```

```@repl c1
quiensoy(nothing)
quiensoy(missing)
```

En este grupo también se encuentran el objeto representado por los dos puntos (`:`), que se usa para indexar arrays y otros objetos semejantes; por ejemplo en `v[:,1]`, que si `v` es una matriz significaría "todos los elementos de la primera columna de `v`. Este objeto es el único valor del tipo llamado `Colon`.

Además, hay "familias de tipos" cuyas variantes específicas tampoco admiten variedad en sus valores. Podemos ver dos de ellas, las funciones y los tipos de variables, con un ejemplo práctico. Supongamos que queremos definir una función que devuelve el [elemento neutro](https://es.wikipedia.org/wiki/Elemento_neutro) de una operación sobre un conjunto de datos. Algunos ejemplos son los siguientes:

* El número cero para la suma de números reales.
* El número uno para el producto de números reales.
* Un texto vacío para la concatenación de textos.
* ...

En Julia podríamos representar cada operación con una función (la suma, el producto, etc.), y cada conjunto por un tipo de variable; y los ejemplos anteriores se implementarían con los siguientes métodos de una función que llamaremos `elementoneutro`:

```@example c1
elementoneutro(::typeof(+), ::Type{T}) where {T<:Real} = zero(T)
elementoneutro(::typeof(*), ::Type{T}) where {T<:Real} = one(T)
elementoneutro(::typeof(*), ::Type{<:AbstractString}) = ""
nothing #hide
```

Aquí estamos aprovechando que cada función tiene su propio tipo, como se ha indicado anteriormente, aunque todas se puedan agrupar en el supertipo `Function`, y que los tipos de variables son también objetos con su propio tipo, todos ellos de la familia `Type`. Así:

```@repl c1
elementoneutro(+, Float64)
elementoneutro(*, Int)
elementoneutro(*, String)
```

## Métodos genéricos

Como hemos visto, en Julia la anotación del tipo de las variables es opcional; o visto de otro modo, en Julia las variables se pueden anotar con tipos abstractos, y la ausencia de anotación se toma implícitamente como si se declarase el supertipo `Any` que incluye cualquier tipo posible.

De hecho, en los argumentos y el cuerpo de las funciones no solo se puede, sino que *se recomienda* usar tipos con el mayor nivel de abstracción posible que sirva para los propósitos del programa. Esto puede sorprender a usuarios con experiencia en otros lenguajes conocidos por su eficiencia, como C, Java o Fortran, que requieren la anotación explícita de los tipos de todas las variables que se utilizan en los programa. Pero lo explica el hecho de que, aunque el usuario defina métodos con variables genéricas, a bajo nivel se compilen métodos específicos para los conjuntos de tipos concretos que realmente se utilizan al llamar a las funciones.

Así pues, definir métodos genéricos, con argumentos de tipos abstractos, no impide en absoluto la optimización del código. Sin embargo, sí que ayuda a que las funciones sean útiles en aplicaciones más amplias que las que se hubieran podido pensar en un principio. Esto contribuye a hacer código más fácil de reutilizar y extender a posteriori.
