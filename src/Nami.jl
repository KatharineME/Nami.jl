module Nami

# ----------------------------------------------------------------------------------------------- #

using CodecZlib: GzipDecompressorStream

using SQLite: _close_db!, Stmt

using SQLite.DBInterface: close!, execute

function lo(vc)

    for li in eachline(GzipDecompressorStream(open(vc)))

        if startswith(li, '#')

            continue

        end

        ch, po, id, _, = eachsplit(li, '\t'; limit = 4)

        if !startswith(id, r".|rs|Manta")

            @warn ch, po, id

        end

    end

end

const CL = Dict(
    "0" => "Benign",
    "1" => "Likely benign",
    "2" => "Likely benign",
    "3" => "Uncertain Significance",
    "4" => "Likely Pathogenic",
    "5" => "Pathogenic",
    "6" => "Drug Response",
    "7" => "Confers Sensitivity",
    "255" => "Other",
)

function get_clnsig(io)

    id = findfirst("CLNSIG=", io)

    cl = isnothing(id) ? "Unknown" : split(@view(io[(last(id) + 1):end]), ';'; limit = 2)[1]

    if occursin(r"\d", cl)

        cl = CL[split(cl, r"[,\|]"; limit = 2)[1]]

    end

    cl

end

function get_effect_impact_gene_clnsig(id, io)

    if startswith(id, "Manta")

        ("Manta" for i in 1:4)

    else

        _, ef, ip, ge, _ = eachsplit(io, '|'; limit = 5)

        titlecase(replace(ef, '_' => ' ')), titlecase(ip), ge, get_clnsig(io)

    end

end

function get_before_colon(st)

    st[1:(findfirst(':', st) - 1)]

end

function get_allele(it, re, al)

    iszero(it) ? re : split(al, ','; limit = it + 1)[it]

end

function get_alleles(re, al, sa)

    it_ = map(st -> parse(Int, st), eachsplit(get_before_colon(sa), r"\||/"))

    if isone(lastindex(it_))

        get_allele(it_[1], re, al), ""

    else

        get_allele(it_[1], re, al), get_allele(it_[2], re, al)

    end

end

const TA = "Variant"

function make_variant_table!(sq, vc)

    execute(sq, "PRAGMA journal_mode = WAL")

    execute(
        sq,
        """
        CREATE TABLE
        $TA 
        (
            CHROM TEXT,
            POS INTEGER,
            ID TEXT,
            REF TEXT,
            Effect TEXT,
            Impact TEXT,
            Gene TEXT,
            Clnsig TEXT,
            Allele1 TEXT,
            Allele2 TEXT)""",
    )

    @inbounds for li in eachline(GzipDecompressorStream(open(vc)))

        if startswith(li, '#')

            continue

        end

        ch, po, id, re, al, _, _, io, fo, sa = eachsplit(li, '\t')

        if get_before_colon(fo) != "GT"

            continue

        end

        if id == "."

            id = "$ch:$po"

        end

        ef, ip, ge, cl = get_effect_impact_gene_clnsig(id, io)

        a1, a2 = get_alleles(re, al, sa)

        execute(
            sq,
            """
            INSERT INTO
            $TA
            VALUES
            (
                '$ch',
                $po,
                '$id',
                '$re',
                '$ef',
                '$ip',
                '$ge',
                '$cl',
                '$a1',
                '$a2')""",
        )

    end

end

function ge(sq, st)

    ta = Stmt(sq, st)

    va_ = map(
        ro -> Dict{Symbol, Union{Int, String}}(
            zip(
                (
                    :CHROM,
                    :POS,
                    :ID,
                    :REF,
                    :Effect,
                    :Impact,
                    :Gene,
                    :Clnsig,
                    :Allele1,
                    :Allele2,
                ),
                ro,
            ),
        ),
        execute(ta),
    )

    close!(ta)

    va_

end

function get_variant_by_id(sq, id)

    va_ = ge(
        sq,
        """
        SELECT
        *
        FROM
        $TA
        WHERE
        id = '$id'""",
    )

    isempty(va_) ? Dict{Symbol, Union{Int, String}}() : va_[]

end

function get_variant(sq, sy)

    ge(
        sq,
        """
        SELECT
        *
        FROM
        $TA
        WHERE
        gene = '$sy'""",
    )

end

function get_variant(sq, ch, st, en)

    ge(
        sq,
        """
        SELECT
        *
        FROM
        $TA
        WHERE
        chrom = '$ch'
        AND
        $st <= pos
        AND
        pos <= $en""",
    )

end

function get_impact(va_)

    mo = lo = od = hi = zero(Int)

    @inbounds for va in va_

        ip = va[:Impact]

        if ip == "Manta"

            continue

        elseif ip == "Modifier"

            mo += 1

        elseif ip == "Low"

            lo += 1

        elseif ip == "Moderate"

            od += 1

        elseif ip == "High"

            hi += 1

        end

    end

    mo, lo, od, hi

end

end
