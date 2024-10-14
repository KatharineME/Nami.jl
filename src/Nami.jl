module Nami

using SQLite: DB

using SQLite.DBInterface: execute

using CodecZlib: GzipDecompressorStream

function _get_gene(io)

    _get_annotation(io)[4]

end

function _get_annotation(io)

    io_ = split(io, ';')

    an = io_[findfirst(startswith("ANN="), io_)][5:end]

    split(an, '|'; limit = 5)

end

function make_variant_table!(db, vc)

    execute(
        db,
        """
        CREATE TABLE IF NOT EXISTS
        variant
        (
        chrom TEXT,
        pos INTEGER,
        id TEXT,
        ref TEXT,
        alt TEXT, 
        info TEXT,
        format TEXT,
        sample TEXT,
        gene TEXT,
        PRIMARY KEY (chrom, pos)
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

        ge = ma ? "Manta" : _get_gene(io)

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
            '$al',
            '$io',
            '$fo',
            '$sa',
            '$ge'
            )
        """,
        )

    end

end

function _make_variant_dictionary(ro)

    va = Dict{Symbol, Union{Int, AbstractString}}(
        zip((:chrom, :pos, :id, :ref, :alt, :info, :format, :sample, :gene), ro),
    )

    if startswith(va[:id], "Manta")

        va[:effect] = va[:impact] = "Manta"

    else

        #TODO: Return annotation for multi-allelic variants
        _, va[:effect], va[:impact], _ = _get_annotation(va[:info])

    end

    for (fo, sa) in zip(eachsplit(va[:format], ':'), eachsplit(va[:sample], ':'))

        if fo == "GT"

            va[:allele_1], va[:allele_2] = (
                sp == "0" ? va[:ref] :
                string(split(va[:alt], ','; limit = 3)[parse(Int, sp)]) for
                sp in eachsplit(sa, r"\||/")
            )

        end

    end

    va

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

        if ip == "MODIFIER"

            mi += 1

        elseif ip == "LOW"

            lo += 1

        elseif ip == "MODERATE"

            me += 1

        elseif ip == "HIGH"

            hi += 1

        else

            error()

        end

    end

    mi, lo, me, hi

end

end
