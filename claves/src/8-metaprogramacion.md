# Capítulo 8. Metaprogramación y macros

```@setup c8
using Random, Fracciones
Random.seed!(123)
```

## Ejemplo: abreviando código mediante metaprogramación

En este capítulo nos adentraremos en estrategias de programación algo más avanzadas. El objetivo de las herramientas y técnicas que vamos a ver no consiste tanto en procesar información y hacer cálculos, que es normalmente el objetivo final de los programas, sino generar el código que se usará para eso. La *metaprogramacion* es, se podría decir, escribir código que genera código, normalmente para abreviar la cantidad de líneas que hay que escribir a mano, o hacer el código fuente más fácil de seguir por un humano.

Veamos un ejemplo en el código del paquete [Fracciones](https://github.com/heliosdrm/Fracciones.jl). En él hay tenemos un método `Base.:+` definido para dos argumentos de tipo `Fraccion`, que nos permite hacer la suma de dos fracciones, por ejemplo:

```@repl c8
a = Fraccion(1, 5);
b = Fraccion(2, 5);
a + b
```

Por otro lado, también interesaría poder hacer la suma entre una fracción y cualquier otro número real que se pudiera convertir a una fracción. Esto se puede hacer sin ningún código adicional, gracias a que el tipo `Fraccion` está definido como un subtipo de `Real`, y también se han implementado las reglas de promoción de tipos adecuadas. Así pues, al sumar una fracción y cualquier otro número real la conversión correspondiente se realiza de forma automática (véase la sección sobre [Conversión y promoción de tipos](@ref) en el capítulo 5). Por ejemplo:

```@repl c8
Fraccion(1, 2) + 1
```

Pero para los propósitos de este capítulo, vamos a suponer que las reglas de promoción automática no estuviesen implementadas. Entonces, sería necesario definir de forma explícita los métodos para sumar una fracción y un número real cualquiera. Esto podría hacerse del siguiente modo:

```julia
Base.:+(x::Fraccion, y::Real) = x + Fraccion(y)
Base.:+(x::Real, y::Fraccion) = Fraccion(x) + y
```

Ahora bien, lo adecuado sería hacer lo mismo con otras operaciones como la resta, la multiplicación, la división, y también con los operadores de comparación entre números. Así, por ejemplo la resta la definiríamos del siguiente modo:

```julia
Base.:-(x::Fraccion, y::Real) = x - Fraccion(y)
Base.:-(x::Real, y::Fraccion) = Fraccion(x) - y
```

Podemos ver que el código de los métodos para la suma y la resta son casi idénticos, excepto por el símbolo que define la operación (`+` y `-`, respectivamente). Y lo mismo ocurre para todas las demás operaciones que estamos considerando. Así pues, escribir todos esos métodos nos obligaría a repetir una cantidad considerable de código, multiplicando también el riesgo de cometer algún error (probablemente por algún desliz al copiar y pegar).

La metaprogramación nos permite evitar ese tipo de repeticiones, o mejor dicho, programarlas para que se efectúen de forma automática. A nivel abstracto podríamos decir que lo que queremos es que nuestro código incorpore varias repeticiones del siguiente patrón, donde `OPERADOR` toma los valores de `+`, `-`, `*`, `/`, `==` y `<`.

```julia
Base.:OPERADOR(x::Fraccion, y::Real) = x OPERADOR Fraccion(y)
Base.:OPERADOR(x::Real, y::Fraccion) = Fraccion(x) OPERADOR y
```

Pues bien, eso mismo es lo que hace el siguiente código, empleando el bucle `for` y la macro `@eval`:

```julia
for op ∈ (:+, :-, :*, :/, :(==), :<)
    @eval Base.$op(x::Fraccion, y::Real) = x $op Fraccion(y)
    @eval Base.$op(x::Real, y::Fraccion) = Fraccion(x) $op y
end
```

Se puede ver que la expresión escrita después de `@eval` para cada uno de los dos métodos es precisamente el patrón definido antes, cambiando `OPERADOR` por `$op`. De esa forma interpolamos el contenido de la variable `op` en el resto de la expresión, igual que se haría con una cadena de texto. Esa variable está definida en el bucle como cada uno de los operadores que queremos extender.[^1]

[^1]: Para más información puede consultarse la sección sobre cadenas de texto y símbolos en el [manual básico](https://hedero.webs.upv.es/julia-basico/2-series-tablas/#Cadenas-de-texto-y-s%C3%ADmbolos). Los símbolos se escriben precediéndolos siempre por dos puntos; el de la comparación de igualdad, `:(==)`, tiene que escribirse entre paréntesis después de los dos puntos para evitar ambigüedades.

## Evaluación de expresiones

Las expresiones son un tipo más de objetos, concretamente del tipo `Expr`, que se pueden asociar a variables igual que cualquier otro objeto en Julia. Las expresiones son algo parecido a cadenas de texto, con la diferencia de que el texto representado en una expresión ha de tener la sintaxis de un fragmento de código ejecutable en Julia. Por ejemplo, `x + y` sería una expresión válida, mientras que `for x` no lo es, porque está incompleta.

Internamente las cadenas de texto y las expresiones son muy distintas. Las cadenas de texto están compuestas por una secuencia de códigos que representan las letras y otros caracteres, mientras que las expresiones están compuestas por un conjunto de símbolos (elementos de tipo `Symbol`), en una estructura complicada que define las relaciones entre operandos, operadores y otros elementos que constituyen el código representado.

Hay dos formas de escribir expresiones. Las más sencillas se pueden escribir entre paréntesis precedidos por dos puntos, como por ejemplo `:(x + y)`. Delimitarlas de esta manera permite distinguir las dos siguientes operaciones, que son muy distintas:

```julia
z = x + y
z = :(x + y)
```

La primera de ellas asigna a `z` el resultado de sumar `x` e `y`, mientras que la segunda le asigna la expresión que representa esa suma. Un detalle a destacar es que las expresiones han de representar código *sintácticamente válido*, pero eso no significa que ese código se pueda ejecutar. Por ejemplo, si las variables `x` o `y` no existiesen (o representasen elementos que no se pueden sumar), la primera línea daría lugar a un error, pero la segunda se ejecutaría sin ningún problema.

La otra forma de escribir expresiones es como un bloque entre las palabras `quote` y `end`, lo cual suele hacerse cuando se trata de expresiones complicadas, compuestas por varias líneas de código, por ejemplo:

```julia
quote
    z = x + y
    w = z^2 - z
end
```

Las expresiones pueden ejecutase pasándolas como argumento a la función `eval`, o también con la macro `@eval`, que es lo que se ha hecho antes, en el ejemplo de los métodos para fracciones y otros números. Usar la función `eval` resulta conveniente cuando tenemos la expresión a evaluar en una variable, mientras que la macro hace que el código sea más legible cuando la expresión se escribe directamente, ya que no hace falta añadir los delimitadores `:()` o `quote`/`end`.

La clave de la metaprogramación es que las expresiones y los símbolos se pueden componer y modificar, creando nuevas expresiones programáticamente. Hay diversas formas de hacerlo, aunque la más habitual es la interpolación con el símbolo `$`, como en el ejemplo mostrado anteriormente.

## Contexto de variables para `eval`/`@eval`

La flexibilidad que proporciona la función `eval` (así como la macro `@eval`, que hace esencialmente lo mismo) la convierte en un recurso de programación muy atractivo, pero tiene un precio y unas limitaciones que desaconsejan su uso indiscriminado.

El principal problema es que su capacidad de evaluar código arbitrario conlleva la incapacidad de anticipar qué información se va a procesar y qué se tiene que hacer con ella. El código de la expresión que se pasa a `eval` no se analiza hasta el mismo momento en que se ejecuta (lo que en inglés se conoce como *runtime*), por lo que algunas operaciones que necesitan un análisis previo no se pueden llevar a cabo.

Para empezar, no se puede hacer ninguna inferencia sobre el tipo de variables que se van a procesar, ni otras optimizaciones que ayuden a acelerar el procesado del código. Pero posiblemente la limitación más importante es la del contexto de las variables involucradas. Julia emplea contextos léxicos, lo que significa que las variables locales de una función, un bucle, etc., se determinan durante el análisis del código, antes de proceder a ejecutarlo.

Esto deja fuera las variables que están escritas como parte de expresiones pasadas a `eval`, y por lo tanto estas no pueden participar en los contextos locales. Así pues, el código evaluado de esta manera solo trabaja con variables globales, incluso si se ejecuta en un contexto local. Por ejemplo, consideremos la siguiente función:

```@example c8
function raizpositivo(x)
    y = abs(x)
    println("Raíz cuadrada del valor absoluto:")
    y = sqrt(y)
    return y
end
nothing #hide
```

El comportamiento de esta función es obvio:

```@repl c8
raizpositivo(-2)
```

Pero ahora cambiemos la primera línea por la evaluación de una expresión equivalente (lo cual es una tontería, pero nos ayuda a mostrar la limitación de de la que estamos hablando):

```@example c8 
function raizpositivo_eval(x)
    @eval y = abs(x)
    println("Raíz cuadrada del valor absoluto:")
    y = sqrt(y)
    return y
end
nothing #hide
```

```@repl c8
raizpositivo_eval(-2)
```

El error dice que la variable `x` no existe, porque la busca en el contexto global, donde no la hemos definido. Por otro lado, si la definimos:

```@repl c8
x = -3
raizpositivo_eval(-2)
```

Ahora la primera línea se ha ejecutado (por eso podemos ver el mensaje que se envía en la siguiente línea, con `println`). Pero en la siguiente operación se intenta utilizar una variable *local* (`y`), que no se había llegado a definir; sin embargo en el entorno global:

```@repl c8
y
```

Las cosas aparentemente extrañas que pasan en estos ejemplos dan un claro mensaje: normalmente no hay que usar `eval` o `@eval` dentro de funciones, salvo que el propósito de la función sea precisamente añadir o modificar objetos del contexto global. Un caso legítimo para hacerlo sería en una situación parecida a la del ejemplo con el que comenzábamos este capítulo. En este caso podríamos haber definido una función como la que sigue para extender métodos:

```julia
function extiendemetodos(fun::Function)
    sfun = nameof(fun)
    @eval Base.$sfun(x::Fraccion, y::Real) = $sfun(x, Fraccion(y))
    @eval Base.$sfun(x::Real, y::Fraccion) = $sfun(Fraccion(x), y)
end
```

Y luego esa función se podría haber aplicado en bucle a los operadores que se han señalado, teniéndola también disponible por si se quiere aplicar a otras funciones en un sitio distinto.

!!! note "Contexto de las variables interpoladas en expresiones"
    
    Conviene aclarar que lo que pertenece al contexto global al usar `eval` son las variables *referidas* en la expresión que se tiene que evaluar. Por contra, las variables *interpoladas* para crear las expresiones siguen las reglas normales, y pueden ser globales o locales. Por ejemplo, Si se evalúa la expresión `:(x + $y)`, `x` se tomará siempre del contexto global, mientras que `y` (interpolada como `$y`) se habrá sustituido antes de la evaluación por el valor que corresponda de la variable `y`, sea esta global o local.

La limitación del contexto en el que se pueden ejecutar las expresiones con `eval` tiene una contrapartida, y es que se puede utilizar para *hackear* otros módulos. En general no está permitido crear nuevas variables en un módulo `A` desde otro módulo `B`, ni que se les asigne nuevos valores si ya existen esas variables. Lo vemos con un ejemplo, en el que intentamos manipular `A` desde `Main`:

```@repl c8
module A
x = 1
end;
A.y = 0 # nueva variable
A.x = 0 # reasignación
```

Sin embargo, el módulo se puede pasar como primer argumento a `@eval` para que la expresión que sigue se ejecute como si estuviésemos en ese módulo:

```@repl c8
@eval A y=0
A.y
```

Si en lugar de la macro queremos usar la función `eval`, tenemos dos opciones:

* Usar el método `Base.eval`, que permite pasarle el módulo objetivo como primer argumento.
* Usar la función `eval` del módulo objetivo (cuando se define un módulo se crea por defecto una función `eval` asociada al mismo).

Así, la instrucción equivalente a `@eval A y=0` sería:

```julia
Base.eval(A, :(y=0))
A.eval(:(y=0))
```

## Evaluación de código con `include`

La evaluación de archivos de código a través de la función `include` no suele considerarse una técnica de metaprogramación, porque lo habitual es escribir ese código de forma manual, no programándolo. Pero dejando ese aspecto al margen, `include` y `eval` funcionan de forma muy semejante, y gran parte de lo que se ha comentado antes sobre `eval` se puede aplicar también a `include`.

Concretamente, cuando ejecutamos la instrucción `include(script)`, lo que hace Julia es leer el archivo identificado por la ruta `script` como una cadena de texto, y a continuación evaluar secuencialmente las expresiones contenidas en ese texto, en el contexto global del módulo desde el que se ha llamado a `include`.

Al igual que ocurre con `eval`, con `include` también se puede forzar que el código se ejecute en el contexto de un módulo `A` arbitrario, usando `Base.include(A, script)`, o `A.include(script)`.

Todas estas funciones emplean internamente la función `include_string`, que se puede utilizar igual que `Base.include` o `Base.eval`, pasándole el módulo objetivo como primer argumento, y que sí sirve como herramienta de metaprogramación, ya que como segundo argumento toma una cadena de texto que puede ser generada programáticamente. Es más, `include_string` tiene también un método que toma una función como primer argumento, para transformar las instrucciones que se ejecutan.

## Macros

### ¿Para qué sirven las macros?

Las macros son la herramienta de metaprogramación de Julia más usada, aunque seguramente es también la menos comprendida, lo que provoca no pocos quebraderos de cabeza a los programadores. En este capítulo intentaremos explicarlas de forma comprensible, para poder hacer un uso eficaz de las mismas.

Es fácil reconocer el uso de macros, que son esos comandos cuyo nombre empieza por el símbolo `@`. En este mismo capítulo hemos visto el uso de `@eval`, y en capítulos anteriores también hemos visto las macros `@test` y `@doc`, entre muchas otras que se usan de forma habitual. Lo que no suele resultar tan fácil es entender cuál es su propósito en general, ya que hacen cosas muy diversas: algunas parecen simples funciones, otras alteran las instrucciones que se escriben después del nombre de la macro, o ejecutan operaciones adicionales...

A grandes rasgos, el propósito de las macros es proporcionar al usuario atajos para expresar operaciones que, si nos limitásemos a la sintaxis estándar de Julia, serían más complicadas de escribir. Veamos el caso de la macro `@eval`, por ejemplo. Hemos visto al principio del capítulo cómo se podría usar para definir una serie de operaciones, con instrucciones como:

```julia
@eval Base.$op(x::Fraccion, y::Real) = x $op Fraccion(y)
```

En el fondo, lo que hace la macro es sustituir el código que se le pasa por la siguiente operación con la función `eval`:

```julia
eval(:(Base.$op(x::Fraccion, y::Real) = x $op Fraccion(y)))
```

Aunque la diferencia es pequeña, la instrucción con la macro es algo más "limpia" y fácil de leer, pues la expresión a evaluar se puede escribir sin los delimitadores que son imprescindibles con la sintaxis estándar.

En el paquete Fracciones.jl también está definida la macro `@fraccion`, cuyo *docstring* la describe como sigue:

````md
    @fraccion x/y
    
Crea una fracción equivalente la expresión `x/y`.

Si las partes de la expresión `x` e `y` contienen otras divisiones,
estas se interpretan también como fracciones.

# Ejemplo

```
julia> @fraccion (1+(5/2))/3
Fraccion(7, 6)
```
````

Realmente, lo que hace esta macro es sustituir las divisiones por llamadas a la función `fraccion`; por ejemplo `5/2` se sustituye por `fraccion(5, 2)`, y la operación completa por:

```julia
fraccion(1 + fraccion(5, 2), 3)
```

Y al realizarse esa operación se obtiene el resultado señalado en el *docstring*, `Fraccion(7, 6)`.

Lo que hacen todas las macros es, en esencia, tomar una o más expresiones de entrada, manipularlas, y reemplazarlas por otra expresión con las instrucciones que realmente se desean ejecutar. La forma exacta de la expresión resultante se puede obtener mediante otra macro: `@macroexpand`. Así, por ejemplo:

```@repl c8
@macroexpand @fraccion (1+(5/2))/3
```

(Más adelante se comentará por qué la función `fraccion` aquí va precedida del nombre del módulo `Fracciones`.)

Para ampliar la perspectiva de cómo las macros sirven para transformar expresiones, podemos mostrar el resultado de la macro `@assert`, que se aplica a operaciones que dan un resultado lógico (`true` o `false`), y hace que se emita un mensaje de error si el resultado es `false`:

```@repl
@macroexpand @assert sqrt(4) ≈ 2
```

En este ejemplo hemos pasado a `@assert` la expresión `sqrt(4) ≈ 2`, que se utiliza en dos sitios de la expresión resultante: por una parte se copia tal cual en la condición `if` de la primera línea, y por otra se emplea como mensaje de error en el caso de que no se cumpla la condición.

### Definición y funcionamiento de las macros

Las macros se definen como sigue (las palabras en mayúsculas se usan para distinguir los elementos propios de cada macro):

```julia
macro NOMBRE(ARGUMENTOS)
    CÓDIGO
end
```

A nivel superficial es la misma estructura que se usa para definir funciones, aunque en lugar de la palabra `function` se emplea `macro`, y también hay otras diferencias notables. `NOMBRE` es el nombre de la macro (sin el símbolo `@` que se emplea para llamarla); por otro lado `ARGUMENTOS` es una lista de argumentos, como las de las funciones, pero en el caso de las macros, estos argumentos solo pueden ser expresiones (una o más de una), y el resultado devuelto por la macro también ha de ser otra expresión.

La forma de llamar las macros también es distinta a la de las funciones: su nombre tiene que ir precedido del símbolo `@`, y a pesar de que los argumentos sean expresiones, se escriben "a pelo", sin delimitarlas con `:()` o `quote ... end` También es habitual llamar a las macros sin poner paréntesis a los argumentos que siguen; es válido añadir los paréntesis, pero si se hace es importante que no haya ningún espacio entre el nombre de la macro y el paréntesis, lo cual no es crítico en el caso de las funciones

Finalmente, la diferencia más profunda y compleja entre funciones y macros es cómo se ejecutan y el efecto que tienen sobre los programas: las macros actúan en la fase de análisis del código, y la expresión que generan se inserta en el mismo sitio donde se ha hecho la llamada a la macro, antes de continuar con la fase de ejecución.

## Una macro paso a paso

Vamos a observar con más detalle la forma en la que operan las macros, con un ejemplo que contiene una macro muy sencilla, que solo implica instrucciones de imprimir en pantalla. Esta macro es:

```@example c8
macro ejemplo(ex)
    println("ANÁLISIS DE CODIGO: se ejecuta la macro con $ex")
    quote
        println("EJECUCIÓN DE CÓDIGO: variable del contexto global = ", $ex)
        println("EJECUCIÓN DE CÓDIGO: variable del contexto presente = ", $(esc(ex)))
    end
end
```

A continuación definimos una función que emplea esa macro:

```@repl c8
function foo(x)
    println("Valor local de x en la función :", x)
    @ejemplo x
    @ejemplo -x
end
```

Aquí ya podemos ver un aspecto peculiar de las macros, y es que como se ha dicho antes, actúan durante la fase de análisis de código, antes del *runtime*. Así, aunque lo único que hemos hecho ahora es *definir* una función (sin ejecutarla), las dos llamadas a la macro `@ejemplo` contenidas en esa definición sí hacen que se ejecute el código de la macro. Esto lo prueba el hecho de que se impriman los dos mensajes con el texto `"ANÁLISIS DE CÓDIGO"`. Hay, además, dos detalles a destacar:

* De las tres líneas con `println` que hay en el código de la macro, solo se ejecuta la primera, porque es la única en la que se hace una llamada "real" a esa función. Las otras dos líneas son solo parte de la expresión generada por la macro, que no se evalúa en este momento, sino que se se inserta en en el código de la función.
* Los argumentos `x` y `-x` que se pasan a la macro son meras expresiones, ajenas a la variable `x` que se emplea en la función. De hecho, habría dado lo mismo que no existiera. Así, el mensaje presentado en pantalla solo muestra el valor del símbolo `:x` --o la expresión `:(-x)` en el segundo caso.

Ahora veamos qué pasa si definimos una variable `x` y ejecutamos la macro `@example` en el contexto global:

```@repl c8
x = 1;
@ejemplo x
```

Al llamar a la macro se vuelve a ejecutar su código, por lo que vemos de nuevo el mensaje `"ANÁLISIS DE CÓDIGO..."`. Pero además se inserta e inmediatamente después se evalúa la expresión resultante, lo que da lugar a las otros dos mensajes con `"EJECUCIÓN DE CÓDIGO..."`. Los dos mensajes son iguales, aunque resultan de dos instrucciones distintas. Podemos ver la forma exacta que toman esas instrucciones con `@macroexpand`:

```julia-repl
julia> @macroexpand @ejemplo x

quote
    #= REPL[4]:4 =#
    Main.println("EJECUCIÓN DE CÓDIGO: variable del contexto global = ", Main.x)
    #= REPL[4]:5 =#
    Main.println("EJECUCIÓN DE CÓDIGO: variable del contexto presente = ", x)
end
```

Las dos líneas de la expresión resultante hacen referencia a la variable `x`, primero como global de `Main`, y luego sin cualificar, debido a que en el código de la macro, en la segunda línea se ha usado la función `esc`, de la que luego hablaremos. En el contexto presente (global) ambas `x` son lo mismo.

Pero ahora vamos a ver el resultado de ejecutar la función `foo` con otro valor:

```@repl c8
foo(2)
```

Aquí hemos asignado el valor `2` al argumento de la función, que se asocia a una variable `x` *local*. El código de la función `foo`, recordemos, consta de la línea con `println` que muestra el valor de esa variable local, y ademaś incorpora dos veces la expresión de haber ejecutado la macro `@ejemplo`. La primera es como la que hemos visto antes; y la segunda, como recibió el argumento `-x`, es:

```julia
quote
    #= REPL[4]:4 =#
    Main.println("EJECUCIÓN DE CÓDIGO: variable del contexto global = ", -Main.x)
    #= REPL[4]:5 =#
    Main.println("EJECUCIÓN DE CÓDIGO: variable del contexto presente = ", -x)
end
```

En el contexto de la función no es lo mismo la `Main.x` que `x`, pues esta última hace referencia a la variable local. Así que los mensajes que vemos al ejecutar la función muestran valores distintos para cada uno de los contextos (`1` para `Main.x`, y `2` para `x`).


## Diferencias entre macros y `eval`

Tanto las macros como `eval` utilizan como entrada expresiones que representan código de un programa, pero hacen cosas muy distintas con ese código. `eval` opera en la fase de ejecución (en *runtime*), y todo lo que hace es ejecutar el código representado en la expresión de entrada. Por contra, lo que hacen las macros es sustituir unas expresiones de entrada (pueden tener más de una) por otra durante la fase de análisis del código (en *parsetime*). La ejecución de ese código puede darse inmediatamente después, o en cualquier momento posterior, según corresponda por su contexto.

Este último detalles es clave: las macros no evalúan las expresiones que generan, lo que hacen es insertarlas en el código antes de la fase de ejecución. Esto evidencia una gran ventaja de las macros, que al contrario que `eval` sí son aptas para usar en funciones y otros contextos locales. Al ejecutarse durante el análisis de código, las expresiones generadas por una macro llegan a tiempo de que las variables que contienen se incluyan en contextos locales, y también se pueden compilar.

Cabe preguntarse entonces: ¿por qué decíamos arriba que la macro `@eval` no puede evaluar expresiones en entornos locales? El motivo es que si, por ejemplo, en un punto de programa aparece la línea `@eval x = y`, al invocarse la macro esta línea se sustituye por una expresión que llama a la función `Core.eval` con la expresión `:(x = y)`. Es decir, que en la expresión resultante las variables `x` e `y` no existen como tales, sino como símbolos dentro el argumento que se pasa a la función `eval`.

## "Higiene de macros"

Las macros, igual que las funciones o los tipos, pueden usarse en contextos completamente ajenos a aquellos en los que están definidas; es más, lo habitual es que ese sea precisamente su propósito. En el caso de las funciones o los tipos, el hecho de que Julia emplee contextos léxicos protege de posibles conflictos: si en mi espacio de trabajo tengo una variable `x`, y uso la función de un paquete cuyo código también hace referencia a una variable `x`, puedo confiar en que esa función no va a interferir con mi `x`, porque su código estará haciendo referencia a alguna variable local de la función, o en todo caso a una global de su contexto circundante. La única forma que tiene una función de interactuar con objetos del contexto desde el que se les llama es pasándoselos como argumento, lo cual hace que esos objetos se vinculen a variables locales.

Con las macros la situación es algo más complicada, porque el código generado se inserta en el lugar desde el que se las llama. Eso rompe la barrera entre contextos, que se compensa con una una transformación de los símbolos utilizados en las expresiones, lo que se conoce como "higiene de las macros".

La macro `@ejemplo` que hemos utilizado antes nos ha mostrado parte de cómo funciona ese mecanismo de higiene. La primera línea de la expresión que genera está definida en su código como:

```julia
println("EJECUCIÓN DE CÓDIGO: variable del contexto global = ", $ex)
```

Pero cuando veíamos con `@macroexpand` el código realmente generado --dando a la expresión `ex` el valor del símbolo `:x`--, nos encontramos con lo siguiente:

```julia
Main.println("EJECUCIÓN DE CÓDIGO: variable del contexto global = ", Main.x)
```

Lo que ha ocurrido es que al "expandirse" la expresión generada por la macro, los símbolos `:println` y `:x` que aparecen en ella se han cualificado como objetos de `Main`, que es donde hemos definido la macro. Si la macro fuera parte de otro módulo, veríamos el nombre de ese módulo en lugar de `Main`, y lo mismo ocurriría con cualquier otro símbolo utilizado en la expresión generada. De ese modo, es seguro que las funciones y variables incluidas en ese código se refieren a objetos conocidos en el contexto donde se definió la macro, y que no interferirán con las del contexto desde el que se le llama.

Naturalmente, es habitual que también se quiera interactuar con objetos del contexto en el que se aplica la macro, igual que se hace con los argumentos de las funciones. El recurso que se utiliza en esos casos es la función `esc`, que anula los mecanismos de higiene sobre los símbolos y expresiones a los que se aplica. Hemos visto cómo funciona en la segunda línea de la expresión generada por la macro `@ejemplo`:

```julia
println("EJECUCIÓN DE CÓDIGO: variable del contexto presente = ", $(esc(ex)))
```

El código generado en este caso era:

```julia
Main.println("EJECUCIÓN DE CÓDIGO: variable del contexto global = ", x)
```

Así pues, al interpolar `esc(ex)` en lugar de simplemente `ex`, se ha omitido el prefijo `Main` de la variable `x`, y cuando se evalúa la expresión en esta segunda línea se utiliza el valor de `x` en el mismo contexto en el que se llama a la macro, no en el de su definición.

Las expresiones generadas por macros también pueden contener líneas que definen nuevas variables. Veamos por ejemplo la siguiente macro, una versión simplificada de `@time`, que mide el tiempo que tarda en ejecutarse una instrucción:

```@example c8
macro cronometrar(expresion)
    quote
        inicio = time()
        resultado = $(esc(expresion))
        final = time()
        println("Tiempo transcurrido: ", (inicio-final)/1e9, " segundos")
        resultado
    end
end
nothing #hide
```

En la expresión generada se definen las variables `inicio`, y `final`, que se utilizan para calcular el tiempo transcurrido, más `resultado`, que es lo que resulta de ejecutar la expresión original. Estas variables tienen que crearse en el contexto en el que se llama a la macro, pero no queremos que exista el riesgo de confundirlas con otras variables que podrían existir con el mismo nombre. La medida de higiene en este caso es sustituir los nombres que aparecen en el código de la macro por un nombre "ofuscado", como se ve a continuación:

```julia
julia> @macroexpand @cronometrar x = sum(rand(100_000))
quote
    #= REPL[4]:3 =#
    var"#9#inicio" = Main.time()
    #= REPL[4]:4 =#
    var"#10#resultado" = (x = sum(rand(100000)))
    #= REPL[4]:5 =#
    var"#11#final" = Main.time()
    #= REPL[4]:6 =#
    Main.println("Tiempo transcurrido: ", (var"#9#inicio" - var"#11#final") / 1.0e9, " segundos")
    #= REPL[4]:7 =#
    var"#10#resultado"
end
```

Podemos ver aquí que el nombre `inicio` se ha reemplazado por `var"#9#inicio"`, y lo mismo se ha hecho con `resultado` y `final`. Esto asegura que las variables definidas a través de la macro no coincidan con nombres normales. También en este caso `esc` omite la ofuscación, de manera que las variables generadas se identifiquen con el mismo símbolo que aparece en el código de la macro. Así, si ejecutamos la macro obtenemos:

```@repl c8
@cronometrar x = sum(rand(100_000))
```

Se puede ver que la expresión introducida, que se interpola con la función `esc`, se mantiene tal cual en el código generado, pero la función `time` se señala como la existente en `Main` (donde hemos definido la macro), y las variables `inicio`, `resultado` y `final` aparecen con el nombre ofuscado. De ese modo, podemos confiar en que no se aplicará una posible función `time` que pudiera haberse definido aparte, ni habrá problemas en el caso de que existan otras variables con esos mismos nombres en el contexto donde se llamó a la macro.

Estas operaciones de higiene se aplican por defecto a todos los nombres que aparecen en la expresión generada, exceptuando las que se introducen con `esc`. Pero puede haber circunstancias en las que resultaría más conveniente lo contrario: que la mayor parte de la expresión generada aparezca tal como se escribe en la definición de la macro, con algunas excepciones puntuales. La forma de conseguirlo sería aplicar la función `esc` a todo el resultado de la macro, cualificando adecuadamente las variables o funciones que correspondan a módulos distintos de aquel desde el que se le llama, y señalando como `local` las variables que se desee mantener "ocultas".

Por ejemplo, la macro `@cronometrar` podría haberse definido del siguiente modo, que daría un resultado equivalente.[^2]

```julia
macro cronometrar(expresion)
    quote
        local inicio = Base.time()
        local resultado = $expresion
        local final = Base.time()
        println("Tiempo transcurrido: ", (inicio-final)/1e9, " segundos")
        resultado
    end |> esc
end
```

[^2]: La función `esc` se ha aplicado a la expresión generada con el operador `|>`, que en este caso resulta más conveniente que escribir `esc(quote ... end)`. En general, `x |> f` es equivalente a escribir `f(x)`.

## Construcción de expresiones con MacroTools

Las macros que añaden código antes o después de la expresión introducida, como `@assert` o `@time`, son relativamente fáciles de construir, pero a menudo lo que se busca son modificaciones que requieren analizar y manipular los elementos de la expresión, y eso resulta bastante más complicado. Ese es, por ejemplo, el caso de la macro `@fraccion`, que tiene como finalidad cambiar todas las operaciones de división por la función `fraccion`.

Para facilitar la tarea, esa macro se auxilia del paquete [MacroTools](https://fluxml.ai/MacroTools.jl/stable/)[^3], que proporciona varias utilidades que ayudan a analizar y modificar expresiones. En particular, el código de la macro consiste en lo siguiente:

```julia
macro fraccion(ex)
    MacroTools.postwalk(ex) do subex
        hayfraccion = @capture(subex, num_ / den_)
        if hayfraccion
            return :(Fracciones.fraccion($num, $den))
        else
            return subex
        end
    end |> esc
end
```

[^3]: En particular, se ha usado la versión 0.5 de MacroTools.

Las dos herramientas empleadas son la función `postwalk` y la macro `@capture`. `MacroTools.postwalk` recorre una expresión dada, reemplazando recursivamente cada una de las subexpresiones contenidas por una transformación de la misma, que es precisamente lo que queremos hacer (reemplazar divisiones por llamadas a `fraccion`). En este caso la expresión introducida (`ex`) coincide con la que se pasa a la macro; y la función de transformación es la que se define en las siguientes líneas, tomando como argumento la variable `subex`, que identifica cada subexpresión dentro de la expresión original.[^4]

[^4]: Realmente `MacroTools.postwalk` se define con dos argumentos: el primero es la función de transformación, y el segundo la expresión a transformar. Los "bloques `do`" son un recurso aplicable a funciones que siguen ese patrón (su primer argumento es otra función), que permite escribir esa "función-argumento" de una forma más conveniente. (Véase la sección al respecto en el [manual de Julia](https://docs.julialang.org/en/v1/manual/functions/#Do-Block-Syntax-for-Function-Arguments)).

Dentro de esa función de transformación se usa la macro `@capture`, que toma cada subexpresión y busca en ella el patrón de una división: `num_ / den_`, donde `num_` y `den_` indican cualquier símbolo o expresión. Por ejemplo, la subexpresión `:(5/2)` daría un resultado positivo, mientras que `:(1+2)` daría un resultado negativo. Ese resultado se refleja en el valor devuelto por `@capture` (la variable `hayfraccion`). Pero además, si se ha encontrado el patrón, los dos elementos definidos en él quedan "capturados" en variables con el mismo nombre pero sin el guión bajo final. En el ejemplo positivo anterior, se crearía una variable `num=5` y otra `den=2` (en el ejemplo negativo no se crearía ninguna variable).

Esto se usa para construir la expresión de reemplazo, donde `num` y `den` aparecen interpolados como argumentos de la función `fraccion`. Si no se encuentra el patrón, se devuelve la subexpresión sin modificaciones.

Todos los elementos de la expresión resultante proceden de la original, excepto la función `fraccion` que es propia del paquete `Fracciones`. Por eso este es uno de esos casos donde vale la pena aplicar `esc` a toda la expresión, y simplemente cualificar la función `fraccion`, como se ha visto antes.

Este es solo un ejemplo ilustrativo de una macro algo más compleja, que incluso con la ayuda de herramientas como el paquete MacroTools puede ser necesario examinar unas cuantas veces para asimilar. La construcción de macros es un tema que puede resultar bastante complicado, y que también presenta muchas otras facetas que no exploraremos aquí. Para más información, se puede acudir a la sección de [Metaprogramación](https://docs.julialang.org/en/v1/manual/metaprogramming/) del manual oficial de Julia, o la [introdución interactiva de Simon Danisch en Nextjournal](https://nextjournal.com/a/KpqWNKDvNLnkBrgiasA35?change-id=CQRuZrWB1XaT71H92x8Y2Q).


