# Capítulo 4. Módulos y paquetes

```@setup c4
using Fracciones
```

## Módulos

En el capítulo anterior hemos visto cómo crear nuevos tipos compuestos, que sirven para organizar los datos de una forma práctica, adecuada para los problemas a resolver. La definición de los tipos suele ir acompañada de constructores que faciliten su creación, ya comentados, y métodos particulares para los mismos, que veremos en el siguiente capítulo; y cuando tenemos un conjunto de utilidades relacionadas como esas, puede ser interesante agruparlas en un módulo particular, para tener el código mejor estructurado.

Los módulos en Julia son conjuntos de objetos (tipos de variables, datos, funciones...) que se agrupan bajo un nombre común, separándolos del resto del código. En el paquete que estamos usando de ejemplo en esta guía, el archivo `src/Fracciones.jl` define un módulo para todo el código de `src/fraccion.jl` que empezamos a ver en el capítulo anterior, del siguiente modo:

```julia
module Fracciones
export Fraccion, numerador, denominador, fraccion, reciproco, @fraccion
include("fraccion.jl")
end # module
```

Dejando de lado la línea que comienza con `export`, de la que hablaremos más adelante, la definición de un módulo es extremadamente sencilla: se reduce a poner todo el código que se quiera agrupar entre `module NombreDelModulo ... end`. El código recogido por el módulo puede escribirse directamente o se puede incluir desde un archivo con `include`, como en el ejemplo; y es habitual escribirlo sin indentar el comienzo de las líneas, aunque eso es un detalle estético sin mayor relevancia. Como ocurre con los tipos, existe la convención de escribir los nombres de los módulos en *camel case*. Y si los objetos contenidos tienen principalmente que ver con la definición de un nuevo tipo, el nombre que se suele dar al módulo es el del tipo en plural (en nuestro caso `Fracciones`).


!!!note "El módulo `Main`"
    
    Todos los objetos de una sesión de Julia están en algún módulo. En todas las sesiones de Julia se genera automáticamente un módulo llamado `Main` en el que se alojan todos los objetos del espacio de trabajo, los que se crean sin asignarlos específicamente a otro módulo en particular. 

Cuando algo se define dentro de un módulo, en principio solo se puede acceder a ello a través del módulo mismo. Por ejemplo, cuando cargamos el archivo `src/Fracciones.jl`, indirectamente cargamos también el código de `src/fraccion.jl` donde teníamos definido el tipo `Fraccion` y varias cosas más, pero todo eso ahora forma parte del módulo `Fracciones`:

```julia
julia> include("src/Fracciones.jl")
Main.Fracciones

julia> Fraccion(3,4)  # No se puede acceder de forma directa
ERROR: UndefVarError: Fraccion not defined
Stacktrace:
 [1] top-level scope at REPL[3]:1

julia> Fracciones.Fraccion(3,4) # Así sí
Fraccion(3, 4)
```

La primera impresión puede ser que tener que añadir el nombre del módulo como prefijo aporta más molestias que otra cosa; pero es una forma de poner orden en el espacio de trabajo, lo que resulta especialmente beneficioso en cuanto la cantidad de objetos contenidos en el módulo empieza a crecer. Un claro beneficio es que no hace falta preocuparse por la repetición de nombres. Los módulos forman contextos con espacios de nombres aislados, por lo que se pueden definir variables y funciones con los mismos nombres que los de otros paquetes, o incluso del módulo `Base`, sin que se dé ningún conflicto. (Encontrarás más detalles sobre este tema en el [capítulo 7 sobre contextos de variables](7-contextos.md).)

Por otro lado, el inconveniente de tener que prefijar el nombre del módulo puede reducirse en el caso de nombres largos usando un alias (p.ej. `F = Fracciones`, tras lo cual se puede escribir `F.Fracciones`, etc.). E incluso hay recursos para no tener que escribir el nombre del módulo en absoluto, que comentaremos después.

