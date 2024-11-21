using Nami

using Revise: includet

includet("view.jl")

@genietools

# ---- #

const UP = joinpath("public", "upload")

if !isdir(UP)

    mkdir(UP)

end

const DA = joinpath(UP, "variant.db")

# ---- #

@app begin

    @in su = true

    @in ss = false

    # ---- #

    @in fi = ""

    db = Nami.DB(DA)

    @event up begin

        fi = fileuploads["name"]

        Nami.make_variant_table!(
            db,
            mv(fileuploads["path"], joinpath(UP, fi); force = true),
        )

        su = false

        ss = true

    end

    # ---- #

    @in ta = ""

    @out em = false

    @out sr = false

    # ---- #

    @in va = Dict{Symbol, Union{Int, AbstractString}}()

    # ---- #

    @out rs = ""

    @in ri = 0

    @in cv = false

    @out co = ""

    @out cl = ""

    @out po = 0

    @out a0 = ""

    @out a1 = ""

    @out a2 = ""

    @out an = ""

    @out ip = ""

    # ---- #

    @out va_ = Dict{Symbol, Union{Int, AbstractString}}[]

    # ---- #

    @in sy = ""

    @in cg = false

    # ---- #

    @out ch_ = vcat(string.(collect(range(1, 22))), ["X", "Y", "MT"])

    @in ch = ""

    @in st = 0

    @in en = 0

    @in cr = false

    # ---- #

    @onchange va begin

        if va == Dict{Symbol, Union{Int64, AbstractString}}()

            em = true

        else

            co = va[:chrom]

            po = va[:pos]

            rs = va[:id]

            ri = parse(Int, rs[3:end])

            a0 = va[:ref]

            cl = va[:gene]

            a1 = va[:allele_1]

            a2 = va[:allele_2]

            an = va[:effect]

            ip = va[:impact]

            sr = true

        end

    end

    @onchange ri, sy, ch, st, en begin

        em = false

        sr = false

    end

    @onbutton cv begin

        va = Nami.get_variant(db, ri)

    end

    # ---- #

    @out ca_ =
        Dict("A" => "blue", "T" => "green", "G" => "deep-purple-6", "C" => "purple-6")

    @out ci_ = Dict(
        "MODIFIER" => "blue-grey",
        "LOW" => "yellow-8",
        "MODERATE" => "deep-orange",
        "HIGH" => "red-8",
    )

    @out im_ = (0, 0, 0, 0)

    # ---- #

    @onbutton cg begin

        va_ = Nami.get_variant(db, sy)

        im_ = Nami.count_impact(va_)

        if im_ == (0, 0, 0, 0)

            em = true

        else

            sr = true

        end

    end

    # ---- #

    @onbutton cr begin

        va_ = Nami.get_variant(db, ch, st, en)

        im_ = Nami.count_impact(va_)

        if im_ == (0, 0, 0, 0)

            em = true

        else

            sr = true

        end

    end

end

# ---- #

@page "/" view layout = path"layout.html"
