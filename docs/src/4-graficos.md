# Capítulo 4. Gráficos

```@setup c4
cp("../../datos/", "./datos")
```

En los capítulos anteriores de esta guía hemos hecho un tratamiento superficial, incluso podría decirse que apresurado, de unos pocos aspectos básicos en los que muchos otros manuales, sean de Julia o cualquier otro lenguaje de programación, suelen ser más detallados en sus capítulos introductorios. En este capítulo dedicado a los gráficos, sin embargo, vamos a detenernos más a pesar de que es una funcionalidad bastante avanzada, y requiere instalar algunos paquetes auxiliares y herramientas externas para empezar.

Hay una buena razón para hacerlo así. El usuario de una herramienta informática normalmente no juzga si una tarea es "básica" o "avanzada" según las complejidades que supone para esa herramienta, sino por cuestiones más prácticas. Y explorar visualmente los datos es una de las primeras cosas que se suele hace después de recogerlos, como mínimo para valorar si parecen correctos o hay algún tipo de anomalía. En este sentido los gráficos podrían considerarse como una de las tareas más básicas. De hecho no es raro que el ansia por ver qué pinta tienen los datos conduzca a atajos "sucios y rápidos", como abrir los ficheros con una hoja de cálculo e improvisar gráficas con un par de *clicks* de ratón, antes de empezar los preparativos para un análisis más formal.

Parece lógico, por tanto, que las instrucciones para crear gráficos también se introduzcan lo más pronto posible a la hora de presentar una herramienta para el análisis de datos. Además, parafraseando el refrán popular, se puede decir que un gráfico vale más que mil números. Julia tiene una potencia extaordinaria para hacer cálculos complejos y costosos de forma rápida y eficaz; pero la representación de los resultados en un sencillo gráfico a veces da una mayor sensación de productividad, y aprender a crear esos gráficos es una buena manera de aumentar la motivación para introducirse en un lenguaje de programación.

## El paquete Plots y otras alternativas

