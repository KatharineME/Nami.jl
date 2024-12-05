using Nami

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

    @in sp = false

    @in ss = false

    @in fi = ""

    # ---- #

    db = Nami.DB(DA)

    @event st begin

        @info "st"

    end

    @event up begin

        @info "up"

        sp = true

        su = false

        fi = fileuploads["name"]

        Nami.make_variant_table!(
            db,
            mv(fileuploads["path"], joinpath(UP, fi); force = true),
        )

    end

    @event fi begin

        @info "fi"

        sp = false

        @info "sp" sp

        ss = true

        @info "ss" ss

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

function view_input(ty, la, hi, bi)

    quasar(
        :input;
        type = ty,
        label = la,
        hint = hi,
        outlined = true,
        clearable = true,
        bg__color = "grey-2",
        class = "q-pa-sm",
        @bind(bi)
    )

end

function view_search_button(bu)

    quasar(
        :btn;
        size = "lg",
        color = "teal-13",
        label = "Search",
        class = "q-mt-lg",
        @click("$bu = true")
    )

end

function view_allele(al, la)

    ai = "$al"

    quasar(
        :card,
        [
            xelem(:h1, "{{$ai}}"; class = "q-pa-md text-white"),
            xelem(:h4, la; class = "q-pb-md text-white"),
        ];
        flat = true,
        class = Symbol(
            "($ai == 'A' ? 'bg-blue' : $ai == 'T' ? 'bg-cyan' : $ai == 'G' ? 'bg-teal' : $ai == 'C' ? 'bg-green' : 'bg-pink') + ' col' + ' q-ma-lg'",
        ),
    )

end

function view_impact(nu, na, co)

    quasar(
        :card,
        [
            xelem(:h1, "{{$nu}}"; class = "q-pa-md text-white"),
            xelem(:h4, "$na"; class = "q-pb-md text-white"),
        ];
        flat = true,
        class = "bg-$co col q-ma-lg",
        style = "max-width:160px;",
    )

end

const IM =
    (modifier = "blue-grey", low = "yellow-8", moderate = "deep-orange", high = "red-8")

function view_impact()

    xelem(
        :div,
        [
            view_impact("im_[0]", "Modifier", IM[Symbol("modifier")]),
            view_impact("im_[1]", "Low", IM[Symbol("low")]),
            view_impact("im_[2]", "Moderate", IM[Symbol("moderate")]),
            view_impact("im_[3]", "High", IM[Symbol("high")]),
        ];
        class = "row flex-center q-pa-lg",
        style = "max-width: 960px;",
    )

end

function view_variant_button()

    xelem(
        :div,
        @recur("vr in va_"),
        quasar(
            :btn;
            label! = "vr.id",
            color! = "ci_[vr.impact]",
            size = "md",
            class = "q-ma-md",
            @click("ta = 't1'; va = vr")
        ),
    )

end

# ---- #

@page "/" path"html/view.jl.html" layout = path"html/layout.html"
