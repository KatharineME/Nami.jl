using SQLite: DB

using SQLite.DBInterface: close!

using Nami

@genietools

#

const UP = pkgdir(Nami, "public", "upload")

const CO_ = Dict("Modifier" => "ey", "Low" => "ye", "Moderate" => "or", "High" => "re")

#
#

@app begin

    @in b1 = true #show uploader

    @in b2 = false #show spinner

    @in b3 = false #show search

    @in na = ""

    @in db = DB()

    #

    @in ta = ""

    @out b4 = false #if empty

    @out b5 = false #show result

    #

    @in va = Dict{Symbol, Union{Int, AbstractString}}()

    @in r1 = ""

    @out r2 = ""

    @in u1 = false

    #

    @out va_ = Dict{Symbol, Union{Int, AbstractString}}[]

    #

    @in ge = ""

    @in u2 = false

    #

    @out ch_ = vcat(string.(collect(range(1, 22))), ["X", "Y", "MT"])

    @in ch = ""

    @in st = 0

    @in en = 0

    @in u3 = false

    #

    @out co_ = CO_

    @out im_ = (0, 0, 0, 0)

    #

    @onchange r1, ge, ch, st, en begin

        b4 = false

        b5 = false

    end

    @onchange va begin

        if isempty(va)

            b4 = true

        else

            r2 = va[:ID]

            b5 = true

        end

    end

    @onbutton u1 begin

        va = Nami.get_variant_by_id(db, r1)

    end

    @onchange va_ begin

        im_ = Nami.get_impact(va_)

        if im_ == (0, 0, 0, 0)

            b4 = true

        else

            b5 = true

        end

    end

    @onbutton u2 begin

        ge = uppercase(ge)

        va_ = Nami.get_variant(db, ge)

    end

    @onbutton u3 begin

        va_ = Nami.get_variant(db, ch, st, en)

    end

end

#

@event :up begin

    b1 = false

    b2 = true

    na = fileuploads["name"]

    close!(db)

    db = DB(mv(fileuploads["path"], joinpath(UP, na); force = true))

end

@event :fi begin

    b2 = false

    b3 = true

end

#

function view_tab(na, st)

    quasar(:tab, xelem(:div, st; class = "text-h5 text-bold text-white"); name = na)

end

function view_header()

    quasar(
        :header,
        [
            xelem(
                :div,
                quasar(
                    :btn;
                    unelevated = true,
                    size = "lg",
                    icon = "home",
                    class = "text-h6 text-white text-center",
                    style = "min-width:200px; width:fit-content;",
                    @click("b1 = false; b3 = true;")
                );
                class = "col-3 flex flex-center",
            ),
            quasar(
                :tabs,
                [
                    view_tab("t1", "Variant"),
                    view_tab("t2", "Gene"),
                    view_tab("t3", "Region"),
                ];
                no__caps = true,
                active__bg__color = "deep-purple-12",
                indicator__color = "li",
                align = "justify",
                class = "col-6",
                style = "min-height:80px;",
                @bind(:ta),
                @showif(:b3),
            ),
            xelem(
                :div,
                "Nami";
                class = "col-6 text-center text-white q-mt-lg q-mb-sm",
                style = "font-size: 200%; font-family: fantasy",
                @showif(:b1),
            ),
            xelem(
                :div,
                quasar(
                    :btn;
                    outline = true,
                    size = "md",
                    icon = "close",
                    label! = "na",
                    class = "btn",
                    style = "min-width: 100px; max-width: 300px; width: fit-content;",
                    @showif(:b3),
                    @click("b1 = true; b3 = false;")
                );
                class = "col-3 flex flex-center",
            ),
        ];
        class = "row items-center bg-in",
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
        @bind(bi),
    )

end

function view_search_button(bu)

    quasar(
        :btn;
        unelevated = true,
        size = "lg",
        color = "in",
        label = "Search",
        class = "q-ma-lg btn",
        @click("$bu = true")
    )

end

function view_no_variant_found()

    xelem(:div, "No variants found"; class = "text-h4 text-black q-pa-xl", @showif(:b4))

end

function view_search_title(st)

    xelem(:div, st; class = "text-h4 text-black q-pt-xl q-pb-lg")

end

function view_allele(al, st)

    xelem(
        :div,
        quasar(
            :card,
            [
                xelem(:div, st; class = "text-h6 text-white q-pa-md"),
                xelem(
                    :div,
                    "{{$al}}";
                    class = "text-bold text-white q-pb-md q-ma-sm",
                    style = "inline-size: 144px; overflow-wrap: break-word; overflow:hidden; min-width:0; font-size: 32px",
                ),
            ];
            flat = true,
            bordered = true,
            class = Symbol(
                "($al == 'A' ? 'bg-g1' : $al == 'T' ? 'bg-g2' : $al == 'G' ? 'bg-b1' : $al == 'C' ? 'bg-b2' : 'bg-pi') + ' column flex-center q-ma-lg'",
            ),
        );
    )

end

function view_variant_information(s1, im, s2)

    quasar(
        :card,
        quasar(
            :card__section,
            [
                xelem(:div, s1; class = "text-h6 text-center text-dark"),
                xelem(
                    :img;
                    src = im,
                    class = "q-ma-sm",
                    style = "height:40px; object-fit: contain;",
                ),
                xelem(:div, s2; class = "text-h6 text-in q-pt-md"),
            ];
            vertical = true,
            class = "column flex-center",
        );
        flat = true,
        vertical = true,
        class = "flex-center bg-grey-2 q-mt-md q-mb-md q-pa-md",
    )

end

function view_impact(nu, st, co)

    quasar(
        :card,
        [
            xelem(:div, st; class = "text-h6 text-white q-pa-md"),
            xelem(
                :div,
                "{{$nu}}";
                class = "text-bold text-white q-pb-md ",
                style = "font-size: 32px;",
            ),
        ];
        flat = true,
        class = "col bg-$co q-ma-lg",
        style = "max-width:160px; min-width:120px;",
    )

end

function view_impact()

    xelem(
        :div,
        [
            view_impact("im_[0]", "Modifier", CO_["Modifier"]),
            view_impact("im_[1]", "Low", CO_["Low"]),
            view_impact("im_[2]", "Moderate", CO_["Moderate"]),
            view_impact("im_[3]", "High", CO_["High"]),
        ];
        class = "row flex-center q-pa-lg",
    )

end

function view_variant_button()

    quasar(
        :scroll__area,
        [
            xelem(
                :div,
                @recur("vi in va_"),
                quasar(
                    :btn;
                    unelevated = true,
                    size = "md",
                    color! = "co_[vi.Impact]",
                    label! = "vi.ID",
                    class = "q-ma-sm",
                    @click("ta = 't1'; va = vi;")
                ),
            ),
        ];
        style = "height: 480px",
    )

end

function update!(se)

    while true

        rm.(readdir(UP; join = true), recursive = true)

        sleep(se)

    end

end

@async update!(10)

#

@page "/" path"html/view.html" layout = path"html/layout.html"
