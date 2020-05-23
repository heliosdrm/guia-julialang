# Capítulo 10. Detección y depuración de errores

Los errores son inevitables a la hora de desarrollar un programa, hasta el punto que la estrategia más eficaz para prevenirlos no es tanto evitar que ocurran, sino intentar detectarlos corregirlos rápidamente. En el último capítulo de esta guía vamos a ver algunas buenas prácticas y herramientas que facilitan esta tarea, tratando de evitar algunos pasos en falso y atolladeros comunes.

## Tipos de errores

Comencemos por ver los tres tipos de errores más comunes con los que nos solemos encontrar en un programa.

**Errores de código**. Con este tipo de errores nos referimos a los fallos cometidos por confusiones en los nombres de funciones o variables, por escoger las operaciones que no tocan, definir de forma incorrecta bucles o condiciones, etc. En la mayoría de casos estos fallos provocan errores sistemáticos, interrupciones del programa o resultados inesperados en los primeros intentos de uso, lo que facilita su detección.

**Errores ocasionales**. Consisten en el típico *bug* que hace fallar misteriosamente un programa que parecía funcionar bien. A menudo son más difíciles de detectar, porque no siempre aparecen de forma sistemática. Suelen darse al usar datos que no cumplen alguna hipótesis implícita en el diseño del programa, que producen valores singulares, resultados fuera de rango, bucles infinitos, etc. A veces no dependen solo de los datos de entrada, sino incluso de las operaciones que se hayan hecho antes.

