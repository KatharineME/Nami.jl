using Nami

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using SQLite: DB, drop!

# TODO: Test and benchmark each function within its loop.

# ---- #

# 8.625 ns (1 allocation: 32 bytes)
for (id, io, re) in (("Manta1234", "", ("Manta", "Manta", "Manta")),)

    @test Nami._get_effect_impact_gene(id, io) === re

    #@btime Nami._get_effect_impact_gene($id, $io)

end

# ---- #

# 30.947 ns (0 allocations: 0 bytes)
for (st, re) in (("Aa:Bb:Cc", "Aa"),)

    @test Nami._get_before_colon(st) == re

    #@btime Nami._get_before_colon($st)

end

# ---- #

for (st, re) in (("", ""), ("", ""))

    Nami._get_allele

end

# ---- #

Nami._get_alleles

# ---- #

const DA = pkgdir(Nami, "data")

const DT = DB(joinpath(DA, "_.db"))

# ---- #

function dro!()

    drop!(DT, Nami.TA; ifexists = true)

end

# ---- #

const VC = joinpath(DA, "thin.1M.vcf.gz")

dro!()
Nami.make_variant_table!(DT, VC)

@test filesize(DT.file) === 32768

@code_warntype Nami.make_variant_table!(DT, VC)

# 58.479 ms (22535 allocations: 1.92 MiB)
#@btime Nami.make_variant_table!(DT, VC) setup = dro!() evals = 1

# ---- #

Nami._state_execute_close

# ---- #

Nami.get_variant_by_id(DT, "rs10916692")

# ---- #

Nami.get_variant(DT, "UBR3")

# ---- #

const VA_ = Nami.get_variant(DT, 1, 0, 2400000)

# ---- #

Nami.get_variant(DT, "MT", 0, 100000)

# ---- #

Nami.count_impact(VA_)

# ---- #

# 1078.705501 seconds (328.96 M allocations: 25.391 GiB, 0.25% gc time)
# 2489.269564 seconds (328.95 M allocations: 25.318 GiB, 0.16% gc time)
dro!()
#@time Nami.make_variant_table!(DT, joinpath(DA, "735.vcf.gz"))