Además, durante el desarrollo de nuevos tipos, encapsular su definición en módulos nos proporciona una interesante ventaja. ¿Recuerdas que en el capítulo anterior se decía que no es posible redefinir un tipo en una sesión de trabajo? Pues bien, como los módulos forman contextos de objetos separados, lo que sí se puede hacer es definir distintas versiones de un tipo, aunque compartan el nombre, en módulos distintos. Así que una forma de saltarse esa restricción es reemplazar el módulo en el que se definió la primera versión del tipo por otro módulo con el tipo modificado. Veamos un ejemplo:

```@repl c4
module Mod
struct MiTipo
    x::Int
end
end
x1 = Mod.MiTipo(1)
module Mod # Cambiamos el módulo
struct MiTipo
    a::Int
    b::Int
end
end
x2 = Mod.MiTipo(1,2)
```

Al definir por segunda vez el módulo `Mod`, hemos sustituido el módulo anterior por otro con el mismo nombre, lo que es algo anómalo que se nos avisa con un *warning*, pero aun así funciona. El problema es que al hacer esto, la variable `x1` que hemos creado con la primera definición de `MiTipo` no es del mismo tipo que `x2`, aunque se llamen igual, lo que resulta algo confuso:

```@repl c4
typeof(x1)
typeof(x2)
typeof(x1) == typeof(x2)
```

## Importar módulos y sus objetos

En el [capítulo 1](1-proyectos.md) vimos que cuando teníamos el paquete Fracciones como dependencia de un proyecto y lo cargábamos con `using Fracciones`, se ponía a nuestra disposición el constructor `Fraccion` y funciones varias que están definidas del módulo `Fracciones`, sin necesidad de escribir ningún prefijo. Esto es así gracias a que `using` no solo carga el contenido del módulo principal del paquete, sino que también importa los objetos que estan señalados con el comando `export` dentro del módulo.

Podemos ver la importación como una forma de compartir objetos entre módulos. En una sesión interactiva, o cuando ejecutamos un *script* en Julia, implícitamente estamos haciendo operaciones en el módulo `Main`, así que cuando hablamos de "importar los objetos de `Fracciones`", lo que significa es que se crean los objetos `Main.Fraccion`, `Main.numerador`, etc., que hacen referencia a los del módulo `Fracciones`, pero a los que podemos acceder durante la sesión de trabajo sin tener que escribir el prefijo. En lo que sigue vamos a considerar siempre que estamos trabajando en `Main`, pero igualmente podríamos estar escribiendo código dentro de un módulo `A`, en cuyo caso la importación crearía objetos en `A`, etc.

Al ejecutar `using Fracciones` importamos todos los objetos de `Fracciones` que se han señalado para exportar, pero también se puede ejercer un control personalizado sobre qué objetos se importan y cuáles no, usando el comando `import` como complemento a `using`:

* `import Fracciones` carga el paquete Fracciones (igual que `using`), pero no importa ninguno de sus objetos.
* `import Fracciones: Fraccion` importa únicamente el objeto `Fraccion`. Al señalar qué objetos específicos se importan, da igual que estén señalados con `export` dentro del módulo o no.

Las operaciones con `using` e `import` se hacen normalmente al cargar paquetes, pero también se pueden emplear con módulos que hayamos definido directamente. Por ejemplo, si no tenemos el paquete Fracciones como dependencia del proyecto, pero hemos incluido el código de `src/Fracciones.jl` como se ha señalado antes, podremos escribir `using Main.Fracciones`, lo que daría lugar al mismo resultado. También se puede escribir simplemente `using .Fracciones`, con lo que se buscará `Fracciones` en el módulo donde se haya escrito el comando, sea cual sea.[^1]

[^1]: `import .Fracciones` sería una operación sin mucho sentido, porque solo funciona si `Fracciones` está en el módulo actual, con lo que no cambia nada.

En principio, la importación de objetos no es recomendable si se espera redefinir el módulo original como se ha indicado en el apartado anterior, porque puede dar lugar a situaciones confusas. Sustituir un módulo por otro del mismo nombre no afecta a los objetos que se hayan importado del primero, y no está permitido reimportarlos:

```@repl
module Mod
export x, y
x = 1
y = 2
end
using .Mod
x
y
module Mod # Redefinimos
export y, z
y = 3
z = 4
end
using .Mod
x # Viene de la primera importación
y # No se ha podido cambiar
z # Viene de la segunda importación
```

