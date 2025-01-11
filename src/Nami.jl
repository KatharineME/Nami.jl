module Nami

using CodecZlib: GzipDecompressorStream

using SQLite: Stmt

using SQLite.DBInterface: close!, execute

function _get_effect_impact_gene(id, io)

    # TODO: Find the allocation
    if startswith(id, "Manta")

        "Manta", "Manta", "Manta"

    else

        #TODO: Return annotation for multi-allelic variants
        _, ef, ip, ge, _ = eachsplit(io, '|'; limit = 5)

        titlecase(replace(ef, '_' => ' ')), titlecase(ip), ge

    end

end

function _get_before_colon(st)

    be, _ = eachsplit(st, ':'; limit = 2)

    be

end

function _get_allele(gt, re, al)

    id = parse(Int, gt)

    # TODO: Do not split allocate
    iszero(id) ? re : split(al, ','; limit = id + 1)[id]

end

function _get_alleles(re, al, sa)

    gt = _get_before_colon(sa)

    if isone(lastindex(gt))

        _get_allele(gt, re, al), ""

    else

        a1, a2 = (_get_allele(sp, re, al) for sp in eachsplit(gt, r"\||/"))

        a1, a2

    end

end

const TA = "Variant"

function make_variant_table!(da, vc)

    # TODO: Learn to speed up SQL

    execute(
        da,
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
            Allele1 TEXT,
            Allele2 TEXT
        )""",
    )

    # TODO: Read more efficiently
    for li in eachline(GzipDecompressorStream(open(vc)))

        if startswith(li, '#')

            continue

        end

        ch, po, id, re, al, _, _, io, fo, sa = eachsplit(li, '\t')

        if _get_before_colon(fo) != "GT"

            continue

        end

        if id == "."

            id = "$ch:$po"

        end

        ef, ip, ge = _get_effect_impact_gene(id, io)

        a1, a2 = _get_alleles(re, al, sa)

        execute(
            da,
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
                '$a1',
                '$a2'
            )""",
        )

    end

end

function _state_execute_close(da, st)

    sa = Stmt(da, st)

    va_ = map(
        ro -> Dict{Symbol, Union{Int, String}}(
            zip((:CHROM, :POS, :ID, :REF, :Effect, :Impact, :Gene, :Allele1, :Allele2), ro),
        ),
        execute(sa),
    )

    close!(sa)

    va_

end

function get_variant_by_id(da, id)

    va_ = _state_execute_close(
        da,
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

function get_variant(da, ge)

    _state_execute_close(
        da,
        """
        SELECT
        *
        FROM
        $TA
        WHERE
        gene = '$ge'""",
    )

end

function get_variant(da, ch, st, en)

    _state_execute_close(
        da,
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

function count_impact(va_)

    mo = lo = md = hi = zero(Int)

    for va in va_

        ip = va[:Impact]

        if ip == "Manta"

            continue

        elseif ip == "Modifier"

            mo += 1

        elseif ip == "Low"

            lo += 1

        elseif ip == "Moderate"

            md += 1

        elseif ip == "High"

            hi += 1

        end

    end

    mo, lo, md, hi

end

end