Julia nos ofrece la versatilidad y potencia de múltiples herramientas externas para generar gráficos, a través de paquetes complementarios que instalan automáticamente las librerías gráficas[^1] necesarias y proporcionan funciones para manejarlas desde Julia. El que usaremos para los ejemplos que siguen es [Plots](http://docs.juliaplots.org/latest/) (versión 1), uno de los más populares, y que proporciona una interfaz común para manejar muchos de esos otros paquetes, de tal manera que solo hace falta aprender una forma de crear y editar gráficos. Además, tiene una excelente documentación con numerosos tutoriales, ejemplos y demostraciones disponibles en su página web (en inglés), muy recomendables para ampliar los conceptos más básicos que se presentan aquí.

Según los gráficos que se quieran hacer, también puede ser interesante instalar [paquetes complementarios](http://docs.juliaplots.org/latest/ecosystem/) que aumentan su funcionalidad, según el campo en el que se vaya a trabajar. Aunque con el paquete básico de Plots ya se pueden conseguir muchos resultados.

Si no se tienen otras librerías gráficas instaladas, Plots utiliza por defecto la del paquete [GR](https://github.com/jheinen/GR.jl). Otros paquetes muy populares son [PyPlot](https://github.com/JuliaPy/PyPlot.jl), basado en la librería gráfica que se suele usar con Python, [VegaLite](https://www.queryverse.org/VegaLite.jl/stable/) para hacer sofisticados gráficos interactivos, o [UnicodePlots](https://github.com/Evizero/UnicodePlots.jl) en el otro extremo, para crear gráficos basados en caracteres de texto sobre la consola de comandos. Una vez se ha "roto mano" con el lenguaje, y si se dispone de tiempo para ello, puede ser buena idea explorar distintos paquetes para escoger el que mejor se adapta a las necesidades y limitaciones de cada uno.

[^1]: "Librería gráfica" es una traducción macarrónica del inglés *graphic library*, que designa un conjunto de herramientas de software, utilizadas por el sistema operativo para hacer operaciones gráficas (crear y manipular ventanas en pantalla, generar archivos gráficos, "dibujar" formas geométricas en dichas ventanas y archivos, etc.)

## Un ejemplo básico

Una vez instalado el paquete Plots, hacer gráficos es rápido y sencillo. Por ejemplo, el [gráfico del capítulo 2](2-series-tablas.md#ejemplo_series) con una muestra de las señales analizadas se realizó con las siguientes instrucciones:

```@example c4
# Primero leemos el archivo con la serie de datos datos a representar
# (la primera columna tiene los tiempos, y la otra los valores de la serie)
using DelimitedFiles
datos = readdlm("datos/series/sA01.txt")
# Cargamos el paquete Plots y utilizamos la función `plot`
using Plots
x = datos[:,1]
y = datos[:,2]
plot(x, y)
```

!!! note "¿Por qué tarda tanto el primer gráfico?"

    Al reproducir el ejemplo anterior se puede observar que desde que se ejecuta la línea `plot(x, y)` hasta que se presenta el gráfico pasa un tiempo (puede ser corto o largo dependiendo del ordenador y la versión de Julia). La generación y presentación de gráficos es una operación relativamente compleja, y la mayor parte de ese tiempo está dedicado a compilar las instrucciones. La buena noticia es que tras el primer gráfico, la generación de los siguientes es generalmente muy rápida.

Según el entorno en el que se esté trabajando, este código hará que el gráfico se muestre de una manera u otra. Por ejemplo, en el REPL normalmente se abre en una nueva ventana; en IDEs como Juno y VSCode se muestra en el panel de gráficos dedicado; y en un notebook de IJulia los gráficos aparecen en celdas como imágenes integradas en las celdas de resultados.

Si nos interesase mostrar varias señales en la misma gráfica, tenemos a nuestra disposición muchas formas de hacerlo. Por ejemplo, vamos a añadir la última señal.

Como en este caso todas las señales tienen la misma longitud (100 muestras), podemos juntar la primera y la última como dos columnas de una misma matriz, y pasar esta matriz como segundo argumento a la función `plot`:

```@example c4
datos_b = readdlm("datos/series/sB30.txt")
y2 = datos_b[:,2]
matriz = [y y2]
plot(x, matriz)
```

Otra forma de hacerlo es dibujando la segunda gráfica sobre la primera, usando la función `plot!` (con una exclamación al final):

```julia
plot(x, y)
plot!(x, y2)
```

En ambos casos, el resultado sería la misma gráfica mostrada antes.

## Atributos de las líneas

Por defecto, las series de datos se presentan como líneas que se dibujan con colores diferentes para ayudar a diferenciarlas, y etiquetadas como `y1`, `y2`, etc. Pero podemos modificar el color y el estilo de línea, las etiquetas, o incluso sustituir las líneas por otros elementos gráficos (puntos, barras y otras geometrías)

Esto se consigue especificando los atributos de las series de datos, como argumentos "con nombre" que se añaden a la función `plot` (o `plot!`). Veamos una variación de la gráfica anterior combinando distintos atributos, que se explican a continuación

```@example c4
plot(x, [y y2],
    style = [:solid :dash], width = 2,
    color = ["purple" colorant"#00ff00"],
    label = ["sA01" "sB30"]
)
```

En este ejemplo se han modificado cuatro atributos de las líneas:

* `style` (forma abreviada de `linestyle`), que define el estilo de línea. Algunos de los valores posibles son `:solid` (línea continua, que es el valor por defecto), `:dash` (a rayas), `:dot` (punteada), o `:dashdot`(línea con puntos).
* `width` (o `linewidth`), que define la anchura de la línea en píxeles.
* `color` (forma abreviada de `seriescolor`), que define el color de la línea. El color puede venir definido por su nombre en inglés en forma de texto (p.ej. `"purple"`) o símbolo (`:purple`), o bien por un código numérico expresado con la clave `colorant`, como `colorant"#00ff00"`, que es un verde saturado en código hexadecimal (equivalente al color "lime").
* `label`: la etiqueta usada en la leyenda.

!!! tip "Códigos de color"

    Los nombres y los códigos numéricos que se pueden emplear para definir los colores son los recogidos por el [estándar para CSS](https://www.w3.org/TR/css3-color/). Este incluye 62 nombres, desde los más básicos hasta algunos tan exóticos como el "blanco fantasmal" ("ghostwhite") o el de "papaya batida" ("papayawhip"), códigos RGB como `colorant"rgb(0,255,0) --también en porcentaje `colorant"rgb(0,100%,0)"`, o en código hexadecimal `colorant"#00ff00"`--, y códigos HSL como `colorant"hsl(120,100%,50%)"`.

Algunas librerías gráficas permiten definir además el nivel de opacidad (llamado "canal alfa"), con el atributo `seriesalpha` (también `linealpha` o simplemente `alpha`), que puede adoptar un número entre 0 (transparente) y 1 (totalmente opaco).

Así pues, una línea en color lima semitransparente también podría dibujarse con cualquiera de las siguientes expresiones:

```julia
plot(x,y, color=:lime, alpha=0.5)
plot(x,y, color=colorant"rgb(0,255,0,0.5)")
plot(x,y, color=colorant"hsl(120,100%,50%)", alpha=0.5)
``` 

Otro detalle a destacar en el ejemplo anterior es cómo se han estructurado los conjuntos de atributos:

* Al atributo `width` solo se le ha dado un valor, que por lo tanto se aplica por igual a todas las líneas.
* Los atributos `style`, `color` y `label` se han definido como dos valores en una *matriz columna* (elementos separados por espacios), de tal que a cada línea se le ha asignado el valor de la columna correspondiente.

Los atributos correspondientes a series de datos distintas se disponen en columnas, igual que las propias series de datos. Si se dispusieran en un vector (equivalente a una columna), se interpretaría que cada valor del atributo se corresponde con *un punto* de la(s) serie(s). Por ejemplo, se puede hacer variar el grosor de la línea dándole un valor a cada punto como en el siguiente ejemplo:

```@example c4
plot(x, y, width=range(0, 5, length=100))
```

## Otros tipos de gráficos y atributos

En los ejemplos anteriores, las secuencias de puntos formadas por los datos de entrada se han representado como líneas trazadas en el plano X-Y, que es una de las formas más habituales de dibujar series de datos. Pero hay muchas otras posibilidades, que también dependen del conjunto de datos introducidos.

Los gráficos de líneas también pueden ser tridimensionales, para lo cual hay que introducir una tercera serie de datos (`plot(x, y, z)`). Y también se puede introducir un solo vector que representa las coordenadas en el eje Y, en cuyo caso los valores en X son una secuencia de números enteros (1, 2, 3...).

Además, se puede cambiar el elemento geométrico que representa de los datos, ajustando el atributo `seriestype`, que también puede ser, por mencionar algunos casos habituales:

* `:scatter` para gráficos de dispersión (con puntos), de dos o tres dimensiones.
* `:bar` para gráficos de barras.
* `:quiver` para campos de flechas (requiere argumentos adicionales para indicar la dirección y tamaño de las flechas).
* `:histogram` para histogramas de una serie de datos.
* `:surface` y `:wireframe`para gráficos tridimensionales, representadas como superficies coloreadas o mallas, respectivamente.
* `:contour` para gráficos de contorno (como superficies vistas en 2D).

Los gráficos con esos y otros tipos de elementos se pueden crear utilizando directamente el valor de `seriestype` como nombre de la función, en lugar de `plot`. Por ejemplo, un gráfico de barras podría dibujarse con `plot(y, seriestype=:bar)` o sencillamente `bar(y)`. En esos casos también existen las funciones "con exclamación" (`bar!`, etc.) para dibujar encima del gráfico anterior.

Vamos a mostrar, como ejemplo, un gráfico de barras a partir de la tabla de esperanzas de vida que vimos en el capítulo 2. Además, vamos a añadirle un par de atributos más para mostrar algunas funcionalidades extra:

```@example c4
using CSV, DataFrames
tabla_un = DataFrame(CSV.File("datos/esperanzadevida.txt", delim=' ', ignorerepeated=true))
# Seleccionamos los casos de ambos géneros
todos = (tabla_un[!, "género"] .== "Todos")
bar(tabla_un[todos, "continente"], tabla_un[todos, "media"],
    yerror=tabla_un[todos, "desv_tip"],
    label="")
```

En este ejemplo hemos añadido el atributo `label=""` para que no haya leyenda, y también `yerror` con los valores de la desviación típica para superponer barras de error verticales en torno a los datos.

Hay muchísimos más atributos disponibles, aunque dependiendo del tipo de elemento gráfico algunos atributos pueden tener sentido o no. Por ejemplo, el atributo `color` o `seriescolor` se puede aplicar a la mayoría de elementos gráficos, pero `linewidth` solo es aplicable a líneas. El color también puede definirse de forma más específica según el elemento, por ejemplo se puede especificar un color para las líneas (atributo `linecolor`) distinto del color de los marcadores (`markercolor`), el color de relleno (`fillcolor`), etc.

El conjunto completo de atributos disponibles para los elementos geométricos se puede consultar con la instrucción `plotattr(:Series)`. La definición concreta de cada atributo también se puede obtener con la misma función, indicando el nombre del atributo, p.ej. `plot("color")`. Toda esa información también viene recogida en [la documentación de Plots](http://docs.juliaplots.org/latest/generated/attributes_series/)

## Ajustes y decoraciones

Los gráficos se pueden complementar con etiquetas en los ejes, títulos, leyendas y otros elementos que ayuden a interpetarlos. Por ejemplo, veamos un gráfico con los resultados del análisis de las señales realizado en el [capítulo 2](2-series-tablas.md#ejemplo_series). La tabla de resultados era:

```@example c4
using CSV # hide
tabla_resultados = DataFrame(CSV.File("datos/tabla.txt", header=["Archivo", "X", "Y"])) # hide
```

El siguiente gráfico muestra la relación entre tiempos y valores de los picos de las señales, separando los quince primeros casos (los que comienzan como "sA", de los quince segundos ("sB"). El gráfico incluye una leyenda para distinguir estos dos conjuntos, etiquetas para los ejes X e Y, y un título. Además, se han ajustado los límites de los ejes a unos rangos mayores que los que se muestran por defecto:

```@example c4
using DelimitedFiles
resultados = readdlm("datos/tabla.txt", ';')
scatter(resultados[1:15,2], resultados[1:15,3], label="sA")
scatter!(resultados[16:30,2], resultados[16:30,3], label="sB")
xlims!(0, 1)
ylims!(0, 30)
xlabel!("tiempo")
ylabel!("valor extremo")
title!("Resultados del análisis")
```

En este ejemplo vemos de nuevo el uso del atributo `label` para modificar la leyenda del gráfico, y otras funciones que permiten modificar otras partes del mismo:
* `xlims!` e `ylims!` para ajustar los rangos de valores mostrados en los ejes X e Y. (También existe `zlims!` para el eje Z en gráficos tridimensionales.)
* `xlabel!` e `ylabel!` para añadir etiquetas a los ejes X e Y. (Usar `zlabel!` para el eje Z en gráficos tridimensionales.)
* `title!` para añadir un título en la parte superior del gráfico.

En lugar de las funciones `xlims!`, etc., se podrían haber defindo los atributos correspondientes al llamar a `scatter` (o `plot`, o cualquiera de las funciones que generan los graficos), p.ej. `scatter(x, y, xlims=(0,1))`.

Hay muchos más atributos de los gráficos que se pueden ajustar como la escala de los ejes, líneas guía, mapas de color, formato de los textos, etc. Esos atributos no se asocian a los elementos que representan las series de datos, sino a otras partes del gráfico:

* El plano en el que se proyecta el espacio de coordenadas en el que se representa el conjunto de datos. Suele ser un rectángulo, aunque hay gráficos en coordenadas polares con una disposición circular. Este elemento recibe el nombre de `Axis`, aunque incluye más cosas aparte de los ejes de coordenadas (p.ej. el color de fondo, las guías, etc.)
* El panel sobre el que se organizan los elementos del gráfico: los ejes de coordenadas y sus etiquetas, el título, las leyendas, etc. Este elemento recibe el nombre de `Subplot` --considerando la posibilidad de que existan composiciones de gráficos con más de uno de estos paneles--.
* El marco global, que es lo que recibe el nombre genérico de `Plot`, y contiene todos los elementos de un gráfico. Puede ser una ventana, una página de un documento o un cuadro dentro de la misma en la que se enmarca el gráfico, etc.

Las distintas opciones disponibles para cada atributo se pueden consultar, como se ha visto antes, usando la función `plotattr`, por ejemplo `plotattr("xlims")` para ver cómo se definen los límites del eje X. Los atributos configurables de cada una de esas partes de un gráfico también se pueden consultar con la misma función, por ejemplo `plotattr(:Axis)` para listar los atributos del plano de coordenadas, etc. La página web de Plots también tiene secciones que muestran todas las opciones, como se ha visto antes para los elementos geométricos.

## Trabajar con varios gráficos

Las funciones como `plot`, `plot!` y equivalentes devuelven un objeto de tipo `Plot`, que se puede guardar en una variable para recuperar el gráfico generado o modificado, incluso después de haberlo reemplazado por otros. Por ejemplo, tomemos este bloque de código:

```julia
p1 = plot(x, y)
p2 = scatter(w, z)
```

La primera línea genera un gráfico del líneas que se guarda en la variable `p1`, y la segunda un gráfico de dispersión que se guarda en `p2`. Si se ejecutan las dos líneas en el mismo bloque, el primer gráfico normalmente no se verá porque lo hemos reemplazado por el segundo, pero aún lo tendremos disponible en la variable `p1`. Para visualizarlo, lo único que tenemos que hacer es ejecutar otra línea de código que simplemente contenga `p1` (la forma habitual de ver el contenido de una variable).

Asímismo, a las funciones que sirven para modificar gráficos se les puede indicar explícitamente cuál de ellos se quiere editar, cuando se está trabajando con varios a la vez. Por ejemplo, antes hemos utilizado `title!` con una cadena de texto para añadir un título con ese texto al último gráfico generado. Pero también podemos especificar que queremos poner título a un gráfico generado anteriormente, poniendo la variable que lo contienen como primer argumento:

```julia
title!(p1, "Líneas")
title!(p2, "Puntos")
```

Por otro lado, un conjunto de gráficos pueden componerse como *subplots* de otro, simplemente pasándolos a la función `plot` como argumentos. Por ejemplo:

```julia
plot(p1, p2)
```

La disposición de los gráficos se calcula de forma automática intentando que la relación de anchura y altura se altere lo mínimo posible. En este caso, el gráfico generado dispondría `p1` a la izquierda de `p2`. Si se compusiesen cuatro gráficos, por defecto se dispondrían en una malla de 2×2, etc. Y también se puede hacer un diseño personalizado, usando el atributo `layout`. El valor asignado a este atributo puede ser:

* Una tupla de números enteros indicando las filas y columnas de una cuadrícula homogénea; por ejemplo `layout=(2,3)` para disponerlos en una cuadrícula de 2 filas y 3 columnas.
* Un objeto de tipo `GridLayout` para composiciones más complejas.

La manera más sencilla de generar un `GridLayout` es mediante la función `grid`, pasándole el número de filas y columnas, más (opcionalmente) los argumentos con nombre `heights` o `widths` para definir los tamaños relativos de las filas o las columnas. Veamos por ejemplo, un gráfico de dispersión con histogramas marginales:

```@example c4
using Random
x = randn(1000)
y = x .+ randn(1000)
# Gráfico principal con la nube de puntos
sxy = scatter(x, y, markersize=1,
    xlabel="X", ylabel="Y", border=:box)
# Histogramas marginales (el del eje Y en horizontal)
hx = histogram(x)
hy = histogram(y, orientation=:horizontal)
# Gráfico vacío para la esquina superior derecha
p = Plots.Plot()
# Cuadrícula de paneles
cuadricula = grid(2,2, heights=(0.2,0.8), widths=(0.8,0.2))
plot(hx, p, sxy, hy, legend=:none, layout=cuadricula)
```

En la última línea de este ejemplo hemos pasado a `plot` los cuatro gráficos que rellenan la cuadrícula de 2×2, en la que la fila superior y la columna derecha ocupan el 20% de la ventana. Los gráficos se pasan ordenados de izquierda a derecha y de arriba a abajo. Para que la esquina superior derecha quede vacía hemos generado un gráfico vacío con `Plots.Plot()`. Además, hemos manipulado algunos atributos (`border`, `orientation` y `legend`) para personalizar más los gráficos.

Se pueden conseguir composiciones aún más sofisticadas usando la macro `@layout`. (Véase la [página sobre *layouts*](http://docs.juliaplots.org/latest/layouts/) en la documentación del paquete Plots para más detalles sobre cómo usar esa macro.)


## Guardar gráficos como archivos de imagen

Para poder utilizar un gráfico fuera de Julia, lo más práctico es guardarlo como una imagen que luego se podrá añadir a un documento, presentación, etc. Esto se hace con la función `savefig`, por ejemplo:

```julia
savefig("ejemplo.png")
savefig(f, "ejemplo.png")
```

Ambas líneas de este ejemplo crean un archivo de imagen llamado `"ejemplo.png"`. En el primer caso la imagen tendrá el contenido de la figura actual; en el segundo el de la figura guardada en la variable `f`.

El tipo de archivo dependerá de la extensión indicada en su nombre. En este ejemplo se crea un mapa de bits en formato PNG. En el caso de querer una imagen vectorial, se podría haber salvado con la extensión SVG (ideal para web) o PDF, según el uso que se le vaya a dar. Según las herramientas instaladas en el sistema puede haber más o menos formatos disponibles.

## Sumario del capítulo

En este capítulo hemos visto algunos aspectos elementales sobre cómo hacer y editar gráficos con través del paquete Plots. En particular, nos hemos centrado en:

* El uso de la función `plot` para representar una o varias series de datos.
* Cómo modificar los atributos de un gráfico mediante argumentos con nombre en `plot` y otras funciones; y cómo usar la función `plotattr` para consultar los múltiples atributos que se pueden manipular.
* Ejemplos de atributos para modificar el tipo de elemento gráfico que representa los datos, sus tamaños, colores, las coordenadas del gráfico, etiquetas y leyendas, etc.
* Funciones equivalentes a `plot` para dibujar tipos de gráficos distintos del de líneas (equivalente a cambiar el atributo `seriestype`): gráficos de dispersión, de barras, histogramas, y algunos gráficos tridimensionales.
* Funciones "con exclamación" como `plot!` y otras, que sirven para modificar gráficos previos, así como sus atributos.
* Las partes en las que se componen los gráficos: `Series`, `Axis`, `Subplot` y `Plot`, y cómo usar esos conceptos para explorar los atributos que se pueden manipular.
* La asignación de gráficos a variables para poder trabajar con múltiples figuras, incluyendo gráficos compuestos.
* Cómo guardar gráficos en archivos de dibujo matriciales y vectoriales.

* Los códigos de formato usados para especificar el color y tipo de líneas y marcadores en los gráficos.
* Cómo crear leyendas, etiquetas y títulos para anotar los gráficos.
* El uso de la función `hold` para añadir nuevos datos a un gráfico anterior.
* Cómo crear nuevas figuras y cambiar la figura actual.
* La creación de gráficos múltiples mediante la función `subplot`.
* Salvar gráficos como archivos de imagen con `savefig`.

Además, también se han introducido otros dos detalles generales de Julia, no relacionados con los gráficos:

* La función `randn` para crear series de números aleatorios que siguen una distribución normal estándar.
* El uso del guión bajo como separador visual en números de muchas cifras (p.ej. `10_000`).

```@example c4
Figure(); # hide
rm("datos", recursive=true) # hide
```
