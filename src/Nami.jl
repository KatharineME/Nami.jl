module Nami

using Base.Iterators: take

using CodecZlib: GzipDecompressorStream

using SQLite: DB, Stmt, drop!

using SQLite.DBInterface: close!, execute

function _get_allele(nu, re, al)

    nm = parse(Int, nu)

    iszero(nm) ? re : collect(take(eachsplit(al, ','), 3))[nm]

end

function _get_character_before_colon(st)

    collect(take(eachsplit(st, ':'), 1))[1]

end

function make_variant_table!(da, vc)

    ta = "variant"

    drop!(da, ta; ifexists = true)

    execute(
        da,
        """
        CREATE TABLE IF NOT EXISTS
        $ta
        ( chrom TEXT,
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

    ch = 0

    for li in eachline(GzipDecompressorStream(open(vc)))

        if startswith(li, '#')

            continue

        end

        cr, po, id, re, al, _, _, io, fo, sa = eachsplit(li, '\t')

        if cr != ch

            @info "Chromosome $(ch = cr)"

        end

        ps = parse(Int, po)

        ma = startswith(id, "Manta")

        if id == "."

            id = "$cr:$ps"

        elseif !startswith(id, "rs") && !ma

            @error cr ps id

        end

        if ma

            ef = ip = ge = "Manta"

        else

            #TODO: Return annotation for multi-allelic variants
            ee, ia, ge = collect(take(eachsplit(io, '|'), 5))[2:4]

            ef, ip = (titlecase(st) for st in (replace(ee, '_' => ' '), ia))

        end

        nu = _get_character_before_colon(sa)

        if _get_character_before_colon(fo) != "GT"

            continue

        elseif lastindex(nu) == 1

            a1 = _get_allele(nu, re, al)

            a2 = ""

        else

            a1, a2 = (_get_allele(sp, re, al) for sp in eachsplit(nu, r"\||/"))

        end

        execute(
            da,
            """
            INSERT INTO
            variant 
            VALUES
            (
            '$cr',
            $ps,
            '$id',
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

    va = Dict{Symbol, Union{Int, AbstractString}}(
        zip((:chrom, :pos, :id, :ref, :effect, :impact, :gene, :allele1, :allele2), ro),
    )

end

function _execute_statement(da, st)

    sa = Stmt(da, st)

    return map(_make_variant_dictionary, execute(sa)), sa

end

function get_variant_by_id(da, id)

    va_, sa = _execute_statement(
        da,
        """
        SELECT
            *
        FROM
            variant
        WHERE
            id = '$id'
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

    return va_

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

    return va_

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
