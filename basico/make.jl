using Documenter

makedocs(sitename="Programación básica con Julia",
    pages = [
        "index.md",
        "1-primerospasos.md",
        "2-series-tablas.md",
        "3-funciones-control.md",
        "4-graficos.md",
        "5-arrays.md",
        "6-iterables.md",
        "7-strings.md",
        "8-funciones-avanzado.md",
        "9-pkg.md",
        "10-debugging.md"
    ],
    expandfirst = ["index.md"]
)
