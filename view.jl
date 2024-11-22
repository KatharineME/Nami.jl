function _view_input(ty, la, hi, bi)

    quasar(
        :input;
        type = ty,
        label = la,
        hint = hi,
        outlined = true,
        bg__color = "grey-2",
        clearable = true,
        class = "q-pa-sm",
        @bind(bi)
    )

end

function _view_search_button(bu)

    quasar(
        :btn;
        size = "lg",
        color = "teal-13",
        label = "Search",
        class = "q-mt-lg",
        @click("$bu = true")
    )

end

function _view_allele(al)

    ai = "$al"

    quasar(
        :btn;
        size = "xl",
        color! = "ca_[$ai]",
        label! = al,
        class = "q-ma-sm",
        style = "",
    )

end

function _view_impact(nu, na, co)

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

function _view_impacts()

    xelem(
        :div,
        [
            _view_impact("im_[0]", "Modifier", IM[Symbol("modifier")]),
            _view_impact("im_[1]", "Low", IM[Symbol("low")]),
            _view_impact("im_[2]", "Moderate", IM[Symbol("moderate")]),
            _view_impact("im_[3]", "High", IM[Symbol("high")]),
        ];
        class = "row flex-center q-pa-lg",
        style = "max-width: 960px;",
    )

end

function _view_variant_buttons()

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
