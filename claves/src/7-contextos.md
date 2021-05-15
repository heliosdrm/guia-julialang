# Capítulo 7. Contextos de variables

Los contextos de variables son un recurso de los lenguajes de programación para reducir el riesgo de confusiones y conflictos de nombres en programas complejos. Su finalidad es mantener espacios de nombres separados para distintas partes del programa, lo que permite usar los mismos nombres para distintas variables, funciones u otros objetos, siempre que el alcance (*scope* en inglés) de esas asociaciones entre nombres de variables y valores referidos por ellas se limiten a contextos distintos.[^1] Es como lo que ocurre, por ejemplo, con los nombres de las calles en distintas poblaciones: hay muchas ciudades y pueblos que tienen una "Calle Mayor"; pero mientras se esté en un contexto dado (población), se puede indicar a alguien que vaya a la Calle Mayor sin ningún tipo de ambigüedad.

[^1]: Se usa el nombre de contextos de *variables* por simplificar, pero hablamos de contextos para nombres que pueden identificar variables, constantes, tipos, funciones o cualquier otro tipo de objeto.


!!! note "*Scope*: ¿alcance o contexto?"
    
    Para tratar este tema en inglés se suele utilizar el término *scope*, que estrictamente se refiere al alcance de una variable; es decir la región de código en la que se reconoce su asociación particular con un valor dado. Lo normal es que distintas variables que se definen en el mismo fragmento de código tengan el mismo alcance, delimitado por ciertas estructuras (funciones, bloques de código...). Estas estructuras que delimitan el alcance de un conjunto de variables es lo que llamamos un "contexto de variables". Dada la proximidad entre estos conceptos de "alcance" y "contexto", en la jerga informática se suele usar el término *scope* de forma indistinta para referirse a ambas cosas.

Normalmente el funcionamiento de los contextos de variables es bastante lógico, por lo que la mayoría de programas se pueden escribir dando nombre a las variables y refiriéndose a ellas de forma natural, según dicta la intuición. Sin embargo, para usar ciertos recursos avanzadados, y en particular los que se verán en los siguientes capítulos, conviene aclarar algunos detalles, que es el propósito de este capítulo.

