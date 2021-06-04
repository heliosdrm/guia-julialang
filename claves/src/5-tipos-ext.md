# Capítulo 5. Personalizando los tipos compuestos

```@setup c5
using Fracciones
```

En el [capítulo 3](3-tipos-intro.md) vimos cómo definir tipos compuestos y distintos constructores de los mismos. Pero un tipo para el que solo se hayan definido los constructores no resulta especialmente útil, excepto como estructura de datos. Como se indicaba en ese capítulo, lo interesante de los tipos es que se pueden definir funciones con métodos específicos para ellos. Se mostró como ejemplo la función `reciproco`, que sirve para calcular la fracción recíproca a una dada; y el paquete Fracciones también proporciona un par de métodos triviales para extraer los valores del numerador y el denominador.

Lo que se va a mostrar en este capítulo es cómo ir más allá, y definir métodos no solo de funciones nuevas, sino también las que usa Julia para trabajar con otros tipos existentes. Esto nos permitirá personalizar el funcionamiento y la presentación de nuestros nuevos tipos, y mejorar la interoperabilidad de los mismos con otras variables.

## Extensión de funciones externas

Como se ha comentado en el capítulo anterior, los módulos son secciones de código aisladas. Esto impide que un módulo cree nuevos objetos dentro de otro, o que redefina los existentes --de forma semejante a lo que pasa con los campos de un tipo inmutable--. Pero lo que sí se puede hacer es acceder a sus contenidos (utilizando el nombre del módulo como prefijo o importándolos explícitamente), y alterarlos en el caso de que sean objetos mutables.

Esto incluye la extensión de funciones con nuevos métodos. Gracias a eso, en el código del paquete Fracciones se han podido definir métodos de diversas funciones matemáticas que están definidas en el módulo `Base` para otros tipos de números, por ejemplo:

```julia
Base.sign(x::Fraccion) = sign(x.num)
Base.abs(x::Fraccion) = Fraccion(abs(x.num), x.den)
Base.one(::Type{Fraccion{T}}) where T = Fraccion(one(T))
Base.zero(::Type{Fraccion{T}}) where T = Fraccion(zero(T))
```

Con esas funciones, el signo y el valor absoluto de una `Fraccion` se definen haciendo referencia a los valores del numerador (`x.num`), mientras que el valor unitario y cero de ese tipo se crean convirtiendo los valores correspondientes de un entero en `Fraccion`.

Nótese que para hacer esto se ha escrito el prefijo `Base` antes del nombre de las funciones. De no haberlo incluido, se habrían creado funciones con los mismos nombres (`sign`, `abs`, `one` y `zero`) propias del módulo `Fracciones` donde se definen esos métodos, independientes de las de `Base`. Alternativamente, se podrían haber importado esas funciones de forma explícita, escribiendo con anterioridad:

```julia
import Base: sign, abs, one zero
```

Si se hubiera hecho eso, no haría falta escribir el prefijo `Base` para extender esas funciones, pues toda referencia a esos nombres se asociaría a los objetos de `Base`.

Hay muchas otras funciones de `Base` que también reciben nuevos métodos en `Fracciones`. A continuación mostramos la mayoría de ellas.

Las funciones `typemin` y `typemax` definen los valores más bajo y más alto permitidos para los tipos de `Fraccion`:

```julia
Base.typemin(::Type{Fraccion{T}}) where T = Fraccion(-one(T), zero(T))
Base.typemax(::Type{Fraccion{T}}) where T = Fraccion{T}(one(T), zero(T))
Base.typemin(::Type{Fraccion{T}}) where {T<:Union{Unsigned, Bool}} = zero(Fraccion{T})
```

El máximo valor (`typemax`) para una `Fraccion` es una fracción positiva con cero de denominador --equivalente a infinito--. El valor mínimo (`typemin`) es el opuesto en el caso de fracciones con números con signo, y cero para las fracciones de números estrictamente positivos (`Unsigned` y `Bool`).

También tenemos los operadores `+` y `-`, que se usan para alterar el signo del numerador (métodos con un solo argumento), o hacer la suma o resta de fracciones (con dos argumentos):

```julia
Base.:+(x::Fraccion) = Fraccion(+x.num, x.den)
Base.:-(x::Fraccion) = Fraccion(-x.num, x.den)
Base.:-(x::Fraccion{<:Unsigned}) = throw(TypeError(:-, Signed, x))

function Base.:+(x::Fraccion{Tx}, y::Fraccion{Ty}) where {Tx<:Integer, Ty<:Integer}
    if x.den == 0 == y.den
        if sign(x) ≠ sign(y)
            throw(ArgumentError("resultado indefinido"))
        else
            T = promote_type(Tx, Ty)
            return Fraccion(x.num, zero(T))
        end
    end
    mcd = gcd(x.den, y.den)
    xfactor = div(y.den, mcd)
    yfactor = div(x.den, mcd)
    den = xfactor * yfactor * mcd
    return Fraccion(x.num * xfactor + y.num * yfactor, den)
end

Base.:-(x::Fraccion, y::Fraccion) = x + -y
```