!!!tip "Usar Revise para cambios en el código"
    
    Para resolver este tipo de problemas se puede emplear el paquete [Revise](https://timholy.github.io/Revise.jl/stable/). Si el módulo está definido en un archivo de código, y este se incluye con la función `includet` (con `t` de *track* al final), el contenido de ese archivo estará "vigilado", y los cambios que se hagan en él se aplicarán automáticamente, incluso a los objetos importados. Una excepción son los tipos compuestos, que como ya se ha comentado no se pueden redefinir, por lo que cualquier reescritura que afecte a los tipos impedirá a Revise aplicar los cambios (y se emitirá un error con la información correspondiente). 

## Desarrollo de paquetes

Llegados a este punto, pasar de un módulo definido dentro de un proyecto a un paquete que se pueda añadir como dependencia en cualquier otro proyecto solo requiere un par de cosas:

* El módulo que se quiere empaquetar ha de estar en un archivo `.jl` con el mismo nombre, dentro de una carpeta llamada `src`.
* El archivo `Project.toml` ha de incluir unas líneas al comienzo que definan:
    + El nombre del paquete (`name`)
    + Una cadena de texto que sirva de identificador único (`uuid`)
    + La versión del paquete (`version`)
    
En el paquete Fracciones vemos un ejemplo de estos datos:

```toml
name = "Fracciones"
uuid = "81451a68-6ad1-41c9-8c04-09494141aeca"
version = "0.1.0"
```

Si se ejecuta el comando `]generate Mod` en el gestor de paquetes, se generará en el directorio de trabajo actual una carpeta llamada `Mod` con la estructura y los contenidos básicos para crear un paquete, y lo único que hará falta es copiar el contenido del módulo en el archivo de código principal.

!!!tip "Plantilla de paquetes con PackageSkeleton"

    Hay paquetes como [PkgTemplates](https://invenia.github.io/PkgTemplates.jl/stable/) o [PackageSkeleton](https://github.com/tpapp/PkgSkeleton.jl), que amplían la funcionalidad de `]generate`, y permiten crear plantillas más complejas que incluyen utilidades y estructuras de archivos para controlar las versiones del paquete, crear tests, documentación, etc.

Una vez el código está en forma de paquete (como en el repositorio de Fracciones), ya se puede utilizar el comando `]add` para añadirlo como dependencia en cualquier proyecto distinto, y usarlo como un paquete más, tal como se mostró en el [capítulo 1](1-paquetes.md). Sin embargo, salvo que el código esté realmente consolidado y no se piense hacer cambios sobre el mismo, es más práctico usar el comando `]develop` --o de forma abreviada `]dev`--. La diferencia entre `]add Paquete` y `]dev Paquete` es que el primer comando instala una copia de `Paquete` en el sistema centralizado de paquetes, y cada vez que se cargue (con `using Paquete`, `import Paquete`, etc.) se empleará esa copia. Por contra, `]dev` crea una referencia al directorio donde se encuentra `Paquete`, y la versión que se carga con `using` o `import` es la que corresponde al contenido del directorio en ese momento. Si se utiliza `]dev` con una URL, en lugar de un directorio local, el contenido del repositorio se copiará a una carpeta del depósito de Julia (normalmente `.julia/dev`, en el directorio personal del usuario), y será el código de esa carpeta el que se use cada vez que se carga el paquete.

Hay que tener en cuenta que los paquetes solo se cargan una vez por sesión. La segunda vez que se usa `using` o `import` con el mismo paquete en una sesión no ocurre nada, por lo que los cambios en el código después de cargar el paquete no se aplicarán hasta la siguiente sesión.

!!!tip "Usar Revise durante el desarrollo de paquetes"
    
    Si se ha cargado el paquete Revise antes de otro paquete que esté añadido en modo `dev`, los cambios al código *sí* se aplicarán, de forma automática, durante la sesión de trabajo. De nuevo, esto exceptúa los casos en los que se modifique la definición de tipos compuestos. Como la redefinición de tipos está prohibida, si se cambia el código que define un tipo dentro de un paquete, Revise no podrá aplicar los las modificaciones que se hagan a ese paquete.
