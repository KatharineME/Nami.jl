using Nami

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using SQLite: columns

# ---- #

const RE = true

# ---- #

const PA = joinpath(tempdir(), "vcf.db")

if RE && isfile(PA)

    rm(PA)

end

const DA = Nami.DB(PA)

# ---- #

@btime if $RE

    Nami.make_variant_table!($DA, joinpath(@__DIR__, "data", "thin.1M.vcf.gz"))

end

# 147.235 ms (23969 allocations: 2.21 MiB) 
# vcf.db = 32K

columns(DA, "variant")

# ---- #

@time if RE

    Nami.make_variant_table!(DA, joinpath(@__DIR__, "data", "full.vcf.gz"))

end

# 2173.816849 seconds (292.56 M allocations: 25.604 GiB, 0.16% gc time, 0.00% compilation time)
# vcf.db = 316M
# vcf.db.gz = 79M

columns(DA, "variant")

# ---- #

re = Nami.get_variant(DA, 10916692)

# ---- #

re = Nami.get_variant(DA, "UBR3")

# ---- #

re = Nami.get_variant(DA, 1, 0, 24000000)

# ---- #

re = Nami.get_variant(DA, "MT", 0, 100000)

# ---- #

Nami.count_impact(Nami.get_variant(DA, 1, 0, 2400000))