Nótese que el nombre de los operadores tiene que escribirse explícitamente como un símbolo (`:+`, `:-`), con los dos puntos precediendo al carácter que identifica el símbolo. El algoritmo de la suma podría haberse escrito de una forma algo más sencilla, sin usar el máximo común denominador (obtenido con la función `gdc`). El motivo de emplear este algoritmo algo más complejo es que permite trabajar con números más pequeños en valor absoluto. Esto es conveniente cuando se opera con números de tipo entero, para evitar problemas de desbordamiento aritmético. También se controlan casos excepcionales, como cuando uno o los dos sumandos son inifinitos (con denominador cero).

El producto y la división de fracciones, y su potencia por un número entero se definen como métodos de los siguientes operadores:

```julia
function Base.:*(x::Fraccion, y::Fraccion)
    f1 = Fraccion(x.num, y.den)
    f2 = Fraccion(y.num, x.den)
    Fraccion(f1.num * f2.num, f1.den * f2.den)
end

Base.:/(x::Fraccion, y::Fraccion) = x * reciproco(y)

function Base.:^(x::Fraccion, n::Integer)
    if n ≥ 0
        return Fraccion(x.num^n,  x.den^n)
    else
        return Fraccion(x.den^(-n), x.num^(-n))
    end
end
```

El cálculo de los factores `f1` y `f2` en el producto tiene también el propósito reducir los valores que se han de multiplicar en el numerador y denominador de la fracción resultante, para minimizar el riesgo de desbordamiento aritmético.

Finalmente se muestra el código para las comparaciones de igualdad, "menor que" y "menor o igual que":

```julia
Base.:(==)(x::Fraccion, y::Fraccion) = (x.num == y.num) && (x.den == y.den)

function Base.:<(x::Fraccion, y::Fraccion)
    (x.num == 0 == y.num) && return false
    (x.den == 0 == y.den) && return (x.num == -1 && y.num == 1)
    xsig = sign(x)
    ysig = sign(y)
    if xsig == ysig
        f = x/y
        return (xsig == 1) ⊻ (f.num > f.den)
    else
        return xsig < ysig
    end
end

Base.:<=(x::Fraccion, y::Fraccion) = (x < y) | (x == y)
```

La igualdad se reduce a comprobar que numerador y denominador tienen los mismos valores, porque el constructor de `Fraccion` asegura que se trabaja siempre con los valores canónicos de la fracción; es decir que no hay fracciones equivalentes con distintos valores de numerador y denominador. Las comparaciones "mayor que" y "mayor o igual que" no hace falta definirlas, porque se desprenden de estas otras. Normalmente tampoco es necesario es definir la de "menor o igual que" (`<=`), si ya se han definido "igual que" (`==`) y "menor que" (`<`). Pero cuando el tipo se ha definido como subtipo de `Real`, sí que es necesario definir `<=`  de forma explícita, como aquí.

!!! note "Comparación de valores de nuevos tipos"
    
    La mayor parte de los métodos definidos para `Fraccion` se deben a que este tipo representa valores numéricos, pero el operador de comparación `==` es útil para muchos otros tipos de valores. Si no se define este método para un tipo, dos variables `a` y `b` de ese tipo solo se identificarán como iguales (`a == b`) si representan exactamente *el mismo objeto* (es decir, si se cumple `a === b`).

## Conversión y promoción de tipos

Cuando hay varios tipos de variables que representan información equivalente, como `Fraccion` respecto a otros tipos de números, también puede interesar que Julia realice conversiones automáticas en ciertas situaciones. Esto se consigue definiendo nuevos métodos de la función `convert` del módulo `Base`, que normalmente se limita a llamar al constructor correspondiente en cada caso. Por ejemplo, para la conversión de un número real a una fracción podríamos escribir:

```julia
Base.convert(::Type{Fraccion{T}}, x::Real) where T = Fraccion{T}(x)
```

Este método ha de definirse con dos argumentos: el primero ha de designar el tipo al que se quiere hacer la conversión automática, lo cual anotamos como un tipo paricular de la familia `Type`. El segundo argumento es el valor que se quiere convertir a ese tipo. La función `convert` no suele utilizarse explícitamente; si existe el método adecuado, la conversión definida se aplica automáticamente en ciertas circunstancias. Por ejemplo, el número `2` se transformaría en `Fraccion{Int}(2,1)` en los siguientes casos:

* Si se introduce en un `Array` o un objeto semejante destinado al tipo objetivo; p.ej. en `v[1] = 2` si `eltype(v) == Fraccion{Int}`.
* Al asignarlo a una variable anotada con el tipo objetivo (p.ej. `x::Fraccion = 2`), o si es el valor a devolver por una función anotada con ese tipo (véase la sección sobre [Anotación de tipos](@ref) en el capítulo 1).
* Igualmente, si se asigna a un campo anotado con el tipo objetivo, en la construcción de nuevos objetos.

En el código del paquete Fracciones no se define ningún método de `Base.convert`, ya que `Fraccion` está definido como un subtipo de `Real` (y por tanto es a su vez un subtipo de `Number`), y en `Base` ya están definidos los métodos que hacen la conversión automática entre todos los subtipos de `Number`, usando los constructores adecuados.

Otro mecanismo de conversión es la llamada promoción de tipos. Esto es convertir dos valores de tipos distintos a un tipo que sea adecuado para representar ambos. Por ejemplo si juntamos con `promote` un número decimal (`Float64`) con un complejo formado por enteros (`Complex{Int64}`), el resultado es la conversión de ambos a complejos decimales (`Complex{Float64`). Por su parte, a función `promote_type` toma dos tipos y devuelve el que se usaría para efectuar la promoción:

```@repl
promote(1.0, 3+im)
promote_type(Float64, Complex{Int})
```

Para que estas funciones operen también con el tipo `Fraccion`, se han definido los dos siguientes métodos de la función `promote_rule` de `Base`:

```julia
Base.promote_rule(::Type{Fraccion{T}}, ::Type{R}) where {T, R<:Real} = R

function Base.promote_rule(::Type{Fraccion{T1}}, ::Type{T2}) where {T1<:Integer, T2<:Integer}
    T = promote_type(T1, T2)
    Fraccion{T}
end
```

El primer método hace que al juntar una fracción con otro número real, en general ambos se promocionen al tipo real. Pero el segundo método, que es más específico, define una excepción a esa regla: si el otro número es un entero, se buscará el tipo de entero más adecuado para ambos números (usando la propia función `promote_type`), y los dos se promocionarán a una `Fraccion` con ese tipo de entero.

## Representación de los tipos

La forma por defecto de representar los valores de un tipo compuesto es mediante una expresión como `T(...)`, donde `T` es el nombre del tipo (con los parámetros que corresponda), y los puntos suspensivos es una lista ordenada de sus campos. Esto es útil para tipos sencillos, para empezar porque copiando y pegando esa expresión en el REPL se puede crear un objeto con un valor equivalente. Pero cuando se trata de un tipo con una definción complicada, con muchos campos o campos que contienen mucha información, esta representación puede ocupar mucho espacio (es fácil que ocupe decenas de líneas), y se convierte en un engorro.

Para resolver esa situación se puede crear un método especializado de la función `Base.show`. Para el tipo `Fraccion` este método se ha definido de la siguiente manera:

```julia
Base.show(io::IO, x::Fraccion) = print(io, "Fraccion($(repr(x.num)), $(repr(x.den)))")
```

El primer argumento de los métodos de esta función ha de ser un objeto de tipo abstracto `IO` (del inglés *input/output*), que identifica el canal de datos en el que se volcará la representación (un archivo, la salida estándar, un *buffer*, etc.). El segundo argumento es el objeto a representar, y el método ha de ejecutar ese volcado de información sobre el canal especificado.

Lo más habitual es definir una representación basada en una cadena de texto, que se vuelca en el canal de salida con `print`, como se ha hecho en el ejemplo de arriba. En este caso se ha optado por una representación muy sencilla, que apenas difiere de la que se haría por defecto: una cadena de texto que empieza con `Fraccion`, y luego presenta entre paréntesis los valores del numerador y el denominador, respectivamente. La única diferencia con la representación por defecto es que se omite el parámetro del tipo de entero utilizado, de tal manera que, por ejemplo, en vez de `Fraccion{Int}(1, 2)` se leerá `Fraccion(1, 2)`.

Al crear un método específico de `Base.show` no solo se verá esa representación en pantalla cuando mostremos el valor de una `Fraccion`. La propia función `print`, que hace la llamada "representación canónica" de un objeto, también llama por defecto a `show`, por lo que al escribir los valores de una `Fraccion` explícitamente con esa función (y con variantes de la misma, como `println`), el resultado será el mismo. Esto se puede cambiar si se desea, creando un método específico y distinto para `print`, cuya sintaxis es igual que la del método `show` que se ha mostrado. 

