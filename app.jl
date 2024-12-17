using Nami

@genietools

# ---- #

const UP = joinpath("public", "upload")

# ---- #

@app begin

    @in su = true

    @in sp = false

    @in ss = false

    @in na = ""

    @in db = Nami.DB()

    # ---- #

    @event up begin

        sp = true

        su = false

        na = fileuploads["name"]

        db = Nami.DB(mv(fileuploads["path"], joinpath(UP, na); force = true))

    end

    @event fi begin

        sp = false

        ss = true

    end

    # ---- #

    @in ta = ""

    @out em = false

    @out sr = false

    # ---- #

    @in va = Dict{Symbol, Union{Int, AbstractString}}()

    # ---- #

    @out co = ""

    @out po = 0

    @out rs = ""

    @in ri = ""

    @out a0 = ""

    @out ef = ""

    @out ip = ""

    @out ge = ""

    @out a1 = ""

    @out a2 = ""

    @in cv = false

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

            ri = rs

            a0 = va[:ref]

            ef = va[:effect]

            ip = va[:impact]

            ge = va[:gene]

            a1 = va[:allele1]

            a2 = va[:allele2]

            sr = true

        end

    end

    @onchange ri, sy, ch, st, en begin

        em = false

        sr = false

    end

    @onbutton cv begin

        va = Nami.get_variant_by_id(db, ri)

    end

    # ---- #

    @out ci_ = Dict(
        "Modifier" => "blue-grey",
        "Low" => "yellow-8",
        "Moderate" => "deep-orange",
        "High" => "red-8",
    )

    @out im_ = (0, 0, 0, 0)

    # ---- #

    @onchange va_ begin

        im_ = Nami.count_impact(va_)

        if im_ == (0, 0, 0, 0)

            em = true

        else

            sr = true

        end

    end

    @onbutton cg begin

        va_ = Nami.get_variant(db, sy)

    end

    # ---- #

    @onbutton cr begin

        va_ = Nami.get_variant(db, ch, st, en)

    end

end

# ---- #

function header()

    quasar(
        :header,
        [
            xelem(
                :p,
                "Nami";
                class = "col-4 offset-4 text-center text-white q-mt-lg q-mb-sm",
                style = "font-size: 240%; font-family: fantasy",
            ),
            xelem(
                :div,
                xelem(
                    :div,
                    "Searching {{na}}";
                    class = "text-h6 text-white text-right q-ma-md",
                );
                class = "col-2",
                @showif(:ss)
            ),
            quasar(
                :btn;
                outline = true,
                size = "md",
                color = "white",
                label = "Change",
                class = "col-1 q-ma-md",
                @showif(:ss),
                @click("su = true; ss = false;")
            ),
        ];
        class = "row items-center bg-indigo",
    )

end

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
        color = "indigo",
        label = "Search",
        class = "q-ma-lg",
        @click("$bu = true")
    )

end

function view_search_title(st)

    xelem(:div, st; class = "text-h4 text-black q-pt-xl q-pb-lg")

end

function view_no_variant_found()

    xelem(:div, "No variants found"; class = "text-h4 text-black q-pa-xl", @showif(:em))

end

function view_allele(al, la)

    ai = "$al"

    quasar(
        :card,
        [
            xelem(:div, la; class = "text-h6 text-white q-pa-md"),
            xelem(
                :div,
                "{{$ai}}";
                class = "text-white text-bold q-pb-md q-ma-sm",
                style = "inline-size: 144px; overflow-wrap: break-word; overflow:hidden; min-width:0; font-size: 32px",
            ),
        ];
        flat = true,
        bordered = true,
        class = Symbol(
            "($ai == 'A' ? 'bg-blue' : $ai == 'T' ? 'bg-cyan' : $ai == 'G' ? 'bg-teal' : $ai == 'C' ? 'bg-green' : 'bg-pink') + ' column flex-center q-ma-lg'",
        ),
    )

end

function view_variant_information(fi, na, va)

    quasar(
        :card,
        quasar(
            :card__section,
            [
                xelem(:div, na; class = "text-h6"),
                xelem(
                    :img;
                    src = fi,
                    class = "q-ma-sm",
                    style = "height:40px; object-fit: contain;",
                ),
                xelem(:div, va; class = "text-h6 text-indigo q-pt-md"),
            ];
            vertical = true,
            class = "column flex-center",
        );
        flat = true,
        vertical = true,
        class = "col-2 bg-grey-2 flex-center",
    )

end

function view_impact(nu, na, co)

    quasar(
        :card,
        [
            xelem(:div, "$na"; class = "text-h6 text-white q-pa-md"),
            xelem(
                :div,
                "{{$nu}}";
                class = "text-white text-bold q-pb-md ",
                style = "font-size: 32px;",
            ),
        ];
        flat = true,
        class = "col bg-$co q-ma-lg",
        style = "max-width:160px;",
    )

end

const CI_ =
    (modifier = "blue-grey", low = "yellow-8", moderate = "deep-orange", high = "red-8")

function view_impact()

    xelem(
        :div,
        [
            view_impact("im_[0]", "Modifier", CI_[Symbol("modifier")]),
            view_impact("im_[1]", "Low", CI_[Symbol("low")]),
            view_impact("im_[2]", "Moderate", CI_[Symbol("moderate")]),
            view_impact("im_[3]", "High", CI_[Symbol("high")]),
        ];
        class = "row flex-center q-pa-lg",
        style = "max-width: 960px;",
    )

end

function view_variant_button()

    quasar(
        :scroll__area,
        [
            xelem(
                :div,
                @recur("vr in va_"),
                quasar(
                    :btn;
                    size = "md",
                    color! = "ci_[vr.impact]",
                    label! = "vr.id",
                    class = "q-ma-sm",
                    @click("ta = 't1'; va = vr")
                ),
            ),
        ];
        style = "height: 480px",
    )

end

# ---- #

@page "/" path"html/view.jl.html" layout = path"html/layout.html"
