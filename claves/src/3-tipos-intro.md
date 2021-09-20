# Capítulo 3. Definición de tipos compuestos

```@setup c3
using Fracciones
using Random
Random.seed!(123)
```

Como se comentaba en el primer capítulo, el manejo que hace Julia de los tipos de las variables en las funciones es una de las claves de la eficiencia, flexibilidad y expresividad del lenguaje. Los ejemplos de aquel capítulo se basaban en los llamados "tipos primitivos", como las distintas formas de números enteros y decimales. Pero además de esos están los "tipos compuestos", que extienden el lenguaje a mucho más que una herramienta para hacer cálculos con números.

En el paquete [Fracciones](https://github.com/heliosdrm/Fracciones.jl) que hemos introducido en el capítulo anterior tenemos el ejemplo del tipo `Fraccion`, que sirve para representar números racionales. En el código del archivo `src/fraccion.jl` está la definición de ese tipo, que es algo compleja a primera vista, pero podríamos simplificar como sigue:

```julia
struct Fraccion
    num
    den
end
```

Este código define un tipo compuesto por dos valores: `num` (que representa el numerador) y `den` (el denominador). Tras ejecutar ese pequeño fragmento de código ya podríamos crear un objeto de ese tipo, utilizando el nombre del tipo (en este caso `Fraccion`) como "constructor". Por ejemplo, para la fracción de tres cuartos (3 partido por 4) escribiríamos `Fraccion(3,4)`. Los contenidos de ese objeto se pueden extraer usando los nombres de sus campos, mediante la función `getfield` o su expresión abreviada:

```@repl c3
f = Fraccion(3,4)
f.num
f.den
getfield(f, :num) # equivalente a f.num
```

Los tipos suelen designarse con nombres en el llamado *camel case*, es decir, con la primera letra de cada palabra en mayúscula. Así, `Fraccion` se escribe con `F` mayúscula; otros tipos que hemos visto antes compuestos por varias palabras son `BigInt`, `AbstractFloat`, etc. De todos modos, esto es simplemente una convención para mejorar la legibilidad del código; cualquier nombre válido para variables puede usarse también para los tipos.

!!! note "Problemas con la redefinición de tipos"
    
    Si vas a hacer pruebas con el tipo `Fraccion`, *no* ejecutes la definición simplificada que se ha dado arriba. Hay un problema con la definición de tipos, y es que una vez se ha hecho, ya no se puede modificar en toda la sesión de trabajo. Eso significa que si ya se ha cargado alguna otra definición de `Fraccion`, el código anterior no funcionará; y si se ejecuta esa primero, no se va a poder redefinirlo sin cerrar la sesión de Julia e iniciar otra. Hay algunos trucos para redefinir tipos sin reiniciar Julia, que veremos en el capítulo siguiente, pero por ahora lo que se puede hacer para experimentar es utilizar nombres "descartables", como por ejemplo `Fraccion1`, `Fraccion2`, que no entren en colisión entre sí.

!!! note "Tipos vs. clases"
    
    Este concepto de los "tipos" es muy semejante a lo que en otros lenguajes de programación se llaman "clases", y si anteriormente has trabajado con algún lenguaje que utilice clases, encontrarás varias cosas que se hacen igual o de forma muy parecida con los tipos de Julia. Sin embargo, el término "clase" se encuentra muy asociado al paradigma de la programación orientada a objetos, que no es el que se sigue en Julia. La diferencia de nomenclatura ayuda a remarcar esta distinción.

Lo realmente interesante de poder definir tipos compuestos no es que permitan organizar datos de forma personalizada; para eso ya Julia ya pone a nuestra disposición multitud de estructuras de datos muy versátiles (diccionarios, tuplas con nombre...). La gran ventaja de los tipos es que se pueden definir funciones con métodos específicos para ellos, igual que vimos en el capítulo 1 con los distintos tipos de números. Así, en el código de `src/fraccion.jl` tenemos definida, por ejemplo, la siguiente función para calcular el recíproco de una fracción

```julia
"""
    reciproco(x)
    
Calcula la fracción recíproca de `x`.
"""
reciproco(x::Fraccion) = Fraccion(x.den, x.num)   
reciproco(x) = reciproco(Fraccion(x))
```

Esta función tiene dos métodos definidos: el primero es específico para el tipo `Fraccion`; y el segundo es un método genérico, que sirve para cualquier número que podamos convertir en una fracción (más adelante veremos cómo se hace eso). 

## Tipos mutables e inmutables

En un tipo como `Fraccion` se puede acceder al valor de los campos como se ha indicado, pero no se pueden modificar, porque los tipos se definen por defecto como "inmutables". Así, por ejemplo, no podemos cambiar el numerador de la fracción anterior:

```@repl c3
f.num = 1
```

Esto se podría alterar definiendo el tipo explícitamente como "mutable", del siguiente modo:

```julia
mutable struct Fraccion
    num
    den
end
```

De esa manera, el ejemplo anterior no habría dado un error, sino el resultado que se busca. También se podría usar, con el mismo propósito, la funcion `setfield!` que funciona de forma simétrica a `getfield`.

Una situación que puede dar lugar a confusiones es la de tipos inmutables que contienen campos con valores mutables. Por ejemplo, supongamos un tipo de datos llamado `Señal` que identifica una serie de datos y una etiqueta, del siguiente modo:

```julia
struct Señal
    serie
    etiqueta
end

s = Señal(rand(5), "prueba")
```

Como `Señal` es un tipo inmutable, *no* se podría hacer ninguna de las siguientes reasignaciones a sus campos:

```julia
s.serie = rand(10)
s.etiqueta = "abc"
```

Lo que sí se podría hacer es *modificar* el contenido de `s.serie` (por ejemplo `s.serie[1] = 0`), ya que se trata de un vector, que es un objeto mutable.

## Tipos abstractos y supertipos

La definición simplificada al extremo que se ha dado antes del tipo `Fraccion` se puede complementar, acercándola a la que se da realmente en el repositorio, con una serie de modificaciones. En primer lugar se puede incluir el nuevo tipo dentro de una jerarquía de tipos abstractos asignándole un "supertipo". En particular, hemos definido `Fraccion` como un subtipo de número real. Sobre la definición simplificada esto se haría como sigue:

```julia
struct Fraccion <: Real
    num
    den
end
```

En este caso hemos usado un tipo abstracto que ya existía, pero también podemos crear tipos abstractos nuevos. Por ejemplo, podríamos haber definido nuestro propio tipo abstracto con el nombre `Numero`, para lo cual basta con escribir:

```julia
abstract type Number end
```

Este tipo `Numero` que hemos creado, al igual que todos los tipos abstractos en Julia, tiene bien merecido el calificativo de "abstracto": no contiene ningún campo, y tampoco se pueden crear objetos de ese tipo. Si por ejemplo intentamos forzar la creación de un número de tipo `Real`, lo que obtendremos es un objeto de uno de los tipos concretos representados dentro de los subtipos de `Real`:

```@repl
typeof(Real(1))
typeof(Real(1.0))
```

Lo que sí se puede hacer es crear variables que contengan valores de tipo `Real` (u otro tipo abstracto), aunque sería más preciso decir que permiten incluir valores de cualquier subtipo de Real. Por ejemplo el siguiente vector:

```@repl
unos = Real[1, 1.0, true]
eltype(unos) # El tipo representado en `unos`
typeof(unos[1]) # El tipo de cada elemento es concreto...
typeof(unos[2])
typeof(unos[3])
```

## Tipos de los campos y tipos paramétricos

Veamos ahora un aspecto muy importante: la anotación de los tipos de los campos (`num` y `den` en nuestro ejemplo). Con las definiciones que se han dado hasta aquí, estos campos podían ser cualquier tipo de número, pero también textos, funciones o algún otro tipo más exótico de variable. Así que si tenemos la intención de que `Fraccion` represente fracciones de números enteros, podríamos restringir estos campos a valores de tipo `Int`:

```julia
struct Fraccion <: Real
    num::Int
    den::Int
end
```

Esto haría que los valores introducidos al crear una `Fraccion` intenten convertirse al tipo `Int`,[^1] y que se dé un error si la conversión no es posible:

[^1]: `Int` es un *alias* que puede representar tipos distintos según la arquitectura del ordenador en que se está trabajando: es equivalente a `Int64` en los procesadores de 64 bits, y a `Int32` en procesadores de 32 bits.

```julia-repl
julia> Fraccion(3.0, 4.0) # Se pueden convertir a enteros
Fraccion(3, 4)

julia> Fraccion(1.5, 4)   # El numerador no se puede convertir a entero
ERROR: InexactError: Int64(1.5)
```

Ahora bien, la condición de que los campos sean `Int` podría considerarse muy restrictiva. En un ordenador de 64 bits no permitiría crear fracciones con números `Int128` o `BigInt`, y en uno de 32 bits tampoco se podrían hacer fracciones con `Int64`. Esto se puede resolver especificando campos del tipo abstracto `Integer`:

```julia
struct Fraccion <: Real
    num::Integer
    den::Integer
end
```

Sin embargo, esa no es la mejor solución. Siempre que sea posible se recomienda que los campos tengan un tipo concreto. El motivo es que cuando se intenta compilar funciones con variables de tipo compuesto, si todos sus campos son de un tipo concreto predefinido, el compilador podrá calcular exactamente la cantidad de memoria requerida, lo que permitirá optimizar el código a bajo nivel y acelerar la ejecución del programa. Por contra, un campo de tipo abstracto dificultará la optimización de cualquier programa que lo utilice.

La forma adecuada de proceder en casos como este es definiendo "tipos paramétricos", del siguiente modo, que ya es casi lo mismo que encontramos en el código del repositorio:

```julia
struct Fraccion{T} <: Real where {T<:Integer}
    num::T
    den::T
end
```

O de forma equivalente, adelantando la condición `where` al punto en el que se introduce el parámetro `T`: 

```julia
struct Fraccion{T<:Integer} <: Real
    num::T
    den::T
end
```

Esto significa que `num` y `den` han de ser de un tipo `T`, no especificado a priori, que ha de cumplir la condición `T <: Integer`. A la hora de definir una `Fraccion` esto no resulta muy distinto que si hubiéramos especificado `num::Integer` y `den::Integer`, pero en el fondo es algo muy distinto, como vemos a continuación:

```julia-repl
julia> f1 = Fraccion(3,4)
Fraccion{Int64}(3, 4)

julia> f2 = Fraccion(0x3, 0x4)
Fraccion{UInt8}(0x03, 0x04)

julia> typeof(f1)
Fraccion{Int64}

julia> typeof(f2)
Fraccion{UInt8}

julia> typeof(f1) == typeof(f2)
false

julia> typeof(f1) <: Fraccion
true

julia> typeof(f1) <: Fraccion >: typeof(f2)
true
```

Aquí vemos que `f1` es del tipo `Fraccion{Int64}` mientras `f2` es una `Fraccion{UInt8}`.[^2] Son dos tipos *distintos*, cuya representación en memoria está bien especificada por el tipo de parámetro indicado entre llaves. Por otro lado, ambos se reconocen como miembros del tipo `Fraccion`.

[^2]: La representación canónica de los números enteros "sin signo" (`Unsigned`) es mediante un código hexadecimal con una posición por cada 4 bits, precedido de `0x`; p.ej. `0x0f` para el número 15 en un entero sin signo de 8 bits (`UInt8`), `0x000f` para el mismo número en 16 bits (`UInt16`), etc. Entre los números decimales, los de 32 bits (`Float32`) también tienen una representación canónica especial: se representan en notación exponencial, con la letra `f` antes del exponente; p.ej. el número 15 es `15.0f0` --pero también podría escribirse como `1.5f1`, etc.

De este modo, el código anterior define no solo un tipo concreto, sino una familia de tipos, cuyos miembros se concretan por el valor del parámetro `T`. En este caso hemos asignado un mismo tipo `T` al numerador `num` y el denominador `den`, por lo que si se pasan dos enteros de distinto tipo, se intentará convertir estos a un mismo tipo de entero. Por ejemplo, si combinamos un `Int32` y un `Int64`, se escojerá el `Int64` como tipo que engloba a ambos:

```julia
julia> Fraccion(0x3, 4)
Fraccion{Int64}(3, 4)
```

También podríamos indicar explícitamente qué valor queremos que adopte el parámetro `T`, por ejemplo con `Fraccion{UInt128}(3, 4)`.

Si quisiéramos , también se podrían definir parámetros distintos para ambos campos, del siguiente modo:

```julia
struct Fraccion{N, D} <: Real where {N<:Integer, D<:Integer}
    num::N
    den::D
end
```

El valor de los parámetros en un tipo paramétrico puede ser cualquiera que cumpla las condiciones especificadas en las expresiones con `where`, que se pueden componer e incluso anidar. También se puede dejar que un parámetro `T` adopte cualquier valor, escribiendo solo `where T` o `where {T}`, sin ninguna condición impuesta.

Ni siquiera es obligado que los parámetros representen tipos de los campos, aunque sea lo habitual. Fijémonos, por ejemplo, en el tipo `Array`. Su definición paramétrica es `Array{T, N} where {T, N}`, siendo `T` el tipo de los elementos que contiene, mientras `N` es el *número* de dimensiones (1 para vectores, 2 para matrices, etc.).

## Constructores

Hemos visto que el nombre de los tipos también sirve de "función constructora", cuyos argumentos son los valores asignados a los campos, en el mismo orden en el que se declaran al definir el tipo. En nuestro ejemplo, el primer argumento del constructor `Fraccion` es el valor del campo `num` (numerador), y el segundo es el valor de `den` (el denominador). En los tipos paramétricos, el valor de los parámetros se pasa entre llaves antes de los argumentos --p.ej. `Fraccion{BigInt}(1,2)`--, pero se puede omitir si están unívocamente determinados por los valores de los campos.

Para los constructores también se pueden definir métodos específicos, que empleen otro número y otros tipos de argumentos, como ocurre con cualquier función. Así, en `src/fraccion.jl` tenemos los siguientes constructores que crean una `Fraccion` a partir de otra fracción o un entero:

```julia
Fraccion(x::Fraccion) = x
Fraccion(x::T) where {T<:Integer} = Fraccion(x, one(T))
```

En el caso de que `x` sea una fracción basta con devolver el mismo valor que se le ha pasado; si es un número entero, es una fracción con denominador unitario del mismo tipo. Además se han creado los siguientes constructores para los casos en los que se especifique explícitamente el parámetro de la fracción:

```julia
Fraccion{T}(x::Fraccion{T}) where T = x
Fraccion{T}(x::Fraccion) where T = Fraccion{T}(x.num, x.den)
Fraccion{T}(x::Tx) where {T, Tx<:Integer} = Fraccion{T}(x, one(Tx))
```

La distinción de los dos primeros métodos para `x::Fraccion` no es absolutamente necesaria; podría haberse definido solo el segundo, pero cuando el parámetro de la fracción de entrada y el de la salida es el mismo, no vale la pena construir una nueva fracción, y por eso se ha definido el primer método que es más específico y más sencillo. El método paramétrico para construir la fracción a partir de un entero es virtualmente igual al no paramétrico.

También se ha definido un constructor con parámetro de `Fraccion` a partir de cualquier número real, aunque en este caso solo se admiten valores equivalentes a enteros o infinitos, y en caso contrario se emite un error:

```julia
function Fraccion{T}(x::R) where {T, R<:Real}
    if iszero(rem(x, one(R)))
        return Fraccion{T}(T(x), one(T))
    elseif isinf(x)
        return Fraccion{T}(T(sign(x))*one(T), zero(T))
    else
        throw(InexactError(nameof(T), T, x))
    end
end
```

La equivalencia de `x` a un entero se comprueba calculando el resto de la división por la unidad del mismo tipo que `x` (`rem(x, one(R)`), y verificando que sea cero con la función `iszero`. Asimismo, la equivalencia de `x` a un número infinito se obtiene con la función `isinf`. Si no se señala el parámetro `T` de la `Fraccion`, el siguiente método intenta crear un objeto de tipo `Fraccion{Int}`:

```julia
Fraccion(x::Real) = Fraccion{Int}(x)
```

## Constructores internos

En el archivo `src/fraccion.jl` también hay un constructor interno, dentro de la definición del tipo `Fraccion`, con el siguiente código:

```julia
function Fraccion{T}(n, d) where {T<:Integer}
    num = convert(T, n)
    den = convert(T, d)
    # 0/0 no permitido
    iszero(num) && iszero(den) && throw(ArgumentError("fracción inválida: cero entre cero"))
    # reducir a fracción mínima
    mcd = gcd(num, den)
    num = div(num, mcd)
    den = div(den, mcd)
    # fracciones con typemin(T) no permitidas
    if T<:Signed && !(T === BigInt) && (num === typemin(T) || den === typemin(T))
        throw(ArgumentError("fracción inválida: no se puede usar typemin($T)"))
    end
    # denominador negativo
    if den < zero(T)
        num = -num
        den = -den
    end
    new{T}(num, den)
end
```

Este código utiliza la función `gdc` para obtener el máximo común divisor (en inglés *greatest common divisor*) de los argumentos introducidos, con el que la fracción se reduce a su forma canónica (p.ej. `Fraccion(2,4)` se reduce a `Fraccion(1,2)`), y manipula los signos para asegurar que el denominador es positivo. Además, hace unas verificaciones para lanzar un error si los dos argumentos son cero (en cuyo caso la fracción no tiene un valor numérico definido), o si si cualquiera de ellos es el valor negativo extremo del tipo especificado (`typemin(T)`). Por ejemplo, si `T` es `Int16` (que tiene valores definidos entre `-32768` y `32767`), se da un error en el caso de que el numerador o el denominador sea `-32768`. Esto simplifica la gestión de excepciones en cálculos en los que se tenga que cambiar algún signo, pues el valor positivo `32768` no se podría representar como un `Int16`.

!!! warning "Desbordamiento aritmético"
    
    Tal como se ha mostrado en este ejemplo, siempre que se trabaja con números de tipo entero (subtipos de `Signed` o `Unsigned`) hay que tener cuidado los posibles problemas de [desbordamiento aritmético](https://es.wikipedia.org/wiki/Desbordamiento_aritm%C3%A9tico). Esto ocurre cuando se llega a los límites del rango definido para cada tipo (calculados con `typemin` y `typemax`).

Para definir el objeto que devuelve el constructor interno se utiliza la palabra clave `new`, en lugar del nombre del tipo. El motivo es que los constructores internos *sustituyen* los constructores por defecto. Es decir, que no existe ningún método `Fraccion` que utilizar salvo el que se está definiendo en ese código. En este caso hemos querido tener ese constructor interno, para asegurar que las fracciones siempre adoptan la forma canónica con valores aceptables. Pero normalmente se suelen mantener los constructores por defecto, y solo se crean métodos externos, lo que hace las cosas más sencillas.

Por ejemplo, al crear el constructor interno `Fraccion{T}(n, d)` ya no existe un constructor por defecto que permita omitir el parámetro, por lo que tenemos que definirlo explícitamente, con el siguiente código:

```julia
function Fraccion(num::N, den::D) where {N<:Integer, D<:Integer}
    T = promote_type(N, D)
    Fraccion{T}(num, den)
end
```

Aquí la función `promote_type`, de la que se dan detalles en el [capítulo 5](5-tipos-ext.md#Conversión-y-promoción-de-tipos), determina un tipo que permite representar adecuadamente tanto los valores del tipo `N` (los del numerador) como los del tipo `D` (del denominador). Ese tipo es el que se asigna a la fracción resultante, que se crea con el constructor interno que hemos definido antes.

## Constructores abstractos

Hay ocasiones en las que un mismo método sirve para varios constructores relacionados. Por ejemplo, para crear un número de tipo `Float64` a partir de una `Fraccion` se puede definir el siguiente método:

```julia
Float64(x::Fraccion) = Float64(x.num / x.den)
```

También podríamos escribir lo mismo sustituyendo `Float64` por `Float32`, y lo mismo con todos los subtipos de `AbstractFloat`. Ahora bien, en lugar de definir esos constructores uno a uno, en `src/fraccion.jl` tenemos el siguiente código que los define todos a la vez de forma abstracta:

```julia
function (::Type{T})(x::Fraccion) where {T<:AbstractFloat}
    T(x.num / x.den)
end
```

En ese código, el nombre del constructor se reemplaza por una anotación como la que se introdujo en el [capítulo 1](1-multiple-dispatch.md#Anotar-tipos-sin-valores) para representar de forma genérica un conjunto de tipos. Del mismo modo, los constructores de números enteros a partir de fracciones se definen del siguiente modo:

```julia
function (::Type{T})(x::Fraccion) where {T<:Integer}
    if x.den == 1
        return T(x.num)
    else
        throw(InexactError(nameof(T), T, x))
    end
end
```

Este código devuelve el numerador convertido al tipo de entero `T` si el denominador es unitario, y en caso contrario emite un `InexactError`, que indica que `x` no se puede convertir al tipo deseado. En esa línea, `nameof(T)` es el nombre del tipo en forma de símbolo.

Hay muchas cosas más que contar sobre los tipos, incluyendo cómo personalizar distintos aspectos y comportamientos de los mismos. Pero estos detalles se dejan para el [capítulo 5](5-tipos-ext.md); pues ahora que ya se han visto las cuestiones básicas sobre cómo definir tipos personalizados, es oportuno comentar otros aspectos del código en proyectos y paquetes de Julia, que harán que podamos sacar mayor provecho a los tipos, entre otras cosas.


