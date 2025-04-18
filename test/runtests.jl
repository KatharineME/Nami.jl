using Test: @test

using Nami

# ----------------------------------------------------------------------------------------------- #

using SQLite: DB, drop!

# ---- #

const DA = pkgdir(Nami, "data")

const VC = joinpath(DA, "thin.10K.vcf.gz")

# ---- #

# 1.054 s (2388063 allocations: 642.59 MiB)

for vc in (VC,)

    @test Nami.lo(vc) == nothing

    @btime Nami.lo($vc)

end

# ---- #

# 7.667 ns (0 allocations: 0 bytes)
# 1.363 μs (22 allocations: 1.10 KiB)

const MA = "Manta"

const IN = "SNVHPOL=3;MQ=60;ANN=C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000264784.8|protein_coding|2/11|c.250-40A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000309065.7|protein_coding|3/12|c.163-40A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000505104.5|processed_transcript|3/11|n.284-40A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000505506.1|processed_transcript|1/2|n.102-40A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000513129.1|protein_coding|3/5|c.163-40A>G||||||WARNING_TRANSCRIPT_NO_STOP_CODON,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000506839.1|processed_transcript|1/1|n.321-11188A>G||||||,C|intron_variant|MODIFIER|SLC2A9|ENSG00000109667|transcript|ENST00000506583.5|protein_coding|4/13|c.163-40A>G||||||;AA=C;E_1000G;E_Cited;E_ESP;E_ExAC;E_Freq;E_TOPMed;E_gnomAD;MA=T;MAC=898;MAF=0.1793;TSA=SNV;dbSNP_154;ALLELEID=1237953;CLNDISDB=MedGen:CN517202;CLNDN=not_provided;CLNHGVS=NC_000004.12:g.9996981T>C;CLNREVSTAT=criteria_provided,_single_submitter;CLNSIG=Benign;CLNVC=single_nucleotide_variant;CLNVCSO=SO:0001483;GENEINFO=SLC2A9:56606|SLC2A9-AS1:105374476;MC=SO:0001627|intron_variant;ORIGIN=1"

for (id, io, re_) in (
    ("Manta1234", IN, [MA, MA, MA, MA]),
    ("rs1234", IN, ["Intron Variant", "Modifier", "SLC2A9", "Benign"]),
)

    @test collect(Nami.get_effect_impact_gene_clnsig(id, io)) == re_

    #@btime Nami.get_effect_impact_gene_clnsig($id, $io)

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

# 254.629 ns (8 allocations: 520 bytes)

for (ef, al, sa, re) in (("A", "T", "0|1:88", ("A", "T")),)

    @test Nami.get_alleles(ef, al, sa) == re

    #@btime Nami.get_alleles($ef, $al, $sa)

end

# ---- #

const SQ = DB(joinpath(DA, "thin.db"))

# ---- #

# 4.881642 seconds (17.20 M allocations: 1.345 GiB, 2.57% gc time, 3.17% compilation time)
# 89.401177 seconds (328.98 M allocations: 25.166 GiB, 2.50% gc time)

for (sq, ba, re) in
    ((SQ, VC, 17900000), (DB(joinpath(DA, "735.db")), "735.vcf.gz", 353300000))

    drop!(sq, Nami.TA; ifexists = true)

    @time Nami.make_variant_table!(sq, joinpath(DA, ba))

    @test filesize(sq.file) > re

end

# ---- #

for (id, re) in (("rs625655", 20075434),)

    @test Nami.ge(
        SQ,
        """
        SELECT
        *
        FROM
        $(Nami.TA)
        WHERE
        id = '$id'""",
    )[][:POS] === re

end

# ---- #

for (id, re) in (("rs625655", "Modifier"),)

    @test Nami.get_variant_by_id(SQ, id)[:Impact] === re

end

# ---- #

for (ge, re) in (("UBR3", "rs11891040"),)

    @test Nami.get_variant(SQ, ge)[1][:ID] === re

end

# ---- #

for (ch, st, en, re) in (("MT", 0, 100000, "rs869183622"),)

    @test Nami.get_variant(SQ, ch, st, en)[1][:ID] === re

end

# ---- #

for (ch, st, en, re) in (("MT", 0, 100000, (1, 1, 0, 0)),)

    @test Nami.get_impact(Nami.get_variant(SQ, ch, st, en)) == re

end
