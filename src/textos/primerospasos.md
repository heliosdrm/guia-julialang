# Primeros pasos




## Instalación de Julia

Obviamente, lo primero que se necesita para trabajar con cualquier lenguaje de programación son las herramientas para crear y ejecutar los programas. El software básico para usar Julia está disponible en su página oficial (https://julialang.org/downloads), en forma de código fuente así como en binarios preparados para instalar en Windows, Mac OS X, y algunas distribuciones de Linux. Desde esa página se pueden encontrar también enlaces con explicaciones detalladas sobre cómo instalar y ejecutar Julia, que son específicas para cada sistema, y por lo tanto no desarrollaremos aquí.

El paquete básico de Julia presenta un sencillo intérprete de comandos (figura 1), ligero y rápido, útil para realizar pruebas o rutinas sencillas. Sin embargo, para muchos usuarios este tipo de interfaz es poco amigable, y las "ayudas" que proporciona (invocación de instrucciones anteriores usando las flechas de "arriba"/"abajo", combinaciones de teclas disponibles para acelerar las operaciones de corta-y-pega, etc.) resultan insuficientes. Por otro lado, para ejecutar rutinas más complejas, y siempre que se quiera obtener resultados reproducibles, es recomendable escribir las instrucciones en un archivo de código (*script*), y luego ejecutarlo en Julia. Con el intérprete básico se puede ejecutar un *script* (véase un ejemplo en la siguiente sección), pero para escribirlo se necesitaría un programa auxiliar.

Para combinar ambas tareas de forma eficiente en una sola interfaz lo habitual es usar los llamados "entornos de desarrollo integrados" (conocidos por sus siglas IDE en inglés), que pueden ser programas específicos para el lenguaje en cuestión, o aplicaciones genéricas con módulos particulares para distintos lenguajes. Para el usuario que se inicia en Julia se pueden recomendar dos paquetes de software gratuitos coin IDE incluída, desarrollados por [Julia Computing](https://juliacomputing.com), una compañía fundada por los creadores del lenguaje para ofrecer servicios profesionales.

El más sencillo de usar es [Julia Box](https://juliabox.com/), una plataforma web para crear "cuadernos de notas" (*notebooks*) en Julia. En estos cuadernos se puede escribir texto normal (incluyendo formatos de letra, estilos de título y de párrafo, etc.) e intercalarlo con bloques de código que se pueden ejecutar *in situ* con un click de ratón, de forma que los resultados (incluyendo gráficos) aparecen entre los párrafos de texto (figura 2). Otra ventaja es que se puede utilizar desde un navegador de Internet sin siquiera tener Julia instalado en el ordenador; lo único que hace falta es una cuenta de Github, Linkedin o Google con la que registarse para entrar. Trabajar con esta herramienta online tiene algunas limitaciones, pero es un recurso práctico en particular para hacer pruebas o para estudiantes. Julia Box está basado en [Jupyter](http://jupyter.org/), una evolución de la plataforma IPython que se desarrolló originalmente para hacer *notebooks* de Python, y desde la misma web de Jupyter se pueden también hacer pruebas más elementales con Julia (con una funcionalidad más limitada), sin tan siquiera registrarse, entrando de forma anónima en https://try.jupyter.org/ y abriendo un cuaderno de Julia.

Otro paquete más completo es [Julia Pro](https://juliacomputing.com/products/juliapro.html), una aplicación de escritorio (esta sí tiene que instalarse), que permite tanto crear *notebooks* a través de Jupyter --en una instalación local, no remota--, como trabajar en [Juno](http://junolab.org/), otro IDE para Julia basado en el editor de código [Atom](https://atom.io/). La interfaz de Juno está pensada para trabajar con uno o varios archivos de código simultáneos, visualizando a la vez las salidas de los bloques de código que se seleccionen para ejecutar, sea en forma de resultados, gráficos o información dirigida a la consola (figura 3).

La elección de una de estas dos alternativas (o incluso otras que no se mencionan aquí) depende de las necesidades del usuario, por lo que en este manual no se da ninguna preferencia. Los ejemplos que se presentarán a partir de ahora estarán dirigidos a un uso genérico, que se puede hacer tanto en Jupyter como Juno, o incluso en la consola de comandos básica de Julia.

!!! note

    Para los usuarios interesados en los términos legales, es conveniente destacar que la licencia de uso de Julia Pro es más restrictiva que la licencia MIT o BSD con la que están publicados sus componentes individuales (Julia, Juno, Jupyter, etc.). Para mantener vigentes los términos más abiertos de las licencias originales es posible (aunque lleva más trabajo) instalarse e integrar los distintos componentes a mano.

## Un ejemplo básico

Veamos ahora un ejemplo práctico de ambas formas de uso, con un programa sencillo para calcular el día de la semana en el que cae cualquier fecha del calendario Gregoriano, usando el algoritmo de Gauss tal como está publicado por Bernt Schwerdtfeger.[^1] Se trata de un algoritmo simple, que podría traducirse a Julia mediante el siguiente código: 

<a name="gauss_diasemana" />
~~~~{.julia}
"""
Cálculo del día de la semana.
La función devuelve una cadena de texto con el día de la semana que corresponde
a los números de día, mes y año introducidos como los argumentos numéricos
`d`, `m`, `y`, respectivamente.
"""
function gauss_diasemana(d, m, y)
    # Enero y febrero (m=1, m=2) se tratan como el año anterior
    # en torno a los años bisiestos
    if m < 3
        y = y - 1
    end
    # Dividir el año entre centenas (c) y el resto (g)
    c = div(y, 100)
    g = mod(y, 100)
    # Definir e y f en función del mes (de 1 a 12) y el siglo
    # (en ciclos de 400 años --- 4 siglos)
    earray = [0,3,2,5,0,3,5,1,4,6,2,4]
    farray = [0,5,3,1]
    e = earray[m]
    f = farray[mod(c,4)+1]
    # Seleccionar el día de la semana en función del cálculo de Gauss
    warray = ["domingo","lunes","martes","miércoles",
        "jueves","viernes","sábado"]
    w = mod(d + e + f + g + div(g, 4), 7)
    return(warray[w+1])
end
~~~~~~~~~~~~~





[^1]: http://berndt-schwerdtfeger.de/cal/cal.pdf

Supongamos que el código mostrado arriba está guardado en un archivo llamado `calc_diasemana.jl` (el nombre del archivo es arbitrario, y puede ser cualquier nombre aceptado por el sistema operativo. El programa consiste en una sola función con 3 argumentos (los números del día, el mes y el año), basada en unas pocas divisiones enteras (definidas en la función `div`) y el cálculo de "restos" de dichas divisiones (`mod`),[^2] más la selección de unos valores a partir de los resultados intermedios y unas listas predefinidas.

[^2]: Existen dos funciones para el resto de una división: `mod` y `rem`, que funcionan de forma distinta cuando alguno de los dos operandos es negativo. Para el caso que nos ocupa esa diferencia no es relevante.

Este programa se puede cargar usando la función `include` en el intérprete de Julia. Esto es lo que se debería ver en pantalla (los detalles de la presentación dependen de la interfaz usada):

~~~~{.julia}

include("calc_diasemana.jl")
~~~~~~~~~~~~~




El resultado es algo decepcionante, porque lo único que se ha hecho es definir una función, que por sí misma no da ningún resultado. Por otro lado, lo más probable es que al introducir esa línea sin más ni siquiera se obtenga ese resultado, sino un error debido a que no se encuentra el archivo de código.[^3] Para asegurarse de que Julia encuentra el archivo hay varias alternativas:

  * Copiar el archivo de código `calc_diasemana.jl` al directorio de trabajo de Julia. La ruta de ese directorio se puede obtener con la función `pwd()` -- sin ningún argumento--.
  * Cambiar el directorio de trabajo al lugar que contiene el archivo. El cambio de directorio se hace con la función `cd`, que recibe un solo argumento: el nombre del directorio destino. Este se puede definir literalmente como un texto entre comillas dobles, o ser una variable que contiene dicho texto.
  * Introducir la ruta completa del archivo de código en la llamada a `include`. Esta se puede escribir literalmente, o si el directorio que contiene el archivo está definido en una variable (supongamos que esta variable se llama `dir_include`, la ruta se puede componer con la función `joinpath`. Es decir, la expresión anterior sería `include(joinpath(dir_include, "calc_diasemana.jl"))`.

[^3]: Ref. a sección con información sobre LOAD_PATH y require()

!!! tip "Copiar nombres de directorios con `clipboard`"
     A veces los nombres de los directorios son largos y resulta tedioso escribirlos. Para hacerlo más fácil, en sistemas operativos se puede copiar el nombre del directorio desde el gestor de archivos al "portapapeles", y utilizarlo directamente en Julia con la función `clipboard`; por ejemplo se puede cambiar al directorio seleccionado mediante la expresión `cd(clipboard())`. Este truco es particularmente recomendable en Windows, donde los directorios de una ruta suelen presentarse divididos por "barras invertidas". Por ejemplo, el directorio de trabajo podría ser `C:\julia`. Pero la expresión `cd("C:\julia"` no daría el resultado esperado, porque la barra invertida se interpreta como inicio de una "secuencia de escape" para caracteres no imprimibles. Para que funcionase, habría que escribir `cd("C:/julia")` o `cd("C:\\julia")`. La función `clipboard` ahorra este tipo de problemas.

Una vez se ha conseguido cargar el archivo que define la función, esta ya se puede usar para obtener un resultado de verdad. Por ejemplo, para conocer en qué día de la semana cayó el San Valentín de 2012, la fecha en la que se hizo pública la primera versión de Julia:

~~~~{.julia}
julia> gauss_diasemana(14, 2, 2013)
"jueves"

~~~~~~~~~~~~~





Lo que se hace "en un día cualquiera" usando Julia es esencialmente este modelo de rutina, con funciones más complicadas y muchas más operaciones interactivas, explorando resultados, corrigiendo argumentos y repitiendo operaciones, claro está.

## Sintaxis básica

Para escribir un programa en Julia o cualquier otro lenguaje de programación hay que seguir una serie de reglas sintácticas, la mayoría de las cuales en realidad no es necesario explicar, ya que son reglas de escritura lógicas e intuitivas, o se desprenden directamente de la lectura de ejemplos. A continuación se mencionan algunos detalles básicos que se pueden observar en el anterior ejemplo del [algoritmo de Gauss](#gauss_diasemana):

  * Cada operación se escribe normalmente en una línea distinta, aunque es posible "partir" las expresiones en varias líneas. Si una línea acaba con una expresión incompleta se asume que continúa en la siguiente, como ocurre en la definición de la variable `warray` con los nombres de los días de la semana.
  
  * Todo el texto que sigue al símolo `#` hasta el final de la línea se considera un comentario, y no se ejecuta.

  * Las expresiones más habituales son las del tipo `a = f(b)`, como `c = div(y, 100)`, donde `a` es un nombre de variable, `f` el nombre de una función, y `b` el número, cadena de texto u otro tipo de argumento sobre el que opera esa función, o bien el nombre de la variable a la que se le ha asignado el valor de ese argumento. (La función también puede aceptar varios argumentos de entrada, como ocurre con `div`, o tener varias salidas, que se presentan como variables separadas por comas.)
  
  * También es habitual encontrarse expresiones del tipo `a = f[b]`, p.ej. en `e = earray[m]`, con corchetes en lugar de paréntesis. En esos casos `f` no es una función sino un vector, matriz u otra estructura de datos, y `b` es el índice o clave que identifica la parte de su contenido que se asignará a la variable `a`.
  
  * Los nombres de variables, funciones, etc. pueden estar formados por cualquier combinación de letras y números, más guiones bajos, exceptuando nombres que comiencen por números y las palabras clave del lenguaje (como `for`, `if`, `end`, etc.). Además, también se admiten nombres con caracteres Unicode más allá del ASCII básico (letras acentuadas, griegas, etc.), así como el signo de exclamación (`!`) en posición no inicial, aunque conviene usarlos con mesura: emplear caracteres extendidos aumenta el riesgo de problemas de portabilidad de los programas, y la exclamación se suele resevar para el nombre de cierto tipo de funciones (las que modifican sus argumentos de entrada).

  * Los bloques de código (funciones, bloques condicionales, etc.) se delimitan cerrándolos con la palabra clave `end`. Se recomienda indentar las líneas interiores al código para hacerlo más legible, aunque el programa funcionaría igualmente si no se hace.
  
  * En general los espacios son irrelevantes: siempre que haya algun símbolo delimitador (operadores matemáticos, signos de puntuación, paréntesis...) pueden usarse uno, varios o ningún espacio entre nombres de variables, funciones, etc., o al principio de la línea, excepto al inicio de las llamadas a "macros" (véase el capítulo XXXXXXXXXXXXXXXXXXXXXXX).

Hay más reglas importantes que conviene tener en cuenta para programar en Julia, aunque para contener el tamaño de esta introducción, se comentan con más detalle en el capítulo XXXXXXXXXXXXXXXXXX.

## Paquetes complementarios

La distribución básica de Julia es realmente "básica", y carece de bastantes utilidades que son consideradas importantes, incluso fundamentales por la mayoría de los potenciales usuarios de un lenguaje de ese tipo, como representaciones gráficas de datos, editor de código, ayudas para la depuración de rutinas (*debugging*), etc.

Esta limitación está cubierta por el desarrollo coordinado (aunque independiente) de cientos de "paquetes" que contienen dichas utilidades. Como el propio proyecto Julia, todos los paquetes oficiales están publicados con el sistema de [Git](http://git-scm.com/). Julia mantiene un catálogo online de los paquetes oficiales, cuya lista se puede consultar en el sitio http://pkg.julialang.org/, o desde Julia con la expresión `Pkg.available`. En los siguientes capítulos se irán señalando algunos paquetes útiles para cubrir los distintos aspectos tratados en cada momento.

Las soluciones más completas como Julia Box o Julia Pro ya incorporan muchos de los paquetes más importantes, pero incluso en esos casos puede ser necesario gestionarlos, actualizarlos o añadir nuevos paquetes. La instalación y desinstalación de paquetes se controla desde dentro de Julia, mediante las funciones `Pkg.add` y `Pkg.rm`, respectivamente, que toman como argumento el nombre del paquete a instalar o desinstalar. Estas operaciones consisten esencialmente en "clonar" el paquete publicado en un lugar determinado del sistema, o borrarlo de ese sitio (el directorio de instalación está definido en la variable `JULIA_PKGDIR` si existe, o por defecto en el directorio designado por la función `Pkg.dir`). Por ejemplo, el proceso para instalar el paquete [Plots](https://github.com/JuliaPlots/Plots.jl) (usado para crear representaciones gráficas) podría ser como sigue:

~~~~{.julia}

# Consultar si está instalado (en cuyo caso no hace falta instalarlo)
Pkg.installed("Plots")
# Si devuelve "nothing" (no está instalado):
Pkg.add("Plots")
~~~~~~~~~~~~~




Esta operación solo hay que hacerla una vez (actualizaciones aparte). Sin embargo, tener el paquete instalado no basta para poder usarlo. Para esto último hay que cargarlo explícitamente en cada sesión de trabajo, con la instrucción `using`:

~~~~{.julia}

using Plots
~~~~~~~~~~~~~





## Buscando ayuda

Con toda seguridad, al programar en Julia pronto te encontrarás con dificultades que no puedes resolver con la información que se recoge en este manual, y necesitarás ayuda adicional. Lo primero con lo que se ha de contar es el manual de referencia oficial (https://docs.julialang.org/en/stable/), que contiene numerosos detalles de múltiples aspectos del lenguaje, y también explica el uso de todas las funciones que forman parte del paquete "básico" de Julia.

El documento de referencia para las funciones es clave incluso para los programadores experimentados, ya que uno de los problemas más recurrentes es la dificultad de recordar cómo se usa cierta función (qué argumentos acepta, qué resultados proporciona, etc.). Un atajo práctico cuando se trabaja en modo de línea de comandos consiste en escribir el signo de interrogación (`?`) al principio de una instrucción. Al hacerlo la interfaz cambia al "modo de ayuda" (la etiqueta que marca el comienzo de la línea cambia de `julia>` a `help?>`), y al introducir el nombre de la función (sin paréntesis ni argumentos, solo el nombre) aparece en pantalla el texto de referencia.

Se puede probar con cualquier función básica (por ejemplo `?div` para leer la ayuda sobre la división entre enteros), con un operador (p.ej. `?+` para la suma), o incluso para una variable que se haya definido (en ese caso dará una información básica sobre su contenido).

!!! note """Documentación a través de "docstrings" """

    Si has realizado el ejercicio de crear la función [`gauss_diasemana`](#gauss_diasemana) con el código completo presentado en este capítulo, al escribir `?gauss_diasemana` podrás leer el texto de las líneas que preceden a la definición de la función. Esta forma de documentar las funciones u otro tipo de objetos es muy útil y recomendable para hacer programas trazables y comprensibles.

Para las dudas no resueltas en el  manual, entre otras cuestions, los creadores de Julia han organizado un foro de debate y preguntas, disponible en https://discourse.julialang.org (en inglés). Y además existen múltiples foros y redes sociales (también en español y otros idiomas), tanto promovidas por los desarrolladores como por los propios usuarios, donde se pueden encontrar infinidad de consultas pasadas y hacer nuevas. Una buena recopilación de estas redes se puede encontrar en https://julialang.org/community/
