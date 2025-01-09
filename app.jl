using Revise: includet

using SQLite.DBInterface: close!

using Nami

includet("view.jl")

@genietools

# ---- #

const UP = joinpath("public", "upload")

const CO_ = Dict(
    "Modifier" => "blue-grey",
    "Low" => "yellow-8",
    "Moderate" => "deep-orange",
    "High" => "red-8",
)

# ---- #

@app begin

    @in up = true

    @in sp = false

    @in se = false

    @in na = ""

    @in da = Nami.DB()

    # ---- #

    @event ul begin

        up = false

        sp = true

        na = fileuploads["name"]

        close!(da)

        da = Nami.DB(mv(fileuploads["path"], joinpath(UP, na); force = true))

    end

    @event fi begin

        sp = false

        se = true

    end

    # ---- #

    @in ta = ""

    @out em = false

    @out re = false

    # ---- #

    @in va = Dict{Symbol, Union{Int, AbstractString}}()

    @in rs = ""

    @in vr = false

    # ---- #

    @out va_ = Dict{Symbol, Union{Int, AbstractString}}[]

    # ---- #

    @in sy = ""

    @in ge = false

    # ---- #

    @out ch_ = vcat(string.(collect(range(1, 22))), ["X", "Y", "MT"])

    @in ch = ""

    @in st = 0

    @in en = 0

    @in rg = false

    # ---- #

    @out co_ = CO_

    @out im_ = (0, 0, 0, 0)

    # ---- #

    @onchange rs, sy, ch, st, en begin

        em = false

        re = false

    end

    @onchange va begin

        isempty(va) ? em = true : re = true

    end

    @onbutton vr begin

        va = Nami.get_variant_by_id(da, rs)

    end

    @onchange va_ begin

        im_ = Nami.count_impact(va_)

        if im_ == (0, 0, 0, 0)

            em = true

        else

            re = true

        end

    end

    @onbutton ge begin

        va_ = Nami.get_variant(da, sy)

    end

    @onbutton rg begin

        va_ = Nami.get_variant(da, ch, st, en)

    end

end

# ---- #

@page "/" path"html/view.html" layout = path"html/layout.html"
