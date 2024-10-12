using Nami

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using GenieFramework

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

if RE

    Nami.make_variant_table!(DA, joinpath(@__DIR__, "data", "thin.10000000.vcf.gz"))

end

columns(DA, "variant")

# ---- #

Nami.get_variant(DA, 10916692)

# ---- #

Nami.get_variant(NA, 1)

# ---- #

Nami.get_variant(DA, "ASB5")

# ---- #

Nami.get_variant(DA, 1, 0, 24000000)

# ---- #

Nami.get_variant(NA, "MT", 0, 100000)

# ---- #

Nami.count_impact(Nami.get_variant(DA, 1, 0, 2400000))

# ---- #
