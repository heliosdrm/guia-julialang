using Documenter

makedocs(sitename="Claves para programar en Julia",
    pages = [
        "index.md",
        "1-multiple-dispatch.md",
        "2-proyectos.md",
        "3-tipos-intro.md",
        "4-modulos-paquetes.md",
        "5-tipos-ext.md",
        "6-paquetes-desarrollo.md",
        "7-contextos.md",
        "8-metaprogramacion.md",
        "9-benchmark.md",
        "10-optimizacion.md"
    ],
    expandfirst = ["index.md"]
)