**Errores por cambio de versión**. El programa funcionaba perfectamente, pero después de una actualización del sistema o de los paquetes, deja de hacerlo. Es un tipo de error muy frustrante, pero afortunadamente fácil de detectar, y en el caso de Julia también es fácil de prevenir gracias al sistema de [entornos por proyectos](9-pkg.md#Trabajar-por-proyectos-1).

A continuación se comentan algunas prácticas de programación que ayudan a prevenir distintos tipos de errores, seguidas de algunas herramientas específicas de Julia que sirven de apoyo a dichas prácticas.

## Buscar y usar paquetes

Cuando estás haciendo un programa para resolver un problema, vale la pena detenerse y buscar si hay alguien que ya haya resuelto antes el mismo o uno parecido. Es muy probable que al menos una parte del problema requiera herramientas que ya están desarrolladas, puestas a prueba y optimizadas en paquetes. En el capítulo anterior se encuentran algunas referencias para [buscar paquetes de Julia](9-pkg.md#Dónde-encontrar-paquetes-para-Julia-1), instalarlos y usarlos.

Usar paquetes de terceros tiene varias ventajas, entre las que se cuentan las siguientes:

* Ahorro de tiempo y esfuerzo de programación, que se puede invertir en las partes del problema más originales.
* A menudo los paquetes son el resultado de un trabajo colaborativo entre desarrolladores y usuarios, lo que reduce el riesgo de fallos.
* Si es un paquete suficientemente usado, los canales de comunicación de la ["comunidad" de usuarios de Julia](https://julialang.org/community/) (foros de discusión, chats, etc.) pueden ser de ayuda para resolver el problema con el apoyo del paquete.

Naturalmente, el uso de paquetes también puede presentar algunas desventajas que vale la pena valorar. La carga de estos problemas varía mucho de un paquete a otro; hay algunos en los que es despreciable, y otros en los que es bastante importante:

* Para sacar partido a un paquete hay que aprender a emplearlo, lo cual puede ser más o menos difícil en función del diseño del paquete y de la documentación de que disponga.
* En ciertos casos el "peso" de un paquete es desproporcionado respecto a la parte del problema que se busca resolver, en términos de espacio que consume o dependencias que tiene que instalar (sobre todo si son herramientas del sistema operativo o programas externos a Julia, que pueden presentar problemas de instalación). En tales casos cabe considerar si las capacidades que proporciona el paquete podrían ser útiles en otros proyectos, o si existen otros paquetes más básicos para el problema en cuestión.
* Una vez instalados, la mayoría de paquetes se suelen cargan en cuestión de unos pocos segundos cuando se usan por primera vez en una sesión de trabajo, pero algunos pueden tardar más, incluso más de un minuto (dependiendo del paquete y del ordenador). Esta espera puede hacerse más larga después de alguna actualización. 

Por otro lado, algunos inconvenientes en los que se podría pensar a la hora de utilizar paquetes de terceros están bien resueltos en el caso de Julia, y normalmente no hay que preocuparse de ellos:

* Los problemas de compatibilidad entre versiones de los paquetes, y de falta de reproducibilidad a causa de sus actualizaciones, se controlan de forma muy eficaz al [trabajar por proyectos](9-pkg.md#Trabajar-por-proyectos-1), como se ha indicado arriba.
* En cuanto a la explotación de programas que usen paquetes de terceros, la práctica habitual en la comunidad de desarrolladores de Julia es publicar los paquetes bajo la [licencia MIT](https://es.wikipedia.org/wiki/Licencia_MIT) o semejante, lo que da libertad de usarlos y modificarlos, incluso para software propietario y cerrado.

## Encapsular código en funciones pequeñas

Cuando se comienza a trabajar en un proyecto con datos que se han de procesar o analizar, lo primero que se hace normalmente es explorar los datos, ver algunos de muestra,  [representarlos en gráficos](4-graficos.md), etc. Esto suele hacerse en un entorno interactivo, que da mucha flexibilidad al usuario para crear nuevas variables, modificarlas de forma arbitraria, y hacer operaciones paso a paso, viendo lo que pasa después de cada operación antes de proceder a la siguiente.

Las funciones, por otro lado, están pensadas para un flujo de trabajo mucho más sistemático, con una secuencia de operaciones concreta aplicadas a un conjunto cerrado de variables, que se van generando y modificando conforme a un guión predefinido. Esto podría hacer pensar que no vale la pena crear funciones hasta que los algoritmos a emplear en el proyecto estén suficientemente claros, o al menos hasta que se hayan definido rutinas lo suficientemente largas y repetitivas como para que guardar el código de la función suponga un ahorro de trabajo significativo.

Sin embargo, en general es ventajoso empezar a encapsular el código en pequeñas funciones desde casi el principio. En Julia se recomienda definir funciones sencillas porque así es más fácil asegurar la [estabilidad de tipos](@ref), lo que permite que se compilen de forma óptima y se ejecuten más rápido. Pero otra ventaja muy importante, que además es común a todos los lenguajes de programación, es que encapsular secuencias de operaciones en funciones hace que los pasos realizados durante el análisis, incluso en las primeras fases exploratorias, sean más repetibles y menos propensos a errores. Además, esto permite que el código sea más conciso, más modular y fácil de leer y entender posteriormente por el propio autor o por otros.

Las funciones sencillas también facilitan el uso de [tests unitarios](@ref) y las herramientas de *[debugging](@ref)*, que se comentan en secciones posteriores como estrategias para prevenir y arreglar errores en los programas.

## Documentar el código

Aunque Julia se considere un lenguaje "de alto nivel", el código de un programa de Julia dista mucho del lenguaje natural, por lo que entender lo que hace no suele ser fácil, salvo por parte de la persona que lo ha programado, y solo inmediatamente después de escribirlo. (Después de un breve tiempo sin tocarlo, el código de un programa suele ser tan críptico para el programador como para cualquier otra cosa persona.)

Esto es un problema a la hora de enfrentarse a errores que no surjan de forma inmediata, como los errores de tipo ocasional o los derivados de cambios de versiones. Por ese motivo es esencial documentar correctamente el código: si no se entiende bien lo que está haciendo el programa en el punto en el que falla, difícilmente se podrá resolver el error sin correr un gran riesgo de estropearlo más.

Los comentarios son una herramienta fundamental para hacer el código más inteligible. Una buena táctica para hacer comentarios útiles es escribir lo que tiene que hacer el programa en lenguaje natural, antes de hacerlo en el lenguaje de programación. Hacer esto no solo sirve de ayuda a las personas que quieran leer el código más adelante, sino que también es una buena guía a la hora de escribir el programa en sí mismo.

Por ejemplo, si quisiéramos describir las operaciones de la función [`gauss_diasemana`](1-primerospasos.md#gauss_diasemana) que se usó como ejemplo introductorio en el primer capítulo, podríamos escribir lo siguiente:

```text
(Enero y febrero (m=1, m=2) se tratan como el año anterior
en torno a los años bisiestos)

1. Dividir el año entre centenas (c) y el resto (g)
2. Definir e y f en función del mes (de 1 a 12) y el siglo
   (en ciclos de 400 años --- 4 siglos), según las tablas:
   e(m) = 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4
   f(siglo) = 0, 5, 3, 1
3. Seleccionar el día de la semana en función del cálculo de Gauss
   x = d + e + f + g + ⌊g/4⌋
   w es la división entera de x entre 7
```

La función `gauss_diasemana` mostrada en el capítulo 1 está escrita usando como punto de partida ese mismo texto, convertido previamente a una serie de comentarios. El primer párrafo se ha convertido en un comentario en bloque (con los delimitadores `#=`, `=#`), y los párrafos númerados en comentarios de una sola línea (encabezados por el símbolo `#`). Después del primer comentario se ha añadido el bloque condicional que se describe en él, y se han eliminado las líneas que prácticamente enuncian las fórmulas reproducidas en el código, con lo que la función finalmente queda como sigue:

```julia
function gauss_diasemana(d, m, y)
    #=
    Enero y febrero (m=1, m=2) se tratan como el año anterior
    en torno a los años bisiestos
    =#
    if m < 3
        y = y - 1
    end
    # Dividir el año entre centenas (c) y el resto (g)
    c = div(y, 100)
    g = rem(y, 100)
    # Definir e y f en función del mes (de 1 a 12) y el siglo
    # (en ciclos de 400 años --- 4 siglos)
    earray = [0,3,2,5,0,3,5,1,4,6,2,4]
    farray = [0,5,3,1]
    e = earray[m]
    f = farray[mod(c,4) + 1]
    # Seleccionar el día de la semana en función del cálculo de Gauss
    warray = ["domingo","lunes","martes","miércoles",
        "jueves","viernes","sábado"]
    w = rem(d + e + f + g + div(g, 4), 7)
    return(warray[w+1])
end
```

Además de comentar el código, también es muy recomendable documentar las funciones mediante *[docstrings](@ref)*. Los *docstrings* son especialmente útiles porque no hace falta ir al código fuente para leerlos, sino que se muestran cuando se consulta la ayuda de la función. Si las funciones están bien documentadas, es mucho más fácil asegurarse de que se usan correctamente o detectar errores debidos a un mal uso de las mismas.

## Tests unitarios

Para que una construcción no se desmorone es esencial que sus piezas sean robustas --además de que estén bien ensambladas--. Del mismo modo, lo primero para prevenir los fallos de un programa es asegurar que las funciones que emplea son fiables. Los llamados "tests unitarios" son pequeños programas que se escriben para poner a prueba las funciones.

Este tipo de pruebas se suelen hacer de forma espontánea mientras se están definiendo las funciones. Por ejemplo, al comienzo del capítulo tres desarrollamos una función para crear en formato HTML el calendario de un mes cualquiera, basado en la función `gauss_diasemana` comentada arriba y unas cuantas más; y tras definir cada una de ellas se probaba su resultado con un ejemplo particular (el mes de agosto de 2018). Los tests unitarios no son otra cosa que una manera formal, sistemática y más exhaustiva de hacer ese tipo de comprobaciones. En lugar de hacer pruebas informales en el REPL, estas se escriben en un *script* que se guarda para poder repetirlas más adelante, y poder así verificar que las funciones siguen funcionando como se esperaba.

!!! note "Test-driven development"

    Los tests unitarios son el elemento básico de la estrategia de programación conocida como "TDD" o *test-driven development* ([desarrollo guiado por pruebas](https://es.wikipedia.org/wiki/Desarrollo_guiado_por_pruebas)). Se trata de un método para crear programas de forma progresiva, escribiendo primero las pruebas que han de pasar los distintos componentes de un programa, y después las funcionalidades necesarias para que las pruebas vayan pasando.
    
La finalidad de los *scripts* con los tests unitarios no es solo comprobar que las funciones se pueden ejecutar sin provocar ningún error, sino que también dan los resultados esperados. Una forma de conseguir esto es con la macro `@assert`.

Por ejemplo, consideremos la siguiente función, que define el resto de la división entera de una pareja de números, tomando como dividendo el más grande y como divisor el más pequeño, independientemente del orden en que se introduzcan:

```@example c10
function resto(a, b)
    dividendo = max(a, b)
    divisor = min(a, b)
    return rem(dividendo, divisor)
end
```

En principio, el resultado de esta función siempre tendría que ser más pequeño que el menor de los argumentos... pero esto solo ocurre si ambos son números positivos. Cuando se introducen números negativos esta regla ya no se cumple, y si un test incluyese esa prueba con la macro `@assert`, se interrumpiría con un error:

```@repl c10
a1, b1 = 5, 2;
a2, b2 = 5, -2;
@assert resto(a1, b1) < min(a1, b2) "el resto no es más pequeño que el argumento menor"
@assert resto(a2, b2) < min(a2, b1) "el resto no es más pequeño que el argumento menor"
```

Para hacer este tipo de pruebas, después de `@assert` siempre ha de escribirse una expresión que de como resultado el valor `true` o `false`. Si el resultado es `true`, el *script* continúa sin más, pero si es `false` se emite un error de tipo `AssertionError`, con el mensaje escrito como cadena de texto después de la condición. (Ese texto opcional, de tal modo que si se omite el mensaje de error simplemente reproduce la condición.)

Además de la macro `@assert`, Julia también tiene el módulo `Test` en la biblioteca estándar, que proporciona más utlidades para hacer tests unitarios. La principal es la macro `@test`, que funciona como `@assert`, pero no admite el texto de error personalizado, y muestra información más explícita sobre el resultado de la prueba, tanto si se pasa como si no:

```@repl c10
using Test
@test resto(a1, b1) < min(a1, b2)
@test resto(a2, b2) < min(a2, b1)
```


>



La macro `@test` también facilita probar igualdades o desigualdades aproximadas con una tolerancia determinada. Por ejemplo, podemos probar la [aproximación de Bhaskara I a la función seno](https://en.wikipedia.org/wiki/Bhaskara_I%27s_sine_approximation_formula):

```@repl c10
using LinearAlgebra
sin_aprox(x) = 16x * (π - x) / (5π^2 - 4x * (π - x))
@test sin_aprox(π/5) ≈ sin(π/5) atol = 0.001
@test sin_aprox(π/4) ≈ sin(π/4) atol = 0.001
```

Además, se pueden escribir bloques de pruebas con la macro `@testset`, de tal manera que los resultados de todos los tests del bloque se presentan juntos en una tabla resumen. Esto resulta especialmente práctico para repetir un mismo test sobre un conjunto de datos diversos, iterando a lo largo del conjunto de datos:

```@repl c10
@testset "Seno de Bhaskara I" begin
    for x = range(0, π, length=5)
        @test sin_aprox(x) ≈ sin(x) atol = 0.001
    end
end
```

Julia proporciona varias utilidades más, por ejemplo para verificar si una función se interrumpe con un error o emite *warnings* cuando corresponde, comprobar los tipos de variable que dan como resultado las funciones, etc. Estas utilidades se pueden consultar en la sección del manual oficial sobre el [módulo `Test`](https://docs.julialang.org/en/v1/stdlib/Test/).

## `Revise`

Después de escribir el código de una función es necesario pasárselo a la sesión en curso de Julia para poder usarla --bien pegando el código en el REPL, leyendo el archivo que lo contiene con `include`, o con las herramientas que ofrecen los IDEs para ejecutar fragmentos de código--. Asimismo, si en algún momento corregimos alguna parte de la función, también tenemos que "recargarla" en la sesión de Julia, si queremos que se reconozca su nuevo comportamiento. Pero cuando se está escribiendo un programa con muchas funciones (y si se sigue el consejo que se ha dado arriba, eso debería ser lo normal), es fácil perder la pista a los cambios que se les va haciendo según encontramos fallos y los corregimos. Esto puede hacer que llegue un momento en que no sepamos si las funciones que estamos usando son las presentes en el código fuente o una versión anterior.

En esas circunstancias, una solución drástica es terminar la sesión de Julia y comenzarla de nuevo, pero eso supone tener que volver a cargar los paquetes y módulos, repetir los pasos anteriores del estudio que se estuviera haciendo, etc. Una alternativa es usar el paquete [Revise](https://timholy.github.io/Revise.jl/stable/). Entre otras cosas, este paquete proporciona la función `includet`, que hace lo mismo que `include` (evaluar los contenidos de un archivo de código), pero trazando los cambios que se realizan sobre él.

Esto significa que si se modifica alguna parte del archivo cargado con `includet`, este se "recarga" automáticamente. Las nuevas variables y funciones definidas en el código pasan a formar parte del espacio de trabajo; se aplican los cambios que se hayan hecho en sus definiciones, y en el caso de las funciones, las que se borren del código también desaparecen del espacio de trabajo.[^1]

[^1]: Usando el paquete Revise también se pueden redefinir módulos de manera segura sin reiniciar la sesión de trabajo. Lo que no se pueden actualizar son las definiciones de tipos de variables. La definición de módulos y de tipos son aspectos algo más avanzados, que no se abordan en esta guía.

El paquete Revise solo depende de los módulos de la biblioteca estándar de Julia, por lo que se trata de uno de los pocos paquetes de terceros que se puede recomendar [cargar de forma automática al inicio](9-pkg.md#Cargar-paquetes-al-inicio-1). Esta recomendación es especialmente aplicable para usuarios que trabajen en el desarrollo de paquetes, ya que Revise también puede seguir los cambios que se han hecho a los paquetes cargados con `using` o `import`. (Para asegurarse de que Revise funciona bien al cargarlo al inicio, conviene seguir las instrucciones mencionadas en sus páginas de documentación.) 

## Registro de mensajes con `@debug`

Hay circunstancias en las que se necesita consultar lo que ocurre en algún punto determinado de un programa sin tener que recorrer manualmente todos sus pasos, o dentro de una función cuando se ejecuta, para verificar que funciona como se espera o para entender por qué no lo hace. A continuación presentamos tres mecanismos para hacer este tipo de "investigación" o *debugging*.

El método más básico consiste en escribir instrucciones en los puntos de interés del programa, para registrar la información que se desea consultar. La versión más rudimentaria de este proceso sería introducir líneas de código con la función `print` o `println` para mostrar los valores de ciertas variables en ese instante, bien en la pantalla, en archivos de texto, etc.

Una opción más adecuada es usar el sistema de registro de mensajes proporcionado por Julia, que puede activarse, desactivarse y configurarse a demanda. Pongamos, por ejemplo, que queremos registrar los valores de todos los parámetros utilizados en la fórmula final de la función `gauss_diasemana`, es decir:

```julia
w = rem(d + e + f + g + div(g, 4), 7)
```

Esto se puede hacer añadiendo la siguiente línea, justo después de la anterior:

```julia
@debug "Valores de la fórmula de Gauss" d e f g g_4=div(g, 4) w
```

En circunstancias ordinarias, esta línea no tiene ningún efecto sobre el comportamiento de la función --de hecho ni siquiera se ejecuta--:

```julia-repl
julia> gauss_diasemana(11, 8, 2018)
"sábado"
```

Pero si queremos se puede configurar la sesión para que esa línea se "active", de tal manera que en el REPL veremos algo como lo que sigue:

```julia-repl
julia> using Logging

julia> debug_logger = ConsoleLogger(stderr, Logging.Debug);

julia> global_logger(debug_logger);

julia> gauss_diasemana(11, 8, 2018)
┌ Debug: Valores de la fórmula de Gauss
│   d = 11
│   e = 1
│   f = 0
│   g = 18
│   g_4 = 4
│   w = 6
└ @ Main REPL[2]:22
"sábado"
```

Lo que hemos hecho antes de llamar a la función `gauss_diasemana` es crear un registro del tipo `ConsoleLogger`, que dirige la información al dispositivo donde se hayan de mostrar los mensajes de diagnóstico (`stderr`, normalmente en pantalla), y que tiene en cuenta todos los registros de tipo `Debug` o de mayor prioridad.[^2] A continuación, se ha configurado el sistema de registro global para usar el que hemos creado. De este modo, al llegar a la línea con la macro `@debug`, se presenta en pantalla la cadena de texto y la variables especificadas --incluyendo el cálculo `div(g, 4)`, al que se le da el nombre `g_4`.

[^2]: El sistema de registro de Julia tiene tres niveles de prioridad, que en orden ascendente son: `Debug` (el de menor prioridad, pensado para desarrolladores), `Info` (información dirigida al usuario), `Warning` (avisos de que puede pasar algo anormal) y `Error` (mensajes de fallos críticos, que normalmente harán que se interrumpa la ejecución del código). Por defecto se muestran los mensajes de nivel `Info` o superiores. Este sistema se describe con detalle en la sección [Logging](https://docs.julialang.org/en/v1/stdlib/Logging/) del manual oficial. 

El registro que se usa por defecto también es del tipo `ConsoleLogger`, por lo que para volver a la configuración original, que ignora los mensajes de `Debug`, se podría escribir:

```julia
global_logger(ConsoleLogger())
```

Por otro lado, la propia función `global_logger` devuelve un registro con la configuración previa, que puede usarse como argumento para volver al estado anterior:

```julia
logger = global_logger(debug_logger) # cambia configuración
global_logger(logger) # vuelve a la configuración anterior
```

Alternativamente, si se quieren registrar solo los mensajes de un conjunto reducido de instrucciones, en lugar de configurar el registro global se puede usar un registro "temporal" con la función `with_logger`, del siguiente modo:

```julia-repl
julia> with_logger(debug_logger) do
       gauss_diasemana(11, 8, 2018)
       end
┌ Debug: Valores de la fórmula de Gauss
│   d = 11
│   e = 1
│   f = 0
│   g = 18
│   g_4 = 4
│   w = 6
└ @ Main REPL[2]:22
"sábado"
```

Esto hace que el registro que hemos definido como `debug_logger` solo se aplique a las instrucciones incluidas en el boque `do ... end`, sin alterar el sistema de registro global.

Para procesar mejor los mensajes emitidos, sobre todo si son muchos, puede ser conveniente dirigirlos a un archivo de texto en lugar de al `stderr`. En ese caso, es más apropiado usar un registro del tipo `SimpleLogger`[^3], que se podría configurar para asociarlo al archivo `"log.txt"` del siguiente modo:

```julia
io = open("log.txt", "w")
debug_logger = SimpleLogger(io, Logging.Debug)
```

[^3]: La differencia entre un `ConsoleLogger` y un `SimpleLogger` es que el primero da formato al texto para presentarlo en pantalla de forma más legible.

!!! warning

    Hay que recordar cerrar el archivo con la instrucción `close(io)` para que los mensajes se queden grabados en él. Además, si se desea utilizar el mismo archivo para registrar distintos conjuntos de mensajes, hay que abrirlos con la opción `"a"` en lugar de `"w"` para que los nuevos mensajes se escriban a continuación de los anteriores, en lugar de sobreescribir el archivo.

## `Infiltrator`

Los registros de mensajes que acabamos de ver son como radiografías que podemos hacer a los programas y funciones para echar un vistazo a su interior. Son una herramienta sencilla y muy eficiente, pero para que resulten útiles hemos de saber dónde buscar y qué información queremos observar. Desafortunadamente muchas veces esto no es así, por lo que a menudo necesitaremos técnicas de *debugging* más flexibles.

Cuando tenemos localizados los puntos críticos de un programa, un método conveniente para explorarlos con más libertad es utilizar la macro `@infiltrate` del paquete [Infiltrator](https://github.com/JuliaDebug/Infiltrator.jl), en lugar de `@debug`. Esto hace que la ejecución del programa se detenga en ese punto. Por ejemplo, en la función `gauss_diasemana` podríamos cambiar las últimas líneas por las siguientes:

```julia
    w = rem(d + e + f + g + div(g, 4), 7)
    @infiltrate
    return(warray[w+1])
end
```

A continuación cargamos el paquete Infiltrate y empleamos la nueva versión de nuestra función:

```julia-repl
julia> using Infiltrator

julia> include("gauss_diasemana.jl")
gauss_diasemana

julia> gauss_diasemana(11, 8, 2018)
Hit `@infiltrate` in gauss_diasemana(::Int64, ::Int64, ::Int64) at REPL[8]:22:

debug> 
```

Hay varias cosas a notar aquí:

* La instrucción `using Infiltrator` ha de usarse antes de cargar la función que incluye la línea con `@infiltrate`. En este caso hemos supuesto que el archivo que contiene nuestra función se llama `gauss_diasemana.jl`.

* Al llegar a esa línea, la función detiene su ejecución, y la etiqueta del REPL cambia de `julia>  a `debug>`, para indicar que se ha entrado en "modo de depuración" (*debug mode* en inglés).

En este momento se pueden ejecutar nuevas instrucciones en el REPL, que funcionarán como si estuvieran escritas en el punto de la función donde nos hemos detenido. Esto significa que podemos usar las variables locales de la función, que podemos consultar con la macro `@locals`:

```julia-repl
debug> @locals
- e::Int64 = 1
- c::Int64 = 20
- earray::Array{Int64,1} = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
- w::Int64 = 6
- d::Int64 = 11
- farray::Array{Int64,1} = [0, 5, 3, 1]
- g::Int64 = 18
- f::Int64 = 0
- m::Int64 = 8
- y::Int64 = 2018
- warray::Array{String,1} = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"]

debug> div(g, 4)
4
```

Ahora bien, este conjunto de variables locales es cerrado. Por lo tanto, mientras se está en este modo no sirve de nada asignar el resultado de las operaciones a nuevas variables, porque estas no se crearán:

```julia-repl
debug> g_4 = div(g, 4)
4

debug> @locals
- e::Int64 = 1
- c::Int64 = 20
- earray::Array{Int64,1} = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
- w::Int64 = 6
- d::Int64 = 11
- farray::Array{Int64,1} = [0, 5, 3, 1]
- g::Int64 = 18
- f::Int64 = 0
- m::Int64 = 8
- y::Int64 = 2018
- warray::Array{String,1} = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"]

debug> g_4
ERROR: UndefVarError: g_4 not defined
```

Lo que sí se puede hacer es crear una nueva variable global (p.ej. `global g_4 = div(g, 4)`), que se mantendrá en `Main` cuando se salga de la función. (Véanse más detalles en la sección sobre [variables globales y locales](@ref) en el capítulo 8.)

Para salir del modo *debug* basta con pulsar `Ctrl+D`.

Hay dos maneras de desactivar y reactivar el efecto de `@infiltrate` sin redefinir la función:

* Si se ejecuta la macro `@stop` dentro del modo *debug*, el punto de interrupción (*breakpoint*) actual dejará de tener efecto la siguiente vez que se ejecute el programa o la función. La instrucción `Infiltrator.clear_stop()` reactiva todos los *breakpoints*.

* Se puede añadir una condición después de `@infiltrate`, de tal modo que el *breakpoint* se active solo cuando esa condición es cierta. Por ejemplo, se podría crear la variable `Main.activar_infiltrate`[^4] que podamos definir arbitrariamente como `true` o `false`, y en la línea en la que queremos detener el código escribir:

```julia
@infiltrate Main.activar_infiltrate
```

[^4]: El motivo por el que se sugiere definir explícitamente esta variable en el entorno global de `Main` es para asegurar que es esa la variable que controla el comportamiento de `@infiltrate`, en el caso de que hubiera alguna variable local con el mismo nombre en el entorno de la función manipulada.

!!! tip "Infiltrator y Revise"

    Tener el paquete Revise en funcionameinto hace más fácil usar Infiltrator: en los *scripts* que se hayan cargado con `includet`, también se pueden activar y desactivar *breakpoints* simplemente escribiendo y borrando las líneas con `@infiltrate`, respectivamente.
    

## *Debugger* gráfico
