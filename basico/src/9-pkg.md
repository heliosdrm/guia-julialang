# Capítulo 9. Gestión de paquetes

Si comparamos los lenguajes de programación con los lenguajes naturales, se podría decir que hasta el presente punto de esta guía se han tratado los elementos esenciales de la "gramática" de Julia, con los que se podría construir cualquier programa. Una vez dominada esta gramática, lo siguiente que hace falta para un uso fluido del lenguaje es conocer más "vocabulario" (principalmente funciones y otros tipos de variables), que sirvan para expresar las ideas (operaciones) necesarias.

En la [documentación oficial](https://docs.julialang.org/en/v1/) se puede encontrar la lista completa de las funciones y otros elementos disponibles en el [módulo base](https://docs.julialang.org/en/v1/base/base/), así como en los múltiples módulos de la "biblioteca estándar" (sección *Standard Library* del manual). Esos módulos incluyen algunos de los que se han usado en esta guía, como [`DelimitedFiles`](https://docs.julialang.org/en/v1/stdlib/DelimitedFiles/), [`LinearAlgebra`](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/), [`Statistics`](https://docs.julialang.org/en/v1/stdlib/Statistics/), [`Random`](https://docs.julialang.org/en/v1/stdlib/Random/), [`Dates`](https://docs.julialang.org/en/v1/stdlib/Dates/) o [`Printf`](https://docs.julialang.org/en/v1/stdlib/Printf/).

Sin embargo, para un uso realmente productivo de Julia hay que ir más allá de la biblioteca estándar, y recurrir a paquetes externos, como [CSV](https://juliadata.github.io/CSV.jl/stable/), [DataFrames](http://juliadata.github.io/DataFrames.jl/stable/) y [Plots](http://docs.juliaplots.org/latest/), por poner tres ejemplos usados en la guía. En este capítulo veremos algunos detalles sobre cómo instalar y gestionar tales paquetes. Las herramientas que se presentarán también facilitan el desarrollo y mantenimiento de los paquetes; pero en esta guía las explicaciones se limitan a las que tienen que ver con el uso de paquetes desarrollados por otros.

## Dónde encontrar paquetes para Julia

La mayoría de paquetes para Julia están creados por la comunidad de usuarios, y su desarrollo está descentralizado. Cada usuario/desarrollador puede escoger la forma y el sitio donde publicar los paquetes creados, pero para facilitar su instalación existe un "Registro General" que recoge una lista con detalles técnicos de miles de paquetes. Los más conocidos, y en general la mayoría de los que se suelen necesitar, están incluidos en ese registro.

[El sitio web del Registro General](https://github.com/JuliaRegistries/General) no es fácil de explorar, ni proporciona directamente la información que necesitan los usuarios para "descubrir" los paquetes. Para ello se puede usar el servicio [JuliaHub](https://juliahub.com/), que permite buscar los paquetes registrados por nombre, temática o popularidad, entre otros criterios. También existe la web [Julia Packages](https://juliapackages.com/), de código abierto, que ofrece un servicio semejante. Además, la [web oficial de Julia](https://julialang.org/) tiene un apartado titulado "*Ecosystem*" que recomienda algunos paquetes para tareas o dominios de uso habituales.

!!! note "¿Son fiables los paquets de terceros?"

    El Registro General es un repositorio de uso público, es decir que cualquier usuario puede proponer paquetes para ser incluidos en él, siempre que cumplan ciertas reglas para que se puedan instalar de forma segura. No se hace, sin embargo, ninguna revisión de la funcionalidad de los paquetes. Por lo tanto, el hecho de que un paquete esté en ese registro no garantiza que funcione correctamente. Para saber qué paquetes son más recomendables, lo mejor es guiarse por las valoraciones de los usuarios. Los servicios de búsqueda citados incluyen una métrica de popularidad en forma de "estrellas" concedidas por la comunidad de usuarios. 


## Instalación y eliminación de paquetes y sus dependencias

Como ya se explicó en el [capítulo 1](1-primerospasos.md#pkg), la gestión de paquetes se hace habitualmente desde el modo de "gestor de paquetes" del REPL, que se activa introduciendo el símbolo `]` al comienzo de una instrucción. Al hacerlo, la etiqueta del REPL cambia de `julia>` a `pkg (@vX)>`, donde `X` es el número de versión de Julia. Para volver al modo normal, basta pulsar la tecla de borrar antes de escribir ninguna instrucción. En los ejemplos que siguen, el modo de gestión de paquetes se distinguirá igualmente por la etiqueta `pkg>` al principio de la línea. Las instrucciones para este modo que se mencionen a lo largo del texto irán precedidas por el símbolo `]` para distinguirlas.

Todos los comandos el el "modo pkg" se corresponden con una función del módulo `Pkg`, que se puede usar para programar las acciones en un *script* de Julia. Así pues, por ejemplo para instalar el paquete `CSV` valdrían igualmente las siguientes instrucciones (primero en el modo de gestor de paquetes, y luego en el modo normal de Julia):

```julia-repl
pkg> add CSV

julia> using Pkg

julia> Pkg.add("CSV")
```

Como se puede apreciar, en el "modo pkg" el nombre del paquete se escribe sin comillas. También se pueden instalar paquetes no incluidos en los registros, si están disponibles a través de una URL, escribiendo dicha URL en lugar del nombre del paquete.

En el momento en el que se instala un paquete, la consola comienza a poblarse de mensajes como los mostrados en la siguiente figura, con referencias al paquete en cuestión pero también a muchos otros.

![Figure 1](assets/pkgadd.png)

Esto ocurre porque en Julia, como en muchos otros lenguajes de programación, los paquetes que añaden nuevas funcionalidades forman un "ecosistema" con una compleja red de dependencias entre ellos. Así, por ejemplo, un paquete como `CSV` que sirve para grabar tablas de datos en archivos de texto estructurados, o crear las tablas a partir de ese tipo de archivos, emplea las utilidades de otros paquetes que definen tipos de tablas de datos (p.ej. `Tables`), algunos que facilitan la conversión de texto a otro tipo de valores (`Parsers`), etc. Y estos a su vez utilizan funcionalidades de otros paquetes, y así se forma un árbol de dependencias, que habitualmente abarca decenas de paquetes.

Para facilitar el proceso de instalación, todas las dependencias directas e indirectas se descargan y se instalan automáticamente. Los mensajes mostrados en pantalla reflejan los paquetes que se han instalado o modificado a causa de esas relaciones de dependencia.

Es importante tener en cuenta que, aunque al añadir un paquete se instalen todas sus dependencias, solo se permite cargar con `using` aquellos que se han instalado explícitamente. Por ejemplo, con `]add Plots` se instalan tanto el paquete `Plots` como todas sus dependencias, pero aunque `JSON` sea una de ellas, la instrucción `using JSON` no funcionará salvo que antes se ejecute también `]add JSON`.

Para verificar qué paquetes se han instalado explícitamente y están disponibles para usar, se puede ejecutar el comando `]status` (o de forma abreviada, `]st`).

También se pueden quitar paquetes que ya no se consideren necesarios, mediante `]remove` o `]rm`. Por ejemplo, si se ha instalado el paquete `Plots`, para eliminarlo valdría cualquiera de las dos siguientes instrucciones:

```julia-remove
pkg> remove Plots
pkg> rm Plots
```

Esta acción hace que el paquete ya no esté disponible (no se mostrará con `]status`), pero no borra necesariamente los archivos de su instalación, ya que en principio puede servir de dependencia para otros paquetes. Para desinstalar paquetes completamente y liberar espacio de disco se puede ejecutar `]gc` (de las siglas en inglés *garbage collector*, "retirada de basura"). Esta operación revisa si hay paquetes instalados que no se usen, directa o indirectamente, en ningún proyecto de Julia usado en ese ordenador, y si se da el caso los borra del sistema.

## Actualizar y fijar versiones

Los paquetes externos tienen un ritmo de desarrollo propio, independiente del núcleo del lenguaje, y a menudo se publican nuevas versiones con arreglos y mejoras de estos paquetes con más frecuencia que la distribución base de Julia. El comando `]status` o `]st` muestra, junto a los nombres de los paquetes instalados, las versiones de los mismos. Una vez instalado un el paquete `X`, este se puede actualizar en cualquier momento a la versión más reciente posible mediante `]update X` o `]up X`. Si no se indica ningún paquete en particular, `]update` o `]up` busca actualizaciones de todos los paquetes instalados.[^1]

[^1]: Esto solo afecta a los paquetes que se hayan instalado desde un repositorio como el Registro General u otro equivalente. En particular, los paquetes añadidos directamente desde una URL no se pueden actualizar de este modo.

Es posible que la versión a la que se actulicen algunos paquetes sea menor que la última publicada, o incluso que algunos cambien a una versión *más antigua* que la que se estaba usando hasta el momento. Esto ocurre porque las dependencias de los paquetes también pueden definir las versiones compatibles, y el gestor de paquetes realiza las actualizaciones imponiendo la condición de que se cumplan todas las relaciones de compatibilidad.

También en el momento de añadir paquetes nuevos se revisan las compatibilidades, y además de instalarse las dependencias necesarias, aquellas que ya estaban instaladas se actualizan a las últimas versiones compatibles. En la mayoría de casos se actualizan a versiones más nuevas, pero algunos también pueden cambiar a una versión inferior.

Si algún paquete se quiere dejar fijo en una versión determinada, y que no se vea afectado por llamadas a `]update` posteriores, se puede utilizar el comando `]pin`. Las dos instrucciones siguientes fijan el paquete `Plots` a la versión instalada en ese momento o a la versión 1.0.0, respectivamente:

```julia-repl
pkg> pin Plots
pkg> pin Plots@1.0.0
```

Si se quiere, se puede especificar un rango de versiones más amplio. Por ejemplo, `@1` permitiría actualizar el paquete, haciéndolo variar entre cualquiera de las versiones que tengan el patrón `1.X.Y` (1.0.5, 1.1.1, etc.); `@1.0` permitiría todas las versiones del tipo `1.0.Y`, y así sucesivamente. Los límites inferior y superior también se pueden fijar con dos números separados por un guión. Por ejemplo, para cualquier versión entre 1.0.0 y 1.1.1, incluyendo ambas:

```julia-repl
pkg> pin Plots@1.0-1.1.1
```

La versión del paquete se puede fijar en el mismo momento de su instalación, cualificando el nombre del paquete con el número de versión al usar el comando `]add`, exactamente del mismo modo que se hace con `]pin`. Para revertir el efecto de `]pin` o de la versión fijada con `]add`, si se ha especificado, se puede utilizar el comando `]free`:

```julia-repl
pkg> free Plots
```

Esto hará que el paquete se libere de las restricciones fijadas a mano, aunque la máxima versión a la que se pueda actualizar seguirá estando condicionada por las compatibilidades que establezcan los otros paquetes instalados.

## Trabajar por proyectos

Cualquier usuario puede reconocerse en esta situación: tienes un archivo creado con un programa antiguo, e intentas abrirlo con la última versión del mismo. Entonces observas con consternación que el contenido ya no se ve como cuando se creó originalmente; o peor, que la nueva versión del programa ni siquiera permite abrir el archivo.

Lo mismo puede ocurrir con las versiones de los paquetes de Julia: las actualizaciones introducen mejoras y arreglan fallos de las versiones anteriores, pero también pueden introducir cambios en los resultados de un estudio, o incluso crear incompatibilidades que impidan ejecutar el programa que se escribió originalmente.

Para resolver este conflicto, Julia permite trabajar por proyectos con entornos de paquetes aislados y estables, aunque el conjunto de paquetes instalados en el sistema se amplíe y actualice libremente.

Cuando se añade un paquete nuevo, o cuando se actualizan los existentes, en realidad se instalan todas sus versiones disponibles. La versión particular que aparece reflejada cuando se llama a `]status`, y la que se carga en la sesión de trabajo cuando se llama a `using`, viene determinada por la configuración del "entorno", que se puede cambiar de forma muy sencilla.

Asignar un entorno particular a un proyecto se reduce a seleccionar una carpeta para ese proyecto. Normalmente será la carpeta que recoge toda la información del proyecto, pero puede ser cualquiera, y la única restricción es que no puede ser compartida por otro proyecto de Julia.

Lo primero que hay que hacer es, en una sesión de Julia, activar la carpeta escogida como un nuevo entorno de trabajo, con el comando `]activate` seguido de la ruta de la carpeta. Si esta coincide con el directorio de trabajo actual, basta con escribir `]activate .` (un punto representa el directorio actual). La etiqueta mostrada en la consola cambiará para mostrar el nombre del nuevo entorno. Por ejemplo, si la carpeta escogida tuviese la ruta `proyectos_julia/estudio1`:

```julia-repl
pkg (@v1.5)> activate proyectos_julia/estudio1

pkg (estudio1)>
```

Si se quiere volver al entorno por defecto, basta con ejecutar `]activate` sin ningúna ruta a continuación.

Cuando se activa un entorno por primera vez, este está "limpio" de paquetes, como si se estuviese trabajando con una instalación nueva de Julia. Para trabajar con cualquier paquete externo hay que añadirlo de la forma habitual, con `]add`, etc. La instalación de paquetes en un entorno nuevo no duplica los archivos descargados o instalados en el sistema; únicamente edita dos archivos de texto en el directorio del entorno:

* `Project.toml`. Este archivo contiene la lista de paquetes que se han añadido explicitamente al entorno, es decir los que se podrán cargar con el comando `using` mientras se esté trabajando en ese entorno.
* `Manifest.tom`. Contiene una lista completa de todos los paquetes necesarios para trabajar en el entorno, incluyendo los listados en `Project.toml` y todas sus dependencias directas e indirectas. Además, para cada paquete señala su lista de dependencias directas y la versión que se cargará en el entorno.

De este modo, cada proyecto puede tener definida su propia configuración de paquetes, y mantenerla fijada cuando se cierre el proyecto, sin renunciar a tener otros entornos con versiones más actualizadas. Al estar todas las versiones recogidas en el archivo `Manifest.toml`, siempre que se vuelva a activar esa carpeta del proyecto el gestor de paquetes utilizará las mismas versiones, aunque en otros proyectos se hayan cambiado. (Naturalmente, esto es así mientras no se hagan actualizaciones en el entorno en cuestión.) 

Incluso en otro ordenador, con una instalación de Julia aparte, se puede reproducir el conjunto de paquetes y sus versiones asociadas a un proyecto, si se mantienen los archivos `Project.toml` y `Manifest.toml`. En el nuevo ordenador únicamente haría falta ejecutar --una vez activado el entorno del proyecto-- el comando `]instantiate`, para descargar e instalar en el sistema los paquetes indicados en el *manifest*. Si la versión de Julia es la misma, los proyectos funcionarán igualmente en ambos ordenadores (salvo por diferencias que pudiera haber en utilidades del sistema operativo, al margen de los componentes de Julia). Si la versión de Julia ha cambiado, podría haber incompatibilidades con los paquetes o diferencias en el funcionamiento del programa. Para controlar incluso este detalle, se puede añadir a `Project.toml` una indicación sobre la versión de Julia a emplear, con las siguientes líneas:

```toml
[compat]
julia = "1"
```

(En este ejemplo se indica que se ha de usar la versión 1 de Julia. Puede indicarse una versión más específica --p.ej. `julia="1.5"`, o incluso distintas versiones separadas por comas.)

Es muy recomendable trabajar siempre de este modo, con un entorno distinto para cada proyecto, en parte porque hace que el trabajo sea reproducible a largo plazo, tal como se ha dicho. Pero además, si cada proyecto tiene en su entorno con solo los paquetes que necesita, se evitan los entornos con un número excesivo de paquetes, que son una causa frecuente de incompatibilidades entre versiones.

El entorno por defecto, que se activa al inicio de cada sesión de Julia, tiende a ser un terreno de pruebas, en el que se van acumulando los distintos paquetes que se instalan, a veces antes de decidir su uso definitivo en los proyectos en curso. Esta práctica hace proliferar incompatibilidades, por lo que algunos paquetes en el entorno por defecto se quedan bloqueados en versiones antiguas, y otros no se pueden añadir. Así pues, es preferible mantener razonablemente limpio el entorno por defecto, y tener algún directorio reservado para las pruebas, que llegado el caso de problemas se puede "resetear" borrando los archivos `Project.toml` y `Manifest.toml`.

!!! note "Entornos en VS Code"

    Si se trabaja en VS Code con la extensión de Julia, y la carpeta del proyecto activo contiene un archivo `Project.toml`, el entorno por defecto se convierte automáticamente en esa carpeta de proyecto, lo que facilita trabajar del modo recomendado.

!!! warning "Problema de alternar entre entornos"

    Hay que diferenciar entre las versiones de los paquetes recogidas en el *manifest* de un proyecto y las cargadas en una sesión de trabajo de Julia. Si durante la sesión solo se ha ejecutado el comando `using` dentro de un mismo entorno, las versiones serán las indicadas en él. Pero una vez se ha cargado un paquete, la versión usada será la misma aunque luego se pase a otro entorno que especifica otra versión. Ejecutar otra vez `using` no cargará una versión distinta. Esto aplica tanto a los paquetes señalados en `Project.toml` como a las dependencias recogidas en `Manifest.toml`. Al cambiar de entorno podrían surgir incompatibilidades, por lo que para trabajar en varios proyectos es mejor salir de la sesión de Julia y volver a entrar entre uno y otro. 


## Cargar paquetes al inicio

Por defecto Julia se inicia en un estado "limpio", en el que no se ha cargado nada más que el módulo básico. Pero salvo en el caso de las rutinas más elementales, casi siempre es necesario recurrir a las utilidades proporcionadas por otros módulos o paquetes. Por eso, si su uso es rutinario, resulta cómodo configurar el sistema para que se carguen automáticamente al iniciar la sesión.

Esto es tan sencillo como añadir una o varias líneas con la instrucciones correspondientes en un archivo llamado `startup.jl`, guardado en uno de estos dos lugares:

* El directorio `config` dentro del "depósito" local de Julia --normalmente un directorio llamado `.julia` en la ruta donde se encuentra el perfil del usuario del ordenador--. Si en una sesión de Julia se escribe `DEPOT_PATH`, se presentará una lista de directorios, el primero de los cuales suele ser este depósito. Así pues, la ruta exacta del archivo a editar normalmente se podrá obtener como `joinpath(DEPOT_PATH[1], "config", "startup.jl")`.
* El directorio de configuración global de Julia, cuya ruta se puede obtener como `joinpath(Sys.BINDIR, Base.SYSCONFDIR)`.

Cualquiera de los dos sitios son válidos para guardar el archivo `startup.jl`, solo que en el primer caso se guardará una configuración específica para el usuario, y en el segundo será una configuración global para todos los usuarios. Dependiendo de cómo se haya instalado Julia, un usuario que no sea administrador podría tener solo acceso a la configuración local.

El archivo `startup.jl` es un *script* de Julia como cualquier otro, con la peculiaridad de que se ejecuta automáticamente al inicio de cada sesión de trabajo. Si por ejemplo un usuario quiere tener siempre disponibles las funciones básicas de estadística (medias, desviación tipica...) y de álgebra lineal (norma de vectores, productos escalares y vectoriales, descomposiciones de matrices...), sin tener que cargar los módulos correspondientes cada vez, puede incluir las siguientes líneas en su `startup.jl`:

```julia
using Statistics
using LinearAlgebra
```

O en una sola línea:

```julia
using Statistics, LinearAlgebra
```

En general solo conviene hacer esto con módulos de la biblioteca estándar. Salvo en contadas excepciones, es mejor no cargar paquetes externos al inicio, aunque se usen con mucha frecuencia, porque esto hará que se carguen las versiones presentes en el entorno por defecto. Si luego se cambia a un entorno que use otra versión de los mismos paquetes (incluso si es una dependencia indirecta), podrían darse conflictos entre versiones, u obtenerse resultados distintos a la hora de ejecutar los programas.

## Conflictos con nombres de funciones

Al cargar un módulo estándar o un paquete con el comando `using`, los nombres de las funciones y otros objetos "exportados" pasan a ser utilizables directamente, como ocurre con `readdlm` al cargar `DelimitedFiles`, `plot` de `Plots`, etc. Por otro lado, los paquetes generalmente contienen muchas otras funciones y objetos que no se exportan; la mayoría suelen ser elementos "internos", es decir, que no están pensados para que el usuario que carga el paquete los use habitualmente, pero no siempre es así. Por ejemplo, la función `File` del paquete `CSV` no está exportada, y por eso para leer archivos con ese paquete hay que llamarla como `CSV.File`.

Esto es conveniente en el caso de funciones cuyo nombre sea muy genérico, de tal manera que puedan entrar en conflicto con funciones distintas de otros paquetes.[^2] Si por ejemplo en la misma sesión se carga el paquete `Plots` y también `PyPlot`, al usar la función `plot` ocurre esto:

```julia-repl
julia> using Plots, PyPlot

julia> plots(x, y)
WARNING: both Plots and PyPlot export "plot"; uses of it in module Main must be qualified
ERROR: UndefVarError: plot not defined
```

[^2]: Algunos paquetes pueden *extender* funciones de otros paquetes o módulos, añadiendo nuevos métodos. Ese tipo de extensiones no producen ese tipo de conflictos.

Para evitar este error, en lugar de `plot` habría que usar `Plots.plot` o `PyPlot.plot`, según lo que se desee.

En lugar de `using` también se puede usar el comando `import`. Esto carga el paquete del mismo modo que lo haría `using`, pero todas las funciones definidas en él han de usarse cualificándolas con el nombre del paquete.

## Sumario del capítulo

En este capítulo hemos visto las utilidades básicas relacionadas con la gestión de paquetes:

* Cómo buscar, añadir, eliminar, actualizar y fijar versiones de paquetes para ampliar las funcionalidades de Julia.
* El uso de entornos para trabajar con proyectos reproducibles y prevenir problemas de incompatibilidades entre versiones de los paquetes.
* Las diferencias entre `using` e `import` como dos formas de cargar los módulos de la biblioteca estándar y otros paquetes.
* El uso del archivo de configuración `startup.jl` para cargar módulos y ejecutar otras acciones al inicio de cada sesión. 
