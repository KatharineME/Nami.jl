module Nami

using CodecZlib: GzipDecompressorStream

using SQLite: Stmt

using SQLite.DBInterface: close!, execute

function _get_effect_impact_gene(iv, io)

    # TODO: Find the allocation
    if startswith(iv, "Manta")

        "Manta", "Manta", "Manta"

    else

        #TODO: Return annotation for multi-allelic variants
        _, ee, ia, ge, _ = eachsplit(io, '|'; limit = 5)

        titlecase(replace(ee, '_' => ' ')), titlecase(ia), ge

    end

end

function _get_character_before_colon(fo)

    ca, _ = eachsplit(fo, ':'; limit = 2)

    ca

end

function _get_allele(ia, re, al)

    il = parse(Int, ia)

    # TODO: Do not split allocate
    iszero(il) ? re : split(al, ','; limit = il + 1)[il]

end

function _get_alleles(re, al, sa)

    ca = _get_character_before_colon(sa)

    if isone(lastindex(ca))

        _get_allele(ca, re, al), ""

    else

        a1, a2 = (_get_allele(ia, re, al) for ia in eachsplit(ca, r"\||/"))

        a1, a2

    end

end

function make_variant_table!(da, vc)

    ta = "variant"

    # TODO: Learn to speed up SQL

    execute(
        da,
        """
        CREATE TABLE IF NOT EXISTS
        $ta
        (
            chrom TEXT,
            pos INTEGER,
            id TEXT,
            ref TEXT,
            effect TEXT,
            impact TEXT,
            gene TEXT,
            allele1 TEXT,
            allele2 TEXT
        )
        """,
    )

    # TODO: Read more efficiently
    for li in eachline(GzipDecompressorStream(open(vc)))

        if startswith(li, '#')

            continue

        end

        cr, po, iv, re, al, _, _, io, fo, sa = eachsplit(li, '\t')

        if iv == "."

            iv = "$cr:$po"

        end

        ef, ip, ge = _get_effect_impact_gene(iv, io)

        if _get_character_before_colon(fo) != "GT"

            continue

        end

        a1, a2 = _get_alleles(re, al, sa)

        execute(
            da,
            """
            INSERT INTO
            variant 
            VALUES
            (
                '$cr',
                $po,
                '$iv',
                '$re',
                '$ef',
                '$ip',
                '$ge',
                '$a1',
                '$a2'
            )
        """,
        )

    end

end

function _make_variant_dictionary(ro)

    Dict{Symbol, Union{Int, AbstractString}}(
        zip((:chrom, :pos, :id, :ref, :effect, :impact, :gene, :allele1, :allele2), ro),
    )

end

function _execute_statement(da, st)

    sa = Stmt(da, st)

    map(_make_variant_dictionary, execute(sa)), sa

end

function get_variant_by_id(da, iv)

    va_, sa = _execute_statement(
        da,
        """
        SELECT
            *
        FROM
            variant
        WHERE
            id = '$iv'
        """,
    )

    close!(sa)

    if isempty(va_)

        Dict{Symbol, Union{Int, AbstractString}}()

    else

        va_[1]

    end

end

function get_variant(da, ge)

    va_, sa = _execute_statement(
        da,
        """
        SELECT
            *
        FROM
            variant
        WHERE
            gene = '$ge'
        """,
    )

    close!(sa)

    va_

end

function get_variant(da, cr, st, en)

    va_, sa = _execute_statement(
        da,
        """
        SELECT
            *
        FROM
            variant
        WHERE
            chrom = '$cr'
        AND
            $st <= pos
        AND
            pos <= $en
        """,
    )

    close!(sa)

    va_

end

function count_impact(va_)

    mo = lo = md = hi = zero(Int32)

    for va in va_

        ip = va[:impact]

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

        else

            error(ip)

        end

    end

    mo, lo, md, hi

end

end