Estos métodos también alteran los resultados de las funciones `repr` y `string`, que crean cadenas de texto con esas representaciones de los objetos. Concretamente, `repr` crea la cadena de texto que se muestra con `show`, y `string` crea la cadena mostrada con `print` (la representación canónica).

Por otro lado, la representación de variables no tiene por qué limitarse a cadenas de texto planas. Algunos tipos también pueden tener una representación en texto HTML o de otros formatos, así como de tipo gráfico (figuras geométricas, figuras...), audiovisiual (señales de audio, vídeos...), o en cualquier otro medio que pueda expresarse informáticamente. La forma estándar que tiene Julia para definir las distintas formas de representación es mediante [tipos MIME](https://es.wikipedia.org/wiki/Multipurpose_Internet_Mail_Extensions). Por ejemplo, la representación en HTML de una `Fraccion` se ha definido del siguiente modo:

```julia
function Base.show(io::IO, ::MIME"text/html", x::Fraccion)
    print(io, "<sup>$(x.num)</sup>&frasl;<sub>$(x.den)</sub>")
end
```

Esto hace que si el valor de una fracción se ha de mostrar en un contexto donde el formato de representación es HTML (como este manual), el texto que se vuelque sea el código HTML que permite ver la fracción de forma "bonita"; por ejemplo al mostrar el resultado siguiente:

```@example c5
x = Fraccion(3, 4)
```

Si no se define ningún método para formatos MIME específico, el único que funciona es el de tipo "text/plain", que usa el método `show` con dos argumentos que se ha mostrado antes.

!!! note "Especificación de formato MIME en Julia"
    
    Cada formato MIME se representa con un tipo propio en Julia, todos ellos de la familia `MIME`. En el ejemplo hemos visto el tipo `MIME"text/html"`; otros serían `MIME"text/plain"`, `MIME"image/png"`, etc. Esas expresiones que comienzan por `MIME` son variantes más cómodas de escribir que la expresión canónica de esos tipos, que es `MIME{Symbol("text/html")}`, etc. Véase la página del manual oficial sobre la [representación personalizada de tipos](https://docs.julialang.org/en/v1/manual/types/#man-custom-pretty-printing) para más detalles.

## Extensión de otros métodos

Con lo visto en los apartados anteriores se han cubierto la práctica totalidad de los métodos de `Base` para los que se han definido nuevos métodos en el paquete Fracciones. Pero naturalmente, hay muchos otros que pueden ser interesantes para tipos con otras características.

Por ejemplo, si nuestro tipo fuese una colección de datos de tamaño variable, podría ser útil definir métodos de algunas de las siguientes funciones:
* `length` para calcular la cantidad de elementos contenidos.
* `size` si la información está estructurada en varias dimensiones.
* `get` o `getindex` para extraer el dato de una o varias posiciones específicas.
* `setindex!` para asignar un valor a una o varias posiciones específicas.
* ... y otras funciones habituales que se usan para operar con *arrays*, diccionarios u otro tipo de colecciones que sean comparables con el tipo que se haya definido.

Las funciones `getindex` y `setindex!` son especialmente interesantes, porque controlan el comportamiento de las expresiones con corchetes como las que se usan para acceder a elementos de *arrays* y diccionarios. En particular:

* La operación de lectura `x[indices]` ejecuta la función `getindex(x, indices)` -- donde `indices` puede ser un valor de cualquier tipo o un conjunto de ellos, según los métodos que se hayan definido. Concretamente es típico definir un método para un índice de tipo `Colon`, que se corresponde con los dos puntos (`:`), para referirse a "todos los elementos".
* La operación de escritura `x[indices] = valores` ejecuta la función `setindex!(x, indices, valores)`, con las mismas consideraciones que se han señalado para `getindex`.

Del mismo modo, las funciones `getproperty`, `setproperty!` y `propertynames` controlan el comportamiento de las expresiones con punto que se usan para acceder a los campos o propiedades de un objeto:

* La expresión de lectura `x.campo` ejecuta la función `getproperty(x, :campo)` -- con el segundo argumento como un símbolo que representa lo escrito después del punto.
* La expresión de lectura `x.campo = valor` ejecuta la función `setproperty!(x, :campo) = valor`.
* Si en el REPL se presiona el tabulador después de escribir `x.`, se muestra una lista con los nombres devueltos por la función `propertynames(x)`.

En el caso de los tipos compuestos, si no se ha definido ningún metodo para estas funciones se intenta acceder a los campos de ese tipo. Por lo tanto, si se crea un método específico para cualquiera de ellas es conveniente hacerlo con las tres, para mantener la consistencia. (En el caso de los tipos inmutables no hace falta extender la función `setproperty!`, ya los campos no se pueden modificar.)[^1]

[^1]: Si se crean métodos para `getproperty`, `setproperty!` o `propertynames`, la lectura y escritura de los campos del tipo se puede seguir haciendo de forma directa mediante las funciones `gefield`, `setfield!` y `fieldnames`, que no deberían modificarse con métodos nuevos.

## Objetos como funciones

Una propiedad curiosa y útil en ciertas circunstancias de todos los objetos de Julia es que se pueden emplear como funciones, si se definen métodos para su tipo. Esto se entiende mejor con un ejemplo:

```@example c5
struct Multiplicador
    n::Int
end

(m::Multiplicador)(x) = m.n * x
```

La última línea de ese ejemplo se puede leer como la definición método para la función `m::Multiplicador`, es decir, una función representada por cualquier objeto `m` del tipo `Multiplicador` que se ha definido antes. En esa función, `m` es también una variable que se puede usar para hacer operaciones; en particular lo que hace es devolver el producto de su campo `n` por el argumento `x`. Así: 

```@repl c5
k = Multiplicador(3);
k(2.5)
```

Puedes recordar que este es precisamente el truco que se utilizó en el capítulo 3 para definir [Constructores abstractos](@ref), como:

```julia
(::Type{T})(x::Fraccion) where {T<:AbstractFloat}
```

Ese código definía un método para cualquier tipo `T<:AbstractFloat` en el que el argumento fuera un objeto de tipo `Fraccion`.

## Pirateo de tipos

A lo largo de este capítulo hemos visto varios ejemplos en los que hemos extendido funciones del módulo `Base` de Julia con aplicaciones específicas para el tipo `Fraccion`; y lo mismo podría haberse hecho con funciones de otros módulos, así como de paquetes de terceros. Y del mismo modo que hemos definido métodos para el tipo `Fraccion` que hemos definido, podríamos haberlo hecho para cualquier otro tipo, esté definido por nosotros, presente en `Base` o importado de cualquier otro módulo o paquete.

Todo esto es muy útil, especialmente porque se puede hacer sin tener que manipular los módulos o paquetes en los que están definidos las funciones o los tipos que se están usando. Esto es una de las razones por las que Julia se considera un lenguaje fácilmente "extensible": se puede tomar el trabajo de otros (funciones y tipos definidos en otros paquetes) y ampliar su funcionalidad con un nuevo paquete, sin tener que definir versiones derivadas de aquellos objetos, y sin necesidad de coordinarse con los autores de los paquetes anteriores.

Esta flexibilidad deja el camino abierto a una práctica que en Julia se conoce como "pirateo de tipos". La definición que se suele dar de esta práctica es "definir métodos de funciones que no son tuyas para tipos que tampoco son tuyos". En esa definición, "no ser tuyo" significa que bien la función o el tipo no se ha definido en el mismo paquete que el método en cuestión. Los ejemplos de este capítulo no caen dentro de esa categoría, ya que aunque la mayoría de funciones manipuladas pertenecen a `Base`, en todos los métodos que se han definido al menos uno de los argumentos es del tipo `Fraccion`, que está definido en el mismo módulo `Fracciones`.

El pirateo de tipos es considerado una mala práctica, aunque dependiendo del contexto no es tan terrible como podría sugerir el nombre. No hay nada de ilícito en ello, y en proyectos particulares puede resultar un truco práctico para facilitar ciertas operaciones. Lo que no conviene hacer es emplearlo en código que esté previsto compartir, o que se piense que puede servir de base para otros proyectos, porque puede ser el origen de conflictos e inconsistencias.

Para entenderlo piensa en el "ecosistema" de Julia como un inmenso mosaico rectangular que se puede extender infinitamente: cada nuevo tipo que se define traza el diseño de una nueva fila del mosaico, cada nueva función es una nueva columna, y cuando defines cualquier método estás componiendo una celda particular de ese mosaico. Tienes completa libertad para elegir qué piezas del mosaico componer; pero para contribuir al diseño general de forma armoniosa conviene que al menos la fila o la columna sean parte de tu contribución original. Claro está, esto hace que el puzle quede muy disperso, así que si tienes una copia para tu disfrute particular eres libre de rellenar huecos con métodos inventados por ti. Pero si esto se hace de forma colectiva, existe el riesgo de que se generen dos o más piezas para el mismo hueco, lo que por lo menos sería confuso.
