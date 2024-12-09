module Nami

using CodecZlib: GzipDecompressorStream

using .Iterators: take

using SQLite: DB, drop!, tableinfo

using SQLite.DBInterface: execute

function get_allele(ng, re, al)

    ng == "0" ? re : collect(take(eachsplit(al, ','), 3))[parse(Int, ng)]

end

function get_character_before_colon(st)

    collect(take(eachsplit(st, ':'), 1))[1]

end

function make_variant_table!(db, vc)

    ta = "variant"

    drop!(db, ta; ifexists = true)

    execute(
        db,
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

    cr = 0

    for li in eachline(GzipDecompressorStream(open(vc)))

        if li[1] == '#'

            continue

        end

        ch, ps, id, re, al, _, _, io, fo, sa = eachsplit(li, '\t')

        if ch != cr

            @info "Chromosome $(cr = ch)"

        end

        po = parse(Int, ps)

        ma = startswith(id, "Manta")

        if id == "."

            id = "$ch:$po"

        elseif !startswith(id, "rs") && !ma

            @error ch, po, id

        end

        if ma

            ef = ip = ge = "Manta"

        else

            #TODO: Return annotation for multi-allelic variants
            ee, ia, ge = collect(take(eachsplit(io, '|'), 5))[2:4]

            ef, ip = (titlecase(st) for st in (replace(ee, "_" => " "), ia))

        end

        ng = get_character_before_colon(sa)

        if get_character_before_colon(fo) != "GT"

            continue

        elseif lastindex(ng) == 1

            a1, a2 = get_allele(ng, re, al), ""

        else

            a1, a2 = (get_allele(sp, re, al) for sp in eachsplit(ng, r"\||/"))

        end

        execute(
            db,
            """
            INSERT INTO
            variant 
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

function get_variant(db, id)

    va_ = map(_make_variant_dictionary, execute(
        db,
        """
        SELECT
            *
        FROM
            variant
        WHERE
            id = 'rs$id'
        """,
    ))

    if isempty(va_)

        Dict{Symbol, Union{Int, AbstractString}}()

    else

        va_[1]

    end

end

function get_variant(db, ge::AbstractString)

    map(_make_variant_dictionary, execute(
        db,
        """
        SELECT
            *
        FROM
            variant
        WHERE
            gene = '$ge'
        """,
    ))

end

function get_variant(db, ch, st, en)

    map(_make_variant_dictionary, execute(
        db,
        """
        SELECT
            *
        FROM
            variant
        WHERE
            chrom = '$ch'
        AND
            $st <= pos
        AND
            pos <= $en
        """,
    ))

end

function count_impact(va_)

    mi = lo = me = hi = zero(Int32)

    for va in va_

        ip = va[:impact]

        if ip == "Manta"

            continue

        elseif ip == "Modifier"

            mi += 1

        elseif ip == "Low"

            lo += 1

        elseif ip == "Moderate"

            me += 1

        elseif ip == "High"

            hi += 1

        else

            error(ip)

        end

    end

    mi, lo, me, hi

end

end
