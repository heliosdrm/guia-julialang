using Documenter

makedocs(sitename="Guía de Julia",
    pages = [
        "introduccion.md",
        "primerospasos.md",
        "series-tablas.md",
        "funciones-control.md",
        "graficos.md",
        "arrays.md",
        "iterables.md",
        "strings.md"
    ],
    expandfirst = ["introduccion.md"]
)
