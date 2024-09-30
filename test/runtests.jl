using Nami

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using GenieFramework

using VCF

# ---- #

const PA = pkgdir(Nami, "public", "upload", "vcf.db")

const DB = VCF.DB(PA)

# ---- #

VCF.get_variant(DB, 11489793)

VCF.get_variant(DB, 1)

# ---- #

VCF.get_variant(DB, "OR4G4P")

# ---- #

VCF.get_variant(DB, 1, 0, 80000)

VCF.get_variant(DB, 7, 0, 100000)

VCF.get_variant(DB, "MT", 0, 100000)

# ---- #

VCF.count_impact(VCF.get_variant(DB, 1, 0, 80000))