Buena parte de los conceptos tratados en este capítulo ya se han presentado en capítulos anteriores de esta guía y en la "guía básica" (en particular en [uno de los capítulos sobre funciones](https://hedero.webs.upv.es/julia-basico/8-funciones-avanzado)), pero aquí los recogemos de forma más completa y detallada. Aun así, para definiciones y explicaciones precisas de todos los conceptos se puede consultar la sección correspondiente del [manual oficial de Julia](https://docs.julialang.org/en/v1/manual/variables-and-scoping/).

## Módulos y contextos globales

La cuestión más importante en este tema es la distinción entre contextos *locales* y *globales*. Los contextos locales son variados, y se encuadran en el código de las funciones, bucles, bloques `let`, y en general casi todo tipo de estructuras cerradas de código, excepto los bloques `if`(incluyendo `elseif` y `else`), y los delimitados por `begin`/`end`. Como se puede adivinar por su nombre, los contextos locales siempre se encuentran dentro de otro global.

En este punto hay que aclarar que aunque el término "global" haga pensar en un único elemento en el que se enmarca todo lo demás, en Julia normalmente no hay un solo contexto global. De hecho, cada módulo delimita su propio contexto global, por lo que se dan tantos contextos globales como módulos haya en uso. El contexto global del módulo `Main`, que siempre está presente, es el que delimita el alcance de las variables que se definen durante una sesión interactiva, o cuando se lanza una sesión de Julia para ejecutar un *script*.

Cuando se utiliza la función `include`, el archivo introducido se ejecuta en el contexto del módulo desde el que se llama a la función. Esto lo hemos visto indirectamente en el paquete Fracciones, concretamente en el archivo `src/Fracciones.jl`, que tiene el siguiente código:

```julia
module Fracciones
export Fraccion, numerador, denominador, fraccion, reciproco, @fraccion
include("fraccion.jl")
end # module
```

La línea `include("fraccion.jl")`, al encontrarse dentro del modulo `Fracciones`, hace que el alcance de los elementos definidos en el archivo `fraccion.jl` (los mismos que están indicados en la línea `export`) sea ese módulo. Por otro lado, si se ejecutase la misma instrucción en el REPL, esos objetos se definirían en el contexto de `Main`.

Que unas variables pertenezcan a un contexto global dado no impide que se puedan acceder indirectamente desde otro. Supongamos que ejecutamos el siguiente código en `Main` (por ejemplo desde el REPL):

```julia
x = 1   # En el contexto de `Main`
module Foo
    x = 2  # En el contexto de `Foo`
end
```

Aquí tenemos el nombre de variable `x` definido con dos valores distintos en sendos contextos globales, de forma independiente y sin interferirse entre ellos. Pero desde `Main` no solo podemos acceder a su versión de `x`, sino también a la de `Foo` --especificándola como `Foo.x`--.

### Importación de variables entre módulos

La situación se complica cuando se carga un módulo importando objetos del mismo. Por ejemplo, al ejecutar `using Fracciones` desde `Main`, todos los nombres exportados (el del tipo `Fraccion`, las funciones `numerador`, `denominador`, etc.) aumentan su alcance, y son reconocibles en `Main` --a no ser que ya existan variables u otros objetos en `Main` con esos nombres, en cuyo caso la importación no tiene lugar--. Esta operación rompe parcialmente la separación de contextos que existe de forma natural entre módulos distintos, aunque con ciertas limitaciones: solo afecta a los nombres importados, y en el contexto del módulo que hace la importación estos se convierten en variables de "solo lectura", es decir, que no se les puede asignar nuevos valores. Lo vemos con un ejemplo:

```@repl
module Foo
    export x
    x = [1,2]
end
using .Foo # importa `x` en `Main`
x
x[1] = 0; # Si es un objeto mutable se puede modificar
x
x = [3,4] # Pero no lo podemos reasignar
```

Como se vio en el [capítulo 4](4-modulos-paquetes.md#Importar-módulos-y-sus-objetos), hay distintas formas de importar objetos de otros módulos: `using Foo` importa todos los que están señalados con `export`, pero también podemos hacer una importación selectiva con `import Foo: x`, etc. Estas dos formas de importar objetos tienen un par de diferencias sutiles:

* Cuando se ejecuta `import Foo: x` se crea inmediatamente una asociación entre la variable `Foo.x` y otra variable `x` en el contexto del módulo que hace la importación.
* Con `using Foo`, la asociación entre `Foo.x` y `x` en el contexto presente no tiene lugar hasta que se hace una referencia explícita a `x`, si no se le ha asignado ningún valor con anterioridad. Esto permite dar otro valor a `x` en el contexto presente, si realmente no se pretende usar el que tiene en `Foo`.
* Si `Foo.f` fuese una función, `import Foo: f` permite definir nuevos métodos de `f` en el contexto donde se hace la importación.
* Con `using Foo`, suponiendo que la función `f` también esta en la lista de exportaciones, se puede llamar a la función `f` desde el contexto presente, pero no se permite añadirle métodos --salvo que se especifique con el prefijo `Foo.f`--.

## Contextos locales

Las funciones, los bucles, bloques `try-catch`, `let` y otras estructuras (con exepción de los bloques `if` y `begin-end`) delimitan contextos locales dentro del contexto global en el que están escritas. En estos contextos locales se reconocen tanto las variables definidas localmente como las globales. Volviendo al símil de las calles de una población: si estamos en la Calle Mayor de un pueblo puedo referirme a la Plaza del Ayuntamiento u otros lugares del mapa (otras variables del contexto global), pero también puedo hablar del "portal número 3" o del "quiosco de la esquina" (variables particulares de ese contexto local, que no tienen sentido fuera de él). Sin embargo se trata de un símil imperfecto, porque se podría ser más específico y hablar del "portal 3 de la Calle Mayor" desde otro contexto; pero en Julia los nombres de las variables locales no son alcanzables fuera de su propio contexto.

!!! note "Contextos léxicos"
    
    Es importante recalcar que las variables globales que se reconocen en un contexto local son las del módulo en el que *está escrito* el código (lo que se conoce como un "contexto léxico" o "estático"). Este matiz se puede apreciar claramente en el caso de las funciones: dentro de una función se puede hacer referencia a una variable `x` definida globalmente en el módulo en que se ha definido esa función, pero no tiene absolutamente ningún impacto que haya o deje de haber también una variable `x` en fragmentos código distintos en los que se llame a la función.

Las variables locales y las globales tienen características y un tratamiento distinto. De hecho se permite que una variable local tenga el mismo nombre que otra global. En ese caso, la variable local "enmascara" a la global, que deja de ser visible en contexto local --aunque siempre puede hacerse referencia a ella cualificándola con el nombre del módulo--:

```@repl
x = 1 # global en `Main`
function foo()
    x = 2 # la variable local enmascara la global
    println("La x local es: ", x)
    println("La x global es: ", Main.x)
end
foo()
x # La x local no ha afectado a la global
```

### Cómo diferenciar variables globales y locales

El hecho de que en los contextos locales coexistan variables locales y globales es una fuente potencial de confusiones. Una regla general y sencilla, aunque poco precisa, que se puede considerar para evitar esas confusiones es que cuando la variable se "crea" dentro de un contexto local es una variable local, y en los demás casos se asume que se trata de una variable global. Para ser más precisos, se puede decir que las variables con carácter local son:

* En el caso de las funciones, los argumentos de entrada.
* En las expresiones `let`, las variables definidas en la línea de cabecera.
* En los bucles `for`, las variables usadas como iteradores.
* En todos los contextos locales, las variables a las que se les asigna algún valor de forma directa, con instrucciones del tipo `x = 1`.

Esta última regla es la que corre más riesgo de pasarse por alto, ya que las asignaciones pueden darse en cualquier punto de la estructura que define el contexto local, pero cuando una variable adquiere carácter local, lo hace *en todo el contexto*, no solo desde el punto en que se crea. Así pues, el siguiente código sería incorrecto (y de hecho da lugar a un error):

```@example c7
z = 0

function fractal_mal(c)
    w = z^2
    z = w + c
end
nothing #hide
```

En la función `fractal_mal` se quiere hacer referencia a una variable `z` que está definida en el contexto global, con un valor inicial de `0`. Pero la segunda operación, en la que se actualiza el valor de `z`, se está haciendo una asignación que hace que se considere como una variable local. Así pues, al intentar usar esa función la línea `w = z^2` se desencadenará el siguiente error:

```@repl c7
fractal_mal(-0.5)
```

Este desliz pasa inadvertido como más frecuencia cuando las operaciones de "lectura" y "escritura" de la variable tienen lugar en la misma línea. Por ejemplo si se hubiéramos simplificado el código de la función `fractal_mal` a:

```julia
function fractal_mal(c)
    z = z^2 + c
end
```

El resultado habría sido el mismo, porque el código de ambas variantes de la función es equivalente.

Esto supone una traba a la reasignación de variables globales en contextos locales, lo cual se considera generalmente una mala práctica, pero no está completamente impedido. Lo único que hace falta es declarar explícitamente que `z` es una variable global, lo que anula la regla anterior:

```@example c7
function fractal_bien(c)
    global z
    z = z^2 + c
end
```
```@repl c7
fractal_bien(-0.25)
```

Por otro lado, si las variables globales son de tipo mutable (por ejemplo vectores), sus contenidos se pueden alterar en un contexto local, sin hacer nada especial.

!!! note "Cambios en las variables globales"
    
    No se deberían hacer modificaciones sin una buena razón a las variables globales (es decir, en general es recomendable que los objetos globales sean *constantes*, no *variables*). Un motivo es que los cambios a las globales suponen una modificación al estado del programa, que si no se hace con cuidado puede desembocar en funcionamientos difíciles de predecir. Pero también hay razones de eficiencia, que se comentan en el capítulo XXXX.

## Contextos locales anidados

Cuando se anidan estructuras que forman contextos globales, se crean también nuevos contextos locales. Una situación habitual en la que ocurre esto es en los bucles definidos dentro de una función, o en bucles anidados; por ejemplo, en la siguiente función que trata de reproducir el comportamiento de `sum`:

```julia
function suma(x)
    y = zero(eltype(x))
    for v in x
        y += v
    end
    return y
end
```

En esa función se manejan tres variables, todas ellas locales:

* `x`, introducida como argumento de la función, y cuyo alcance es todo el cuerpo de la misma.
* `y`, introducida por asignación en la primera línea, y cuyo alcance es también todo el cuerpo de la función.
* `v`, introducida como iterador del bucle `for`, y cuyo alcance se limita al mismo.

Así pues, la variable `v` solo se puede usar dentro del bucle `for`, aunque dentro del mismo también podemos usar las variables locales `x` e `y`. Lo mismo ocurriría si dentro del bucle hiciéramos una asignación a una nueva variable (por ejemplo `z`), *que no esté definida fuera del bucle*: esa variable se crearía como una local específica de ese contexto anidado, y tampoco se reconocería fuera de él. Por contra, como la variable `y` ya estaba definida como local fuera del bucle, en la línea `y += v` se considera que es la misma variable, no una nueva específica del bucle.

La asignación de valores es la única forma de definir variables locales que no tiene efecto en contextos anidados, si ya existía una local con el mismo nombre en contextos de nivel superior. En los otros casos (argumentos de funciones, iteradores, asignaciones de cabecera en bloques `let`...) siempre se crea una nueva local específica, exista o no otra del mismo nombre en el nivel superior. Por ejemplo, el siguiente código sería exactamente equivalente al que hemos visto antes (aunque ligeramente más confuso):

```julia
function suma(x)
    y = zero(eltype(x))
    for x in x
        y += x
    end
    return y
end
```

En esta versión de la función `suma` hemos sustituido el iterador `v` del bucle por `x`, que coincide con el nombre del argumento de la función. Por eso tenemos la expresión algo extraña `for x in x`, en la que cada una de las dos `x` se refiere a una variable distinta: la segunda `x` es el argumento de entrada, y la primera `x` es el iterador, una nueva local que enmascara a la de nivel superior dentro del contexto específico del bucle --pero no la altera--.

También podemos forzar una asignación dentro de un contexto local anidado, para que se cree una variable local específica del mismo, aunque ya exista una local de nivel superior con el mismo nombre. Esto se consigue poniendo el prefijo `local` a la variable:


```@example c7
function anidados(x)
    println("Nivel superior: ", x)
    for i = 1:3
        local x = i
        println("Anidada: ", x)
    end
    println("Nivel superior: ", x)
end
```
```@repl
anidados(10)
```

## Funciones anidadas (*closures*)

Otra situación común que da lugar a contextos locales anidados son las funciones definidas dentro de otra función. Por ejemplo, la siguiente función `exponenciador` tiene en su código la definición de una función anónima, que de hecho es el objeto que devuelve:

```julia
function exponenciador(n)
    return (x -> x^n)
end
```

En este ejemplo tan sencillo solo tenemos dos variables locales: `n`, que es el argumento de entrada de `exponenciador`, y `x`, el argumento de la función anónima que se define de foma anidada. El alcance de `n` es toda la función `exponenciador` (incluida la función interna), pero `x` solo se reconoce dentro de la función anónima.

Estas funciones anidadas reciben en inglés el nombre de *closures* (traducido a veces al español como "clausura"), porque como ocurre aquí con la variable `n`, "capturan" o "encierran" en su definición objetos de otro contexto local, distinto del suyo propio. Una propiedad de estos objetos capturados es que no se destruyen cuando se acaba de ejecutar la función, sino que persisten entre llamadas. Esto hace posible cosas como:

```@example c7
function secuenciador()
    x = 0 # Esta es la variable capturada
    f = () -> begin
        x += 1   # Se modifica cada vez que se llama la función
        return x
    end
    return f
end
```
```@repl
siguiente = secuenciador()
siguiente()
siguiente()
siguiente()
```

Aunque lo más intuitivo es definir las variables capturadas antes que la función que las captura, lo único que importa es que estén en un contexto de nivel superior. Por ejemplo, la línea `x = 0` que da el primer valor de `x` podría haberse definido después de la función anidada. 

## Variables locales en los bucles

El funcionamiento de los contextos locales en los bucles merece comentarse con un poco más de detenimiento. Un detalle importante es que el alcance de las variables locales de un bucle se reduce a la iteración presente. Una forma de verlo es que el valor de las variables locales del bucle se "olvida" al finalizar cada iteración. Es decir, que no puede emplearse fuera del bucle, pero tampoco en iteraciones posteriores, antes de volver a definir la variable. Por ejemplo, el siguiente código daría lugar a un error:

```julia
for i = 1:10
    if i == 1
        x = 1
    else
        x = x + i
    end
end
```
```
ERROR: UndefVarError: x not defined
```

Esto ocurre porque en la primera iteración se ejecutaría la línea `x = 1`, y en la segunda intentaría ejecutarse `x = x + i`; pero al tratarse de una iteración nueva, el valor de `x` no estaría definido de antemano y esa línea no se podría ejecutar.

Este comportamiento puede parecer inconveniente en situaciones como esta, pero tiene ventajas sustanciales. En primer lugar, esto ayuda a que el código de los bucles sea más fácil de analizar, porque los objetos asignados a las variables dentro del bucle solo pueden depender de las variables globales y las instrucciones del bucle que se ejecuten en la iteración presente; no hace falta pensar en lo que se pueda haber ejecutado o dejado de ejecutar anteriormente. Esto es algo deseable en programas con cierta complejidad, y en particular para la ejecución en paralelo que comentaremos en el capítulo XXXX.

En una situación como la presentada en el ejemplo, en la que querríamos que `x` fuese una variable persistente de una iteración a la siguiente, sería necesario definirla *fuera* del bucle, antes de ejecutarlo. Sin embargo esto nos obliga a considerar si ese bucle se encuentra dentro de un contexto local (por ejemplo en una función), o en uno global (en un módulo, en el nivel superior de un *script*, etc.)

En el primer caso (dentro de una función u otro contexto local), bastaría con escribir:

```julia
x = 0
for i = 1:10
    if i == 1
        x = 1
    else
        x = x + i
    end
end
```

(El hecho de iniciar la variable `x` con el valor `0` es irrelevante; podría haber sido cualquier otro.)

Pero si estuviésemos en un contexto global (por ejemplo si el bucle se escribiese en el código de un módulo), el código anterior fallaría porque la primera línea estaría definiendo una variable `x` global, y en el bucle se trataría de *otra* `x` local al mismo, distinta de la `x` anterior. Tal como se ha comentado antes, para hacerlo funcionar habría que declarar explícitamente que la `x` del bucle es la variable global del mismo nombre:


```julia
x = 0
for i = 1:10
    global x
    if i == 1
        x = 1
    else
        x = x + i
    end
end
```

Esto resulta una molestia cuando se están prototipando programas o haciendo análisis de forma interactiva, en el REPL, ya que las instrucciones se ejecutan en el contexto global `Main`. En esas circunstancias resultaría más cómodo que los bucles se comportasen como si las variables globales fuesen unas locales de nivel superior, y se les pudiese asignar valores sin tener que declararlas como `global`. Por eso en el REPL (y en otros entornos interactivos como en *notebooks* de [IJulia](https://julialang.github.io/IJulia.jl/stable/)) se hace una excepción a las reglas en ese sentido. Esta excepción --introducida en la versión 1.5 de Julia-- facilita que se pueda "copiar y pegar" código del REPL al interior de las funciones, a pesar de que los contextos sean distintos.

