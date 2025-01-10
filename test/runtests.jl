using Nami

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using SQLite: DB, columns

# ---- #

const FI = joinpath(tempdir(), "_.db")

if isfile(FI)

    rm(FI)

end

SQ = DB(FI)

# ---- #

const DA = pkgdir(Nami, "data")

# ---- #

# 58.226 ms (25681 allocations: 2.19 MiB)
disable_logging(Info)
@btime Nami.make_variant_table!(SQ, $(joinpath(DA, "thin.1M.vcf.gz")))
disable_logging(Debug)

# 32K
readchomp(`ls -lh $FI`)

# ---- #

# 2838.857915 seconds (369.75 M allocations: 29.158 GiB, 0.20% gc time, 0.00% compilation time) 
disable_logging(Info)
@btime Nami.make_variant_table!(SQ, $(joinpath(DA, "735.vcf.gz")))
disable_logging(Debug)

# 337M
readchomp(`ls -lh $FI`)

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
