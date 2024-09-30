using Nami

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using GenieFramework

using VCF

# ---- #

const PA = pkgdir(Nami, "public", "nami.db")

const DB = VCF.DB(PA)

# ---- #

VCF.get_variant(DB, 11489793)

# ---- #

VCF.get_variant(DB, "FAM138A")

# ---- #

VCF.get_variant(DB, 1, 0, 24000)

# ---- #

VCF.count_impact(VCF.get_variant(DB, 1, 0, 24000))
