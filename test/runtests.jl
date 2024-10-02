using Nami

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using GenieFramework

# ---- #

const RE = true

# ---- #

const PA = joinpath(tempdir(), "vcf.db")

if RE && isfile(PA)

    rm(PA)

end

const DB = VCF.DB(PA)

# ---- #

if RE

    VCF.make_variant_table!(DB, pkgdir(VCF, "data", "thin.10000.vcf.gz"))

end

# ---- #

VCF.get_variant(DB, 11489793)

# ---- #

VCF.get_variant(DB, "FAM138A")

# ---- #

VCF.get_variant(DB, 1, 0, 24000)

# ---- #

VCF.count_impact(VCF.get_variant(DB, 1, 0, 24000))

# ---- #

const NA = VCF.DB(joinpath(dirname(pkgdir(VCF)), "Nami.jl", "public", "upload", "vcf.db"))

VCF.get_variant(NA, 11489793)

VCF.get_variant(NA, 1)

VCF.get_variant(NA, "OR4G4P")

VCF.get_variant(NA, 1, 0, 80000)

VCF.get_variant(NA, 7, 0, 100000)

VCF.get_variant(NA, "MT", 0, 100000)

VCF.count_impact(VCF.get_variant(NA, 1, 0, 80000))
