module Nami

using CodecZlib: GzipDecompressorStream

using SQLite: DB

using SQLite.DBInterface: execute

# TODO: Speed up
function _get_annotation(io)

    io_ = split(io, ';')

    io_[findfirst(startswith("ANN="), io_)][5:end]

end

function make_variant_table!(db, vc)

    execute(
        db,
        """
        CREATE TABLE IF NOT EXISTS
            Variant
            (
                _id INTEGER PRIMARY KEY,
                chrom TEXT,
                pos INTEGER,
                id TEXT,
                ref TEXT,
                alt TEXT,
                qual INTEGER,
                filter TEXT,
                info TEXT,
                format TEXT,
                sample TEXT,
                gene TEXT
            )
        """,
    )

    _id = zero(UInt32)

    cu = ""

    for li in eachline(GzipDecompressorStream(open(vc)))

        if li[1] == '#'

            continue

        end

        ch, ps, id, re, al, qs, fi, io, fo, sa = eachsplit(li, '\t')

        if cu != ch

            cu = ch

            @info "Reading chromosome $ch"

        end

        po = parse(Int, ps)

        qu = parse(Int, qs)

        if id == "."

            id = "$ch:$po"

        elseif !(startswith(id, "rs") || startswith(id, "Manta"))

            @error id

        end

        ge =
            startswith(id, "Manta") ? "TODO Manta" :
            split(_get_annotation(io), '|'; limit = 5)[4]

        execute(
            db,
            """
            INSERT INTO
                Variant
            VALUES
                (
                    $(_id += 1),
                    '$ch',
                    $po,
                    '$id',
                    '$re',
                    '$al',
                    $qu,
                    '$fi',
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

    # TODO: Use struct
    va = Dict{Symbol, Union{Int, AbstractString}}(
        zip(
            (
                :_id,
                :chrom,
                :pos,
                :id,
                :ref,
                :alt,
                :qual,
                :filter,
                :info,
                :format,
                :sample,
                :gene,
            ),
            ro,
        ),
    )

    # TODO: Make sure that the number of splits are always the same
    for (fo, sa) in zip(eachsplit(va[:format], ':'), eachsplit(va[:sample], ':'))

        if fo == "GT"

            re = va[:ref]

            al = va[:alt]

            va[:allele_1], va[:allele_2] =
                (sp == "0" ? re : al for sp in eachsplit(sa, r"|/"))

        else

            va[Symbol(fo)] = sa

        end

    end

    if startswith(va[:id], "Manta")

        va[:annotation] = va[:impact] = "Manta"

    else

        ae, va[:annotation], va[:impact], _ =
            split(_get_annotation(va[:info]), '|'; limit = 4)

        if va[:alt] != ae

            @error "$(va[:alt]) != $ae" va

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
            Variant
        WHERE
            id = 'rs$id'
        """,
    ))

    if isempty(va_)

        Dict{Symbol, Union{Int, AbstractString}}()

    else

        # TODO: Fix the VCF and va_[]
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
            Variant
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
            Variant
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

    ui = ul = ue = uh = zero(UInt32)

    for va in va_

        ip = va[:impact]

        if ip == "MODIFIER"

            ui += 1

        elseif ip == "LOW"

            ul += 1

        elseif ip == "MODERATE"

            ue += 1

        elseif ip == "HIGH"

            uh += 1

        else

            error()

        end


    end

    ui, ul, ue, uh

end

end
