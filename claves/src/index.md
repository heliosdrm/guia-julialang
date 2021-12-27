```@raw html
<h1 style="text-align:center"><span style="font-size:larger; font-weight:bolder">Claves para programar en Julia</span></h1>
<br />
```

# Introducción

Esta guía es una continuación de [Programación básica con Julia](https://hedero.webs.upv.es/julia-basico), en la que se presentan algunas herramientas de [Julia](https://julialang.org) que son claves para sacar partido a este potente lenguaje de programación. Los conceptos que se introducen marcan la diferencia entre Julia y otros lenguajes, y dominarlos supone un salto cualitativo en la productividad que se puede alcanzar a la hora de escribir programas.

No he llamado a esta guía "Programación avanzada en con Julia", que podría haber sido un título natural para una continuación de la anterior, porque parte de lo que se explica aquí está bastante por detrás de lo que muchos considerarían un uso avanzado de ese lenguaje. En particular, conceptos como los proyectos, los tipos compuestos de variables, los módulos y el desarrollo de paquetes, que son el tema principal de los primeros siete capítulos, pueden considerarse elementos esenciales de Julia. No son el tipo de cosas que uno suele usar en sus primeros ejercicios, pero una vez se ha "roto mano" con el lenguaje vale mucho la pena aprenderlas; y para alguien que haya asimilado los contenidos de la "guía básica", no debería haber más barrera para manejar esos nuevos conceptos que el tiempo disponible y las ganas de explorar el lenguaje.

Los capítulos siguientes entran en materias que sí merecen en justicia el calificativo "avanzadas": utilidades de metaprogramación, macros, y algunas técnicas para acelerar los programas, incluyendo la ejecución de tareas en paralelo. La conveniencia de aprender esos conceptos ya depende de la ambición de cada uno. Es posible hacer muchísimas cosas en Julia sin emplear ninguna de esas herramientas y trucos, que además requieren de cierta habilidad y disciplina para usarse correctamente. Ahora bien, son recursos realmente útiles, que permiten hacer programas claros, robustos y muy eficaces.


## Requisitos previos

Además de tiempo y ganas de explorar las posibilidades que ofrece Julia, para seguir esta guía también hace falta conocer, al menos a nivel superficial, la sintaxis y algunos conceptos elementales de este lenguaje de programación. Los contenidos de [Programación básica con Julia](https://hedero.webs.upv.es/julia-basico) son un punto de partida apropiado; pero se puede empezar con la presente guía incluso sin dominar todos los de aquella. Algunos de los puntos más importantes se repiten aquí, y donde resulta pertinente se dan enlaces a los capítulos de la guía anterior que conviene consultar.

Naturalmente, también necesitarás disponer de un ordenador en el que experimentar escribiendo y ejecutando programas en Julia. Por simplicidad, los ejemplos se muestran como si la interfaz para interactuar con Julia fuese el REPL (la consola de comandos habitual de Julia), pero la inmensa mayoría de conceptos tratados y ejemplos ilustrativos se pueden emplear a través de *notebooks* o alguno de los múltiples IDEs existentes. Esta guía está elaborada para la versión 1 de Julia, si bien en algunas partes se consideran características que solo existen a partir de la versión 1.5, por lo que se recomienda utilizar versiones posteriores a la misma. (En particular, el *multi-threading* solo es estable a partir de Julia 1.5, aunque también se puede emplear de forma experimental en las versiones anteriores.)

Para mayor comodidad también es muy recomendable usar Julia con el paquete [Revise](https://timholy.github.io/Revise.jl/stable/), gracias al cual los cambios que hagas en el código que se ha cargado en una sesión se pueden aplicar automáticamente, sin tener que recargarlo. De hecho es útil hasta tener el sistema configurado para que Revise [se cargue de forma automática](https://hedero.webs.upv.es/julia-basico/9-pkg/#Cargar-paquetes-al-inicio) al comienzo de las sesiones de trabajo --algo que en general no se recomienda para cualquier paquete--.

## Sobre Git y GitHub

En algunos capítulos se hacen menciones ocasionales a "repositorios git" o páginas de GitHub, que pueden resultar algo crípticas para aquellos que no conozcan de antemano de qué se está hablando. Una rápida búsqueda en Internet es suficiente para resolver ese problema, pero a modo de aclaración, muy sucintamente, se puede decir que son unas herramientas empleadas para controlar el historial de versiones de proyectos de software, que en sí mismas no tienen nada que ver con Julia, pero sí mucho con cómo se gestiona su desarrollo.

Concretamente, [Git](https://git-scm.com/) es un programa que permite convertir cualquier directorio de un sistema de ficheros en un "repositorio", registrar un historial de versiones de todo su contenido e interactuar de múltiples maneras con ese historial --por ejemplo retrocediendo a una versión anterior, mezclando versiones, etc.--, además de sincronizarlo con otros directorios en el mismo ordenador, en uno distinto, o en "la nube". Por su parte, [GitHub](https://github.com) es una plataforma de desarrollo colaborativo, que como indica su nombre se basa en Git.

Naturalmente, en el desarrollo de software es fundamental tener un control preciso de los cambios en el código y las versiones de los programas, y Julia se apoya en Git para ello. Además, tanto el núcleo del lenguaje como muchos paquetes de terceros emplean GitHub como entorno público de desarrollo. Son herramientas extraordinariamente útiles, muy recomendables para poner orden y control en los desarrollos, sean de Julia o cualquier otro lenguaje. Pero considero que entrar en detalles sobre ellas sería una distracción del propósito principal, y aumentaría demasiado la complejidad de esta guía. Por eso, aunque son un recurso muy usado por programadores de Julia y al tratar algunos conceptos sobre este lenguaje es inevitable tener que hacer alguna referencia a esas herramientas, se ha intentado hacerlo en la mínima medida posible, y sin dar mayores explicaciones al respecto. Cuando es necesario, se dan algunas instrucciones sencillas para interactuar con los repositorios, que no requieren instalar ningún programa ni ningún conocimiento especial.

## Créditos y licencia

Esta guía está elaborada por Helios De Rosario Martínez con el paquete [Documenter](https://github.com/JuliaDocs/Documenter.jl) de Julia, a partir del código publicado en el repositorio [https://github.com/heliosdrm/guia-julialang/](https://github.com/heliosdrm/guia-julialang/).

Esta guía está publicada bajo la licencia [Creative Commons Attribution-ShareAlike (CC BY-SA) 4.0](http://creativecommons.org/licenses/by-sa/4.0/). Esto significa que se permite su libre distribución y transformación, incluso con propósitos comerciales, en cualquier medio y formato, siempre que en las copias u obras derivadas se acredite apropiadamente la autoría original y se mantengan los términos de esta licencia.

```@raw html
<img src="assets/cc-by-sa-88x31.png" alt="CC-BY-SA">
```

