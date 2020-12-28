# Capítulo 1. Primeros pasos

## Instalación de Julia

Lo primero que se necesita para trabajar con cualquier lenguaje de programación son las herramientas para crear y ejecutar los programas. El software básico para usar Julia está disponible en su página oficial [https://julialang.org/downloads](https://julialang.org/downloads), en forma de código fuente así como en paquetes preparados para instalar en Windows, Mac OS X, y algunas distribuciones de Linux. Desde esa página podrás encontrar también enlaces con explicaciones detalladas sobre cómo instalar y ejecutar Julia, que son específicas para cada sistema, y por lo tanto no desarrollaremos aquí.

En esencia, los paquetes instalables simplemente descomprimen sus contenidos en una carpeta elegida por el usuario, incluyendo el archivo ejecutable llamado `julia` que servirá para interactuar con el lenguaje de programación. Dependiendo del sistema operativo, también puede realizar algunas operaciones para que otros programas o elementos del sistema reconozcan la ruta de este ejecutable o los tipos de archivos asociados. Cuando se comience a usar Julia, normalmente también se creará una carpeta con el nombre `.julia` (incluyendo el punto, que la convierte en una "carpeta oculta") dentro de la carpeta personal del usuario (en la que suelen estar los destinos por defecto para guardar y cargar documentos, imágenes, etc.). Esta carpeta `.julia` está destinada a contener, principalmente, archivos de configuración y paquetes auxiliares.

Existen varias versiones disponibles de Julia. En general la mejor opción es usar la más reciente (señalada como la "versión estable actual"), aunque los usuarios más conservadores pueden preferir la versión "LTS" (de *long term support*, con "soporte a largo plazo"). Esta guía está elaborada para la versión 1 de Julia, que incluye las etiquetadas como 1.0, 1.1, etc., aunque en unos pocos puntos se consideran características que solo existen a partir de la versión 1.5, por lo que se recomienda utilizar versiones posteriores a la misma.

A menudo, Julia se usa con otros complementos que se instalan y configuran aparte, y de los que hablaremos un poco más adelante. Pero el paquete básico aporta todas las herramientas necesarias para trabajar. Así que para empezar veremos las distintas formas de usar Julia con estas herramientas, sin tener que instalar nada más.

!!! note "Julia Pro y otras alternativas"
    
    La compañía [Julia Computing](https://juliacomputing.com), fundada por algunos de los desarrolladores principales de Julia, ofrece productos como [Julia Pro](https://juliacomputing.com/products/juliapro.html), una distribución de Julia que ya viene con algunos complementos incorporados. Algunos detalles de configuración de estas distribuciones pueden diferir respecto a los de una instalación básica. Otras diferencias entre la versión básica de Julia y Julia Pro son la licencia de uso, el conjunto de paquetes disponibles y el soporte: la versión básica es software libre (bajo licencia MIT), con paquetes mantenidos y controlados por la "comunidad de Julia". Por otro lado Julia Computing tiene sus propios términos de uso para sus productos, ofrece un conjunto de paquetes con versiones controladas por la compañía, y también soporte profesional y funcionalidades extra bajo pago.

## El REPL

La forma más rápida de operar con Julia es trabajando de forma interactiva, en lo que se llama el "REPL", por las siglas de *Read-Eval-Print-Loop* ("bucle leer-evaluar-imprimir"). Este proceso se realiza desde una terminal de comandos --a la que por extensión también se le da el nombre de REPL--, que es lo que se presenta al usuario al lanzar el programa (figura 1).

![Figura 1](assets/repl.png)

*Figura 1. REPL de Julia*

Como se observa en la figura anterior, al iniciar una sesión de Julia el REPL presenta una línea marcada con la etiqueta "`julia>`", a la espera de que el usuario introduzca algún comando --seguido de la tecla `Enter` para confirmar su introducción--. Por poner un ejemplo trivial, para calcular la exponencial de 2, --utilizando la función `exp`--, habría que escribir (sin contar la etiqueta "`julia>`"):

```julia-repl
exp(2)
```

Tras introducir la operación, Julia la evalúa y muestra el resultado justo debajo, seguido de una nueva línea a la espera de la siguiente instrucción, completándose así una interación del bucle que da nombre al REPL.

## Un ejemplo para empezar

```@raw html
<div id="gauss_diasemana" />
```

Veamos ahora un primer ejemplo práctico de Julia, con un programa sencillo para calcular el día de la semana en el que cae cualquier fecha del calendario Gregoriano, usando el algoritmo de Gauss tal como está publicado por Bernt Schwerdtfeger.[^1] Se trata de un algoritmo simple, consistente en los siguientes pasos:

1. Si el número del mes (`m`) es igual o mayor que 3 (de marzo en adelante), el número del año (`y`) se descompone en el número del siglo (`c`, correspondiente a las centenas) y el resto (`g`). En el caso de enero o febrero (`m < 3`) se hace la misma descomposición para `y-1`.
2. Se escoge un número `e` en función del número del mes (de 1 a 12), según la tabla 1 que se presenta a continuación.
3. Se escoge un número `f` según el número del siglo (tabla 2), en un ciclo de 4 siglos (el ciclo de años bisiestos se repite cada 400 años).
4. El día de la semana viene determinado por el resto de la división entera entre `x` y 7, siendo `x = d + e + f + g + ⌊g/4⌋`. (el último sumando es el cociente de la división entera entre `g` y 4).

*Tabla 1: código de mes*

|mes: `e`   |mes: `e`  |mes: `e`      |
|----------:|---------:|-------------:|
|enero: 0   |mayo: 0   |septiembre: 4 |
|febrero: 3 |junio: 3  |octubre: 6    |
|marzo: 2   |julio: 5  |noviembre: 2  |
|abril: 5   |agosto: 1 |diciembre: 4  |

*Tabla 2: código de siglo*

|año (`100*c`)  |`f`|
|---------------|---|
|1600, 2000, ...| 0 |
|1700, 2100, ...| 5 |
|1800, 2200, ...| 3 |
|1900, 2300, ...| 1 |

Este algoritmo se puede implementar en Julia con la siguiente función:

```@example c1
"""
Cálculo del día de la semana.
La función devuelve una cadena de texto con el día de la semana que corresponde
a los números de día, mes y año introducidos como los argumentos numéricos
`d`, `m`, `y`, respectivamente.
"""
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
nothing #hide
```

[^1]: [http://berndt-schwerdtfeger.de/wp-content/uploads/pdf/cal.pdf](http://berndt-schwerdtfeger.de/wp-content/uploads/pdf/cal.pdf)

!!! tip "Trabajando con ejemplos"

    Para asimilar mejor las explicaciones que siguen puedes copiar este ejemplo de código en un archivo, y probarlo en una sesión interactiva de Julia tal como se comenta a continuación, o con variantes de las instrucciones que se propongan. Además, al tener el código en un archivo aparte podrás consultarlo en paralelo mientras lees las explicaciones de la guía, sin tener que desplazarte hacia atrás y hacia delante a lo largo de las páginas. (Esta recomendación también sirve para todos los demás ejemplos que se usen en los siguientes capítulos.)

Supongamos que el código mostrado arriba está guardado en un archivo llamado `calc_diasemana.jl` (el nombre del archivo es arbitrario, y puede ser cualquier nombre aceptado por el sistema operativo). El programa consiste en una sola función con tres argumentos (los números del día, el mes y el año), basada en unas pocas divisiones enteras (definidas en la función `div`) y el cálculo de "restos" de dichas divisiones (`rem`, del inglés *remainder*),[^2] más la selección de unos valores a partir de los resultados intermedios y unas listas predefinidas.

[^2]: Existen dos funciones para el resto de una división: `mod` y `rem`, que funcionan de forma distinta cuando alguno de los dos operandos es negativo. Para el caso que nos ocupa esa diferencia no es relevante.

Este programa se puede cargar usando la función `include` en el REPL, como sigue:

```julia-repl
julia> include("calc_diasemana.jl")
```

El resultado posiblemente sea algo decepcionante, porque lo único que se ha hecho es definir una función, que por sí misma no da ningún resultado. Por otro lado, lo más probable es que al introducir esa línea sin más, ni siquiera se obtenga ningún resultado, sino un error debido a que no se encuentra el archivo de código. Para asegurarse de que Julia encuentra el archivo hay varias alternativas:

  * Copiar el archivo de código `calc_diasemana.jl` al directorio de trabajo de Julia. La ruta de ese directorio se puede obtener con la función `pwd()` --sin ningún argumento--.
  * Cambiar el directorio de trabajo al lugar que contiene el archivo. El cambio de directorio se hace con el comando `cd(directorio)`, donde `directorio` ha de ser la ruta de destino.
  * Introducir la ruta completa del archivo de código en la llamada a `include`. Esta se puede escribir literalmente, o si el directorio que contiene el archivo está definido en una variable (supongamos que esta variable se llama `directorio`), la ruta se puede componer con la función `joinpath`. Es decir, la expresión anterior sería `include(joinpath(directorio, "calc_diasemana.jl"))`.

!!! tip "Nombres de rutas en Windows"

    A veces los nombres de los directorios son largos y resulta tedioso escribirlos. Un atajo habitual es abrir el directorio en un explorador de archivos y copiar la ruta desde la barra de direcciones. Pero en Windows hay un problema añadido, y es que por defecto los directorios se delimitan con barras invertidas (`\`), que hay que "duplicar" para escribirlas de forma literal en Julia (`\\`). Hay dos soluciones rápidas para este problema:
    
    1. Si se está trabajando de forma interactiva, guardar directamente el contenido del portapapeles en una variable, mediante la función `clipboard`. Por ejemplo, con el comando `directorio = clipboard()`.
    2. Si se va a pegar el nombre de la ruta en un *script*, etiquetar la cadena de texto con el prefijo `raw`. Por ejemplo: `directorio = raw"C:\Users\ABC\Documents\Julia\"`. (Esto equivale a `directorio = "C:\\Users\\ABC\\Documents\\Julia\\"`, pero se evita duplicar las barras; véanse más detalles en la sección sobre [Secuencias de escape](@ref) del capítulo 7.) 
    
Una vez se ha conseguido cargar el archivo que define la función, esta ya se puede usar para obtener un resultado de verdad. Por ejemplo, para conocer en qué día de la semana cayó 11 de agosto de 2018, la fecha en la que se publicó la version 1 de Julia:

```@repl c1
gauss_diasemana(11, 8, 2018)
```

Lo que se hace "en un día cualquiera" usando Julia es esencialmente este modelo de rutina, con funciones más complicadas y muchas más operaciones interactivas, explorando resultados, corrigiendo argumentos y repitiendo operaciones, claro está.

Durante una sesión de trabajo habitual, los datos generados suelen guardarse en variables para usarlas en pasos posteriores. Por ejemplo, podríamos definir las variables `día`, `mes` y `año` para recoger los números que luego utilizamos en la función `gauss_diasemana`:

```@repl c1
día = 11;
mes = 8;
año = 2018;
diasemana = gauss_diasemana(día, mes, año)
```

!!! tip "Uso del punto y coma para omitir los resultados"

    Normalmente, cuando se ejecuta una línea o un bloque de código en el REPL, inmediatamente debajo del código introducido aparece el resultado, como la palabra `"sábado"` en este ejemplo. En ocasiones puede quererse ocultar el resultado (por ejemplo si ocupa demasiadas líneas). En ese caso basta con añadir un punto y coma al final del código a ejecutar, como en las primeras líneas del último ejemplo.


## Sintaxis básica

Para escribir un programa en Julia o cualquier otro lenguaje de programación hay que seguir una serie de reglas sintácticas, la mayoría de las cuales en realidad no es necesario explicar, ya que son reglas de escritura lógicas e intuitivas, o se desprenden directamente de la lectura de ejemplos. A continuación se mencionan algunos detalles básicos que se pueden observar en el anterior ejemplo del algoritmo de Gauss:

  * Cada operación se escribe normalmente en una línea distinta, aunque es posible "partir" las expresiones en varias líneas. Si una línea acaba con una expresión incompleta se asume que continúa en la siguiente, como ocurre en la definición de la variable `warray` con los nombres de los días de la semana:
  
```julia
warray = ["domingo","lunes","martes","miércoles",
    "jueves","viernes","sábado"]
```
  
  * Todo el texto que sigue al símbolo `#` hasta el final de la línea se considera un comentario, y no se ejecuta. También se pueden hacer bloques de comentarios que ocupen varias líneas, delimitados por `#=` al principio y `=#` al final, como se ha hecho al comienzo de la función.

  * Las expresiones más habituales son las del tipo `a = f(b)`, como `c = div(y, 100)`, donde `a` es un nombre de variable, `f` el nombre de una función, y `b` el número, cadena de texto u otro tipo de argumento sobre el que opera esa función, o bien el nombre de la variable a la que se le ha asignado el valor de ese argumento. (La función también puede aceptar varios argumentos de entrada, como ocurre con `div`, o tener varias salidas, que se presentan como variables separadas por comas.)
  
  * También es habitual encontrarse expresiones del tipo `a = f[b]`, p.ej. en `e = earray[m]`, con corchetes en lugar de paréntesis. En esos casos `f` no es una función sino un vector, matriz u otra colección de datos, y `b` es el índice o clave que identifica la parte de su contenido que se asignará a la variable `a`.
  
  * Los nombres de variables, funciones, etc. pueden estar formados por cualquier combinación de letras y números, más guiones bajos, exceptuando nombres que comiencen por números y las palabras clave del lenguaje (como `for`, `if`, `function`, `end`, etc.). Además, también se admiten nombres con caracteres Unicode más allá del ASCII básico (letras acentuadas, griegas, etc.), así como el signo de exclamación (`!`) en posición no inicial, aunque conviene usarlos con mesura: emplear caracteres extendidos aumenta el riesgo de problemas de portabilidad de los programas, y la exclamación se suele resevar para el nombre de cierto tipo de funciones (las que modifican sus argumentos de entrada).
  
  * Se puede trabajar con muchos tipos de variables. En este ejemplo se manejan números enteros (`0`, `1`, etc.) y también cadenas de texto, que se escriben entrecomilladas (`"lunes"`, `"martes"`, etc.). En capítulos posteriores se verán otros tipos. Las distintas variables empleadas en un programa pueden hacer referencia a cualquier tipo de variable, e incluso pueden cambiar de tipo a lo largo del programa (aunque es mejor ser consistente en la nomenclatura).
  
  * Los programas suelen tener diversos bloques de código anidados. La función `gauss_diasemana` es en sí un bloque, dentro del cual hay un bloque condicional (el que comienza por `if m < 3`). Los bloques de código se delimitan cerrándolos con la palabra clave `end`, y se recomienda indentar las líneas interiores al código para hacerlo más legible, aunque el programa funcionaría igualmente si no se hace. Otros bloques de código habituales son los bucles `for` y `while`. Para más detalles sobre los distintos tipos de bloques, véase el [capítulo 3](3-funciones-control.md) sobre funciones y estructuras de control.
  
  * En general los espacios son irrelevantes: con contadas excepciones, puede usarse un espacio, varios o ninguno tanto al principio como al final de las líneas, o entre nombres de variables o funciones y símbolos delimitadores varios (operadores matemáticos, signos de puntuación, paréntesis...).

## VS Code y otros IDEs para Julia

Para muchos usuarios, las interfaces basadas en una consola de comandos como el REPL resultan poco "amigables", y por otro lado, para ejecutar rutinas más complejas, y siempre que se quiera obtener resultados reproducibles, es recomendable escribir las instrucciones en un archivo de código (*script*), como hemos hecho con el archivo `calc_diasemana.jl` en el ejemplo anterior.

Para combinar ambas tareas de forma eficiente en una sola interfaz lo habitual es usar los llamados "entornos de desarrollo integrados" (conocidos por sus siglas IDE en inglés), que juntan en una misma interfaz una consola de comandos, un editor de código y a menudo otras utilidades como pueden ser visores de variables, tablas y gráficas, herramientas de depuración, etc. Julia cuenta, más que con un IDE particular, con *plug-ins* para crear IDEs sobre editores de código avanzados, como [Atom](https://atom.io), [Emacs](https://www.gnu.org/software/emacs/), [Sublime Text](https://www.sublimetext.com/), [Vim](https://www.vim.org), [VS Code](https://code.visualstudio.com/) y varios más.

El IDE más completo y popular es el basado en VS Code. Para trabajar en este entorno, además de Julia, hay que instalar VS Code, y activar su [extensión para Julia](https://www.julia-vscode.org/) desde el panel de extensiones (ver en la figura 2). Existen (en inglés) unos excelentes [materiales introductorios](https://code.visualstudio.com/docs) para iniciarse en el uso de VS Code, así como una exhaustiva [documentación de la extensión para Julia](https://www.julia-vscode.org/docs/stable/) para sacar todo el partido a este IDE, que proporciona un amplio conjunto de herramientas para facilitar la creación, edición y ejecución de programas.

![Figura 2](assets/vscode_etiquetado.png)

*Figura 2. Extensión de VS Code para Julia*

El recurso más versátil de VS Code es la "paleta de comandos", a la que se accede con la combinación de teclas `Ctrl`+ `Mayúsc.` + `P`. Escribiendo la palabra "julia" en el el cuadro que surge al pulsar esa combinación, se pueden ver las operaciones relacionadas con la extensión de Julia. Por ejemplo, el comando *Julia: Start REPL* sirve para abrir una terminal con el REPL de Julia que se integra con el resto de elementos de VS Code. También son particularmente útiles los distintos comandos para ejecutar el código de un *script* en la sesión de Julia asociada al REPL abierto:

* *Execute File*: ejecutar el contenido completo del *script*; básicamente equivalente a usar la función `include` mencionada en la sección anterior.
* *Send Current Line or Selection to REPL*: ejecutar en el REPL el código seleccionado en el editor de texto activo, o si no hay nada seleccionado, la línea en la que se encuentra el cursor.
* *Execute Code*: ejecutar el bloque de código en el que se encuentra el cursor en el editor de código. Un "bloque" se corresponde a menudo con una línea, o varias cuando se está dentro de una expresión larga que ocupa múltiples líneas, en una función, bucle u otra [estructura de código](3-funciones-control.md).
* *Execute Code Cell*: ejecutar la celda de código en la que se encuentra el cursor en el editor de código, y moverse a la siguiente celda. Las "celdas" son conjuntos arbitrarios de código en un *script* separados por una línea de comentario que comience por `##`.

Los comandos *Execute Code* y *Execute Code Cell* también cuentan con variantes que después de ejecutar el código mueven el cursor al inicio del siguiente bloque o celda, lo cual es muy útil para ejecutar *scripts* paso a paso.

!!! tip "Atajos de teclado"

    Muchos comandos en VS Code tienen atajos de teclado. Por ejemplo, en la extensión de Julia se puede usar `Alt` + `J` seguido de `Alt` + `O` para lanzar el REPL, `Ctrl` + `Enter` para ejecutar el código seleccionado en el REPL, `Alt + Enter` para ejecutar un bloque de código y continuar, o `Shift + Enter` para hacer lo mismo con una celda de código. Seleccionando en el menú `File > Preferences > Keyboard Shortcuts`, se abre una página con todos los comandos disponibles, y desde ahí se pueden añadir nuevas combinaciones personalizadas a comandos que no las tengan, o modificar las existentes. 

La extensión de Julia tiene numerosas opciones configurables para personalizar la experiencia del usuario. Se puede acceder a ellas a través del menú de configuración general de VS Code (en el icono de la rueda dentada o con el atajo de teclado `Ctrl + ,`), o desde el menú de las extensiones (ver arriba en la figura 2). Para más detalles sobre dichas opciones, véase la [documentación sobre la extensión de Julia para VS Code](https://www.julia-vscode.org/docs/stable/)).


## Manejando el espacio de trabajo

Al iniciar el REPL de Julia se crea un *workspace* o "espacio de trabajo", en el que se registran las distintas variables que se crean o modifican con cada operación. En una sesión de trabajo larga es fácil perder la pista de la variables que se han creado o a su contenido; la función `varinfo` sirve para observar esa información:

```julia-repl
julia> varinfo()
name                    size summary                
–––––––––––––––– ––––––––––– –––––––––––––––––––––––
Base                         Module                 
Core                         Module                 
InteractiveUtils 163.926 KiB Module                 
Main                         Module                 
ans                 15 bytes String                 
año                  8 bytes Int64                  
diasemana           15 bytes String                 
día                  8 bytes Int64                  
gauss_diasemana      0 bytes typeof(gauss_diasemana)
mes                  8 bytes Int64                  
```

Asímismo, la extensión para VS Code y otros IDEs tienen un menú específico para mostrar el espacio de trabajo, así como para explorar sus contenidos con mayor detalle (representaciones de las varialbes en texto, tablas u otros formatos, según su tipo).

En este ejemplo podemos ver las variables `día`, `mes`, `año` y `diasemana` que hemos generado, más la función `gauss_diasemana`, y cuatro elementos más descritos como `Module`, que forman parte de la sesión de trabajo, aunque normalmente no hace falta interactuar directamente con ellos. Por contra, las variables creadas durante la ejecución de `gauss_diasemana` (`c`, `g`, etc.) no se recogen, ya que son variables "locales" a la función, a las que no se puede acceder desde el entorno del REPL, y que se puede considerar que se destruyen al terminar la función.

Esta lista puede llegar a contener muchas variables, creadas en algún momento de la sesión pero que no se necesitan más, y que incluso pueden molestar porque ocupan grandes cantidades de memoria o interfieren en cálculos posteriores. Una forma de librarse de ellas es "vaciarlas" de contenido, del siguiente modo:

```@repl
x = nothing
```

Esta operación asigna a la variable `x` un objeto que "no es nada", y su valor anterior, si no es utilizado por ninguna otra variable, será eliminado automáticamente para liberar memoria cuando haga falta. El nombre de la variable aún seguirá presente en la sesión de trabajo, porque borrar todo rastro de las variables creadas puede dar lugar a problemas e inestabilidades no previstas, según el entorno en el que se esté trabajando. (Para limpiar completamente el espacio de trabajo, el único modo es terminar la sesión de Julia y comenzar una nueva.)

## Módulos y paquetes

```@raw html
<div id="pkg" />
```
Cuando se inicia una sesión de Julia, por defecto solo están disponibles una serie de utilidades elementales, y para la mayoría de proyectos hace falta usar "módulos" que contienen funciones y otras utilidades complementarias. Por ejemplo, en un proyecto en el que se quieran hacer cálculos estadísticos (incluso al nivel básico de medias, varianzas, etc.), hace falta usar el módulo `Statistics`. Para ello hay que ejecutar antes el siguiente comando:

```julia
using Statistics
```

La distribución básica de Julia viene con una biblioteca estándar que incluye diversos módulos. Algunos de estos módulos no están activados por defecto para que la sesión de trabajo no se cargue innecesariamente con tipos de variables y funciones que no se vayan a usar --o cuyo nombre el usuario quiera emplear para otros propósitos--. La lista de módulos de la bilbioteca estándar se puede consultar en la [documentación oficial](https://docs.julialang.org/en/stable/). Algunos que suelen usarse en proyectos de muchos ámbitos son:

* [`Dates`](https://docs.julialang.org/en/v1/stdlib/Dates/) para trabajar con fechas y unidades de tiempo.
* [`DelimitedFiles`](https://docs.julialang.org/en/v1/stdlib/DelimitedFiles/) para leer y escribir tablas de datos en ficheros de texto.
* [`LinearAlgebra`](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/) para cálculos de álgebra lineal (vectores, matrices, etc.).
* [`Statistics`](https://docs.julialang.org/en/v1/stdlib/Statistics/) para cálculos estadísticos (a menudo junto con [`Random`](https://docs.julialang.org/en/v1/stdlib/Random/) para trabajar con números aleatorios y distribuciones de probabilidad).
* [`Sockets`](https://docs.julialang.org/en/v1/stdlib/Sockets/) para trabajar con conexiones a redes informáticas.

Hay muchas otras utilidades que pueden considerse importantes, incluso fundamentales por la mayoría de los potenciales usuarios, como representaciones gráficas de datos, editor de código, ayudas para la depuración de rutinas (*debugging*), etc., pero no están incluidas en la biblioteca estándar, sino en un "ecosistema" de paquetes que se desarrollan de forma coordinada (aunque independiente) por la comunidad de usuarios y desarrolladores de Julia. Puede consultarse la sección *Ecosystem* en la web oficial ([https://julialang.org](https://julialang.org)) para ver algunos de los dominios principales, o webs como [Julia Packages](https://juliapackages.com/) o [Julia Hub](https://juliahub.com/ui/Packages) para explorar muchos más paquetes disponibles.

En el caso de paquetes "registrados" (que es el caso de los más populares, y todos los que se comentan en esta guía), la forma más sencilla de instalarlos es desde el modo de gestión de paquetes de la línea de comandos, mediante los siguientes pasos:

1. Cambiar del modo "normal" al de gestión de paquetes ("pkg"), pulsando la tecla `]` (se verá un cambio en la etiqueta al comienzo de cada línea, como en la figura 3).
2. Escribir el comando `add` seguido del nombre del paquete. Por ejemplo, para añadir el paquete "CSV", que utilizaremos en el siguiente capítulo: `add CSV`
3. Cambiar de nuevo al modo normal, pulsando la tecla de borrar al comienzo de la línea.

![Figura 3](assets/pkgmode.png)

*Figura 3. Cambio a "modo pkg"*

!!! note

    El ciclo de desarrollo de los paquetes externos es independiente (en muchos casos más rápido) que el de Julia. Por ese motivo, aunque se ha procurado que los ejemplos de código esta guía sean compatibles con la versión 1 de Julia, no se puede asegurar que los que dependen de los paquetes externos funcionen adecuadamente en todas las versiones compatibles con Julia 1. Cuando se usen paquetes externos se darán indicaciones de qué versiones de los mismos se han empleado, para reducir la incertidumbre.

## Buscando ayuda

Con toda seguridad, al programar en Julia pronto te encontrarás con dificultades que no puedes resolver con la información que se recoge en esta guía, y necesitarás ayuda adicional. Lo primero con lo que se ha de contar es el [manual de referencia oficial](https://docs.julialang.org/en/stable/), que contiene numerosos detalles de todos los aspectos esenciales del lenguaje, y también explica el uso de todas las funciones que forman parte del paquete "básico" de Julia.

El documento de referencia para las funciones es clave incluso para los programadores experimentados, ya que uno de los problemas habituales es la dificultad de recordar cómo se usa cierta función (qué argumentos acepta, qué resultados proporciona, etc.). Un atajo práctico cuando se trabaja en modo de línea de comandos consiste en escribir el signo de interrogación (`?`) al principio de una instrucción. Al hacerlo la interfaz cambia al "modo de ayuda" (la etiqueta que marca el comienzo de la línea cambia a `help?>`), y al introducir el nombre de la función (sin paréntesis ni argumentos, solo el nombre) aparece en pantalla el texto de referencia, como se muestra en la figura 4.

![Figura 4](assets/helpmode.png)

*Figura 4. Ejemplo de ayuda*

Puedes probar con cualquier función básica (por ejemplo `?div` para leer la ayuda sobre la división entre enteros), con un operador (p.ej. `?+` para la suma), o incluso para una variable que se haya definido (en ese caso dará una información básica sobre su contenido).

!!! note "Documentación a través de "docstrings""

    Si has realizado el ejercicio de crear la función [`gauss_diasemana`](#gauss_diasemana) con el código completo presentado en este capítulo, al escribir `?gauss_diasemana` podrás leer el texto de las líneas que preceden a la definición de la función. Esta forma de documentar las funciones u otro tipo de objetos es muy útil y recomendable para hacer programas trazables y comprensibles. Puedes encontrar más detalles en el [capítulo 3 sobre funciones](3-funciones-control.md#Docstring-1).

Para las dudas no resueltas en el  manual, entre otras cuestions, los creadores de Julia han organizado un foro de debate y preguntas, disponible en [https://discourse.julialang.org](https://discourse.julialang.org) (en inglés). Y además existen múltiples foros y redes sociales (también en español y otros idiomas), tanto promovidas por los desarrolladores como por los propios usuarios, donde se pueden encontrar infinidad de consultas pasadas y hacer nuevas. Una buena recopilación de estas redes se puede encontrar en [https://julialang.org/community/](https://julialang.org/community/).

## Sumario del capítulo

En este primer y breve capítulo hemos aprendido los siguientes puntos fundamentales para trabajar en Julia:

* Las distintas distribuciones y entornos de trabajo disponibles: Julia, JuliaPro, el REPL básico e IDEs diversos (con especial mención de la extensión para VS Code).
* Algunas reglas básicas de sintaxis del lenguaje.
* Cómo instalar y cargar paquetes.
* Cómo buscar ayuda.

A lo largo de las explicaciones también hemos empleado las siguientes funciones particulares (además de las propias de la gestión de paquetes):

* `cd` y `pwd` para definir y consultar el directorio de trabajo, respectivamente.
* `include` para ejecutar *scripts*.
* `joinpath` para componer nombres de directorios y archivos.
* `div` para divisiones enteras y `mod` para el resto de una división.

```@raw html
<hr>
<img src="assets/cc-by-sa-88x31.png" alt="CC-BY-SA"><br><span style="font-size:smaller">Except where otherwise noted, this website is licensed under a <a rel="license" href="https://creativecommons.org/licenses/by-sa/4.0/">Attribution-ShareAlike 4.0 International License</a></span>.
```