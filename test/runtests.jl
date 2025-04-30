using Test: @test

using Nami

# ----------------------------------------------------------------------------------------------- #

using SQLite: DB, drop!

# ---- #

const DA = pkgdir(Nami, "data")

const VC = joinpath(DA, "thin.10K.vcf.gz")

# ---- #

# 1.033 s (2388265 allocations: 642.61 MiB)

for vc in (VC,)

    @test Nami.lo(vc) === nothing

    #@btime Nami.lo($vc)

end

# ---- #

const I1 = "SNVHPOL=3;MQ=60;ANN=C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000264784.8|protein_coding|2/11|c.250-40A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000309065.7|protein_coding|3/12|c.163-40A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000505104.5|processed_transcript|3/11|n.284-40A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000505506.1|processed_transcript|1/2|n.102-40A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000513129.1|protein_coding|3/5|c.163-40A>G||||||WARNING_TRANSCRIPT_NO_STOP_CODON,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000506839.1|processed_transcript|1/1|n.321-11188A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000506583.5|protein_coding|4/13|c.163-40A>G||||||;AA=C;E_1000G;E_Cited;E_ESP;E_ExAC;E_Freq;E_TOPMed;E_gnomAD;MA=T;MAC=898;MAF=0.1793;TSA=SNV;dbSNP_154;ALLELEID=1237953;CLNDISDB=MedGen:CN517202;CLNDN=not_provided;CLNHGVS=NC_000004.12:g.9996981T>C;CLNREVSTAT=criteria_provided,_single_submitter;CLNSIG=Benign;CLNVC=single_nucleotide_variant;CLNVCSO=SO:0001483;GENEINFO=SLC2A9:56606|SLC2A9-AS1:105374476;MC=SO:0001627|intron_variant;ORIGIN=1"

const I2 = "SNVHPOL=3;MQ=60;ANN=C|missense_variant|MODERATE|SOX|ENSG00000109667|transcript|ENST00000264784.8|protein_coding|CLNREVSTAT=criteria_provided,_single_submitter;CLNSIG=5;CLNVC=single_nucleotide_variant;CLNVCSO=SO:0001483;GENEINFO=SLC2A9:56606|SLC2A9-AS1:105374476;MC=SO:0001627|intron_variant;ORIGIN=1"

# ---- #

# 714.886 ns (5 allocations: 416 bytes)
# 288.471 ns (8 allocations: 736 bytes)

for (io, re) in ((I1, "Benign"), (I2, "Pathogenic"))

    @test Nami.get_clnsig(io) == re

    #@btime Nami.get_clnsig($io)

end

# ---- #

# 7.667 ns (0 allocations: 0 bytes)
# 1.708 μs (22 allocations: 1.10 KiB)
# 1.075 μs (25 allocations: 1.41 KiB)

const MA = "Manta"

for (id, io, re_) in (
    ("Manta1234", I1, [MA, MA, MA, MA]),
    ("rs1234", I1, ["Intron Variant", "Modifier", "SLC2A9", "Benign"]),
    ("rs1234", I2, ["Missense Variant", "Moderate", "SOX", "Pathogenic"]),
)

    @test collect(Nami.get_annotation(id, io)) == re_

    #@btime Nami.get_annotation($id, $io)

end

# ---- #

# 14.557 ns (1 allocation: 24 bytes)

for (st, re) in (("Aa:Bb:Cc", "Aa"),)

    @test Nami.get_before_colon(st) === re

    #@btime Nami.get_before_colon($st)

end

# ---- #

# 3.083 ns (0 allocations: 0 bytes)

for (it, re, al) in ((0, "A", "C"),)

    @test Nami.get_allele(it, re, al) === re

    #@btime Nami.get_allele($it, $re, $al)

end

# ---- #

# 256.327 ns (8 allocations: 520 bytes)
# 209.091 ns (5 allocations: 216 bytes)
# 289.004 ns (11 allocations: 824 bytes)

for (re, al, sa, re_) in (
    ("A", "T", "0|1:88", ("A", "T")),
    ("A", "T", "0|0:88", ("A", "A")),
    ("A", "T", "1|1:88", ("T", "T")),
)

    @test Nami.get_alleles(re, al, sa) == re_

    #@btime Nami.get_alleles($re, $al, $sa)

end

# ---- #

const SQ = DB(joinpath(DA, "thin.db"))

# ---- #

# 4.991697 seconds (17.21 M allocations: 1.345 GiB, 2.69% gc time, 3.03% compilation time)
# 90.218603 seconds (328.98 M allocations: 25.167 GiB, 2.40% gc time)

for (sq, vc, re) in
    ((SQ, VC, 17900000), (DB(joinpath(DA, "735.db")), "735.vcf.gz", 353300000))

    drop!(sq, Nami.ST; ifexists = true)

    @time Nami.make_variant_table!(sq, joinpath(DA, vc))

    @test filesize(sq.file) > re

end

# ---- #

# 13.653 ms (162 allocations: 5.586 KiB)

for (id, re) in (("rs625655", 20075434),)

    st = """SELECT * FROM $(Nami.ST) WHERE id = '$id'"""

    @test Nami.ge(SQ, st)[][:POS] === re

    @time Nami.ge(SQ, st)

end

# ---- #

# 13.692 ms (163 allocations: 5.65 KiB)

for (id, re) in (("rs625655", "Modifier"),)

    @test Nami.get_variant_by_id(SQ, id)[:Impact] === re

    #@btime Nami.get_variant_by_id($SQ, $id)

end

# ---- #

# 13.369 ms (978 allocations: 40.75 KiB)

for (sy, re) in (("UBR3", "rs11891040"),)

    @test Nami.get_variant(SQ, sy)[1][:ID] === re

    #@btime Nami.get_variant($SQ, $sy)

end

# ---- #

# 10.874 ms (205 allocations: 7.42 KiB)

for (ch, st, en, re) in (("MT", 0, 100000, "rs869183622"),)

    @test Nami.get_variant(SQ, ch, st, en)[1][:ID] === re

    #@btime Nami.get_variant($SQ, $ch, $st, $en)

end

# ---- #

# 10.898 ms (206 allocations: 7.47 KiB)

for (ch, st, en, re_) in (("MT", 0, 100000, (1, 1, 0, 0)),)

    @test Nami.get_impact(Nami.get_variant(SQ, ch, st, en)) == re_

    #@btime Nami.get_impact(Nami.get_variant($SQ, $ch, $st, $en))

end
