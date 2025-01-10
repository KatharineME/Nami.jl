function view_header()

    quasar(
        :header,
        [
            xelem(
                :div,
                "Window to your genome";
                class = "col-4 text-h6 text-center text-white",
            ),
            xelem(
                :div,
                "Nami";
                class = "col-4 text-center text-white q-mt-lg q-mb-sm",
                style = "font-size: 240%; font-family: fantasy",
            ),
            xelem(
                :div,
                xelem(
                    :div,
                    "Searching {{na}}";
                    class = "text-h6 text-right text-white q-ma-md",
                );
                class = "col-2",
                @showif(:se)
            ),
            quasar(
                :btn;
                outline = true,
                size = "md",
                color = "white",
                label = "Change",
                class = "col-1 justify-end q-ma-md",
                style = "min-width: 80px;",
                @showif(:se),
                @click("up = true; se = false;")
            ),
        ];
        class = "row items-center bg-indigo",
    )

end

function view_tab(na, la)

    quasar(:tab, xelem(:div, la; class = "text-h5 text-black"); name = na)

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
        unelevated = true,
        size = "lg",
        color = "indigo",
        label = "Search",
        class = "q-ma-lg",
        @click("$bu = true")
    )

end

function view_no_variant_found()

    xelem(:div, "No variants found"; class = "text-h4 text-black q-pa-xl", @showif(:em))

end

function view_search_title(st)

    xelem(:div, st; class = "text-h4 text-black q-pt-xl q-pb-lg")

end

function view_allele(al, la)

    ai = "$al"

    xelem(
        :div,
        quasar(
            :card,
            [
                xelem(:div, la; class = "text-h6 text-white q-pa-md"),
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
                "($al == 'A' ? 'bg-blue' : $al == 'T' ? 'bg-cyan' : $al == 'G' ? 'bg-teal' : $al == 'C' ? 'bg-green' : 'bg-pink') + ' column flex-center q-ma-lg'",
            ),
        );
    )

end

function view_variant_information(fi, na, va)

    quasar(
        :card,
        quasar(
            :card__section,
            [
                xelem(:div, na; class = "text-h6 text-center text-charcoal"),
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
        class = "flex-center bg-grey-2 q-mt-md q-mb-md",
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
                    color! = "co_[vi.impact]",
                    label! = "vi.id",
                    class = "q-ma-sm",
                    @click("ta = 't1'; va = vi")
                ),
            ),
        ];
        style = "height: 480px",
    )

end