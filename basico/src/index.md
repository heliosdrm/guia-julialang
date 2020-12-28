```@raw html
<h1 style="text-align:center"><span style="font-size:larger; font-weight:bolder">Programación básica con Julia</span></h1>
<br />
```

# Introducción

Los lenguajes de programación son una herramienta esencial en muchas profesiones científicas, en las que a menudo se presentan problemas que implican cálculos complejos. Cálculos que además suponen un planteamiento nuevo en cada ocasión, y cuya resolución hay que programar, aunque normalmente existan trabajos previos en los que basarse, a falta de ciertos retoques o extensiones.

Entre la infinidad de lenguajes de programación existentes, los que permiten un uso dinámico e interactivo son especialmente útiles para desarrollar programas de forma ágil, probando, descartando y ajustando soluciones de forma continua. También es importante que el lenguaje facilite reusar código escrito anteriormente, quizá incluso por otras personas, para problemas anteriores. Y al mismo tiempo, según avanza la tecnología y la capacidad de registrar y manejar información, es necesario que los programas sean más eficientes, para poder llevar a cabo cálculos más complejos y con bases de datos más voluminosas.

Ese es, precisamente, el propósito de [*Julia*](https://julialang.org), un lenguaje de programación dinámico de alto nivel, creado por investigadores informáticos del Massachusets Institute of Technology (MIT), y distribuido bajo la licencia del MIT para software libre. Julia se usa para cálculos en múltiples ámbitos como la física, biología, ingeniería, matemáticas y finanzas, entre otros. Se trata de un lenguaje fácil de extender y componer, con un "ecosistema" de paquetes muy versátil e igualmente extensible, que se puede adaptar rápidamente a nuevos usos y aplicaciones. Además, uno de sus puntos fuertes es la resolución de problemas numéricos complejos y con grandes cantidades de datos, que otros lenguajes de su misma categoría no pueden abordar de forma eficiente, salvo que se combinen con código compilado en un segundo lenguaje (típicamente en C o C++).

Julia es un lenguaje ideal para trabajar con múltiples niveles de complejidad, abstracción y optimización de código. Dispone de una consola de comandos --también conocida como *read-eval-print loop* o [REPL](https://es.wikipedia.org/wiki/REPL)-- y una interfaz sencilla para ejecutar *scripts*, lo que permite hacer operaciones básicas de forma dinámica, usando un código muy simple, rápido de escribir e interpretar. Yendo al otro extremo, la sintaxis del lenguaje también proporciona utilidades para escribir programas altamente optimizados, en el que todo el código se compile alcanzando el más alto rendimiento --incluso tan rápidos como si hubieran sido escritos en C--. El aspecto de los programas hechos de un modo y del otro puede llegar a ser muy disitinto, pero en ambos se trata del mismo lenguaje, usado de distinta manera. Una vez aprendidas las reglas básicas para hacer los programas más sencillos en Julia, llegar a niveles de complejidad más altos y hacer programas más eficientes es principalmente una cuestión de práctica.

## Objetivo y estructura de esta guía

Por lo dicho arriba resulta razonable usar Julia como lenguaje para introducirse en el mundo de la programación, ya que permite un inicio "amable", con resultados útiles sin excesivo esfuerzo, y a la vez facilita el aprendizaje conceptos más avanzados de programación, en una progresión suave y continua. Partiendo de ese principio, esta guía se presenta como una introducción a la programación con Julia, que no asume conocimientos previos sobre este u otros lenguajes de programación en particular.

Hay múltiples formas de plantear una guía o tutorial para aprender a utilizar un lenguaje de programación desde cero. A menudo se comienza con ejercicios triviales como el de escribir `"Hola mundo"` en pantalla, para introducir poco a poco los conceptos y así suavizar la barrera de entrada al mundo de la programación, a expensas de resultar un inicio lento y poco estimulante. En esta guía se opta por un primer encuentro con el lenguaje basado en ejemplos algo más prácticos, que no es necesario entender al detalle desde el principio, pero que contienen buena parte de los conceptos que se quieren explicar.

Con esa estructura se plantean los cuatro primeros capítulos, dedicados a introducir el [flujo de trabajo habitual con Julia](1-primerospasos.md), el [manejo de series y tablas de datos](2-series-tablas.md), las [funciones y estructuras de control](3-funciones-control.md) de los programas, y el [uso de gráficos](4-graficos.md), respectivamente. Con los contenidos de esos cuatro primeros capítulos se cubre la base necesaria para hacer un uso productivo de Julia, aunque los temas se tratan de forma muy superficial, pensando más en introducir los conceptos --incluso para alguien que tenga poca o ninguna experiencia práctica en programación-- que en una descripción completa de los temas tratados.

Los cinco siguientes capítulos vuelven sobre algunos de los temas anteriores para tratarlos con más profundidad. En particular, se proporcionan detalles sobre cómo crear, manipular y usar [*arrays*](5-arrays.md) y otros [tipos de objetos iterables](6-iterables.md), así como [cadenas de texto](7-strings.md), [funciones](8-funciones-avanzado.md), y cómo [gestionar los paquetes](9-pkg.md) que amplían la funcionalidad básica de Julia, convirtiéndolo así en un lenguaje de programación útil y eficaz en muchos dominios.

Para finalizar, el último capítulo presenta estrategias y herramientas para [detectar y depurar errores](10-debugging.md) en los programas, uno de los desafíos más importantes tanto para principiantes como para las personas con más experiencia programando. 

Las herramientas presentadas en esta guía son la base para hacer cualquier programa en Julia, aunque solo abarcan una parte de todo lo que proporciona este lenguaje de programación. Otros recursos para extraer el máximo rendimiento de Julia se reservan para una guía más avanzada, que pretende seguir a la presente.

## Créditos y licencia

Esta guía está elaborada por Helios De Rosario Martínez con el paquete [Documenter](https://github.com/JuliaDocs/Documenter.jl) de Julia, a partir del código publicado en el repositorio [https://github.com/heliosdrm/guia-julialang/](https://github.com/heliosdrm/guia-julialang/).

Esta guía está publicada bajo la licencia [Creative Commons Attribution-ShareAlike (CC BY-SA) 4.0](http://creativecommons.org/licenses/by-sa/4.0/). Esto significa que se permite su libre distribución y transformación, incluso con propósitos comerciales, en cualquier medio y formato, siempre que en las copias u obras derivadas se acredite apropiadamente la autoría original y se mantengan los términos de esta licencia.

```@raw html
<img src="assets/cc-by-sa-88x31.png" alt="CC-BY-SA">
```
