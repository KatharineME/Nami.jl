using Nami

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using SQLite: DB, columns, drop!, tables

# TODO: Test and benchmark each function within its loop.

# ---- #

# 8.625 ns (1 allocation: 32 bytes)
for (id, io, re) in (
#(".", "TODO", ("TODO", "TODO", "TODO")),
#("rs", "TODO", ("TODO", "TODO", "TODO")),
    ("Manta1234", "TODO", ("Manta", "Manta", "Manta")),)

    @test Nami._get_effect_impact_gene(id, io) === re

    @btime Nami._get_effect_impact_gene($id, $io)

end

# ---- #

# 30.988 ns (0 allocations: 0 bytes)
for (st, re) in (("Aa:Bb:Cc", "Aa"),)

    @test Nami._get_character_before_colon(st) == re

    @btime Nami._get_character_before_colon($st)

end

# ---- #

Nami._get_allele

# ---- #

Nami._get_alleles

# ---- #

const FI = joinpath(tempdir(), "_.db")

if isfile(FI)

    rm(FI)

end

SQ = DB(FI)

# ---- #

const DA = pkgdir(Nami, "data")

function dro!()

    drop!(SQ, "variant"; ifexists = true)

end

# ---- #

const TH = joinpath(DA, "thin.1M.vcf.gz")

dro!()
Nami.make_variant_table!(SQ, TH)

@test isone(lastindex(tables(SQ)))

@test split(readchomp(`ls -lh $FI`); limit = 6)[5] === "32K"

# ---- #

@code_warntype Nami.make_variant_table!(SQ, TH)

# 58.000 ms (22535 allocations: 1.94 MiB)
@btime Nami.make_variant_table!(SQ, TH) setup = dro!()

# ---- #

Nami._make_variant_dictionary

# ---- #

Nami._execute_statement

# ---- #

Nami.get_variant_by_id(SQ, "rs10916692")

# ---- #

Nami.get_variant(SQ, "UBR3")

# ---- #

const VA_ = Nami.get_variant(SQ, 1, 0, 2400000)

# ---- #

Nami.get_variant(SQ, "MT", 0, 100000)

# ---- #

Nami.count_impact(VA_)

# ---- #

# 2838.857915 seconds (369.75 M allocations: 29.158 GiB, 0.20% gc time, 0.00% compilation time) 
# 1069.644638 seconds (328.96 M allocations: 25.645 GiB, 0.27% gc time)
dro!()
@time Nami.make_variant_table!(SQ, joinpath(DA, "735.vcf.gz"))
