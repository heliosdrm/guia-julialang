using Documenter

makedocs(sitename="Guía de Julia",
    pages = [
        "introduccion.md",
        "primerospasos.md",
        "datos.md",
    ],
    expandfirst = ["introduccion.md"]
)
