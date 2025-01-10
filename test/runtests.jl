using Nami

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using SQLite: columns

# ---- #

const RE = true

# ---- #

const NA = "variant"

const PA = joinpath(tempdir(), "$NA.db")

if RE && isfile(PA)

    rm(PA)

end

const DA = Nami.DB(PA)

# ---- #

@btime if $RE

    Nami.make_variant_table!($DA, joinpath(@__DIR__, "data", "thin.1M.vcf.gz"))

end
#  144.643 ms (27998 allocations: 2.37 MiB) 
# variant.db = 32K

columns(DA, NA)

# ---- #

@time if RE

    Nami.make_variant_table!(DA, joinpath(@__DIR__, "data", "735.vcf.gz"))

end

# 2838.857915 seconds (369.75 M allocations: 29.158 GiB, 0.20% gc time, 0.00% compilation time) 
# variant.db = 337M
# variant.db.gz = 82M

columns(DA, NA)

# ---- #

Nami.get_variant_by_id(DA, "rs10916692")

# ---- #

Nami.get_variant(DA, "UBR3")

# ---- #

Nami.get_variant(DA, 1, 0, 24000000)

# ---- #

Nami.get_variant(DA, "MT", 0, 100000)

# ---- #

Nami.count_impact(Nami.get_variant(DA, 1, 0, 2400000))
