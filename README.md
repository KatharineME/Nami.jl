🌊

[Install `julia`](https://julialang.org/downloads).

```bash
git clone https://github.com/KatharineME/Nami.jl
```

```bash
cd Nami.jl
```

```bash
julia --project
```

```julia
using Pkg; Pkg.instantiate()
```

```julia
using GenieFramework; Genie.loadapp(); up()
```

Open http://127.0.0.1:8000.

Upload `Nami.jl/data/thin.1M.vcf.gz`.

Wait a moment for the variant database to build.

Search the suggested variant `625655` or gene `UBR3` and any region larger than one million bases to get hits.

---

Made by [Kata](https://github.com/KwatMDPhD/Kata.jl) 🥋
