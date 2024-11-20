function _view_uploader()

    join((
        xelem(:h4, "Upload your VCF"; class = "q-pt-lg text-center", @showif(:su)),
        xelem(
            :div,
            quasar(
                :uploader;
                accept = "vcf.gz",
                maxfiles = 1,
                url! = "'/____/upload/' + channel_",
                autoupload = true,
                flat = true,
                bordered = true,
                color = "grey-2",
                text__color = "black",
                style = "max-width: 60%; width: 95%; margin: 0 auto",
                @on("uploaded", :up)
            );
            class = "q-pa-lg",
            @showif(:su)
        ),
    ))

end

function _view_vcf_path()

    join((xelem(
        :div,
        [
            xelem(:h6, "Searching 🧬 {{fi}}"; class = "q-ma-md"),
            quasar(
                :btn;
                label = "Change",
                size = "md",
                color = "grey-5",
                class = "q-ma-md",
                @click("su = true; ss = false")
            ),
        ];
        class = "flex flex-center",
        @showif(:ss)
    )))

end

function _view_tab()

    join((xelem(
        :div,
        quasar(
            :tabs,
            [
                quasar(:tab, xelem(:h4, "Variant"); name = "t1"),
                quasar(:tab, xelem(:h4, "Gene"); name = "t2"),
                quasar(:tab, xelem(:h4, "Region"); name = "t3"),
            ];
            align = "justify",
            no__caps = true,
            active__bg__color = "grey-2",
            indicator__color = "grey-2",
            class = "col-12",
            style = "max-width: 960px;",
            @bind(:ta),
            @showif(:ss)
        );
        class = "row flex-center",
    )))

end

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

function _view_allele(al, la, co)

    quasar(
        :card,
        [
            xelem(:h1, "{{$al}}"; class = "q-pa-md text-white"),
            xelem(:h4, "$la"; class = "q-pb-md text-white"),
        ];
        flat = true,
        class = "bg-$co col q-ma-lg",
        style = "max-width:160px;",
    )

end

function _view_variant()

    join((
        xelem(:h4, "No variant found", @showif(:em); class = "q-pt-xl"),
        xelem(
            :div,
            [
                xelem(:h4, "Variant {{rs}}"; class = "q-pt-xl q-pb-lg"),
                xelem(
                    :div,
                    [
                        _view_allele("a0", "Reference", "green-6"),
                        _view_allele("a1", "Your Allele 1", "cyan-6"),
                        _view_allele("a2", "Your Allele 2", "cyan-6"),
                    ];
                    class = "row justify-center q-pa-lg",
                ),
                xelem(:h6, "Chromosome = {{co}}"; class = "q-pa-sm"),
                xelem(:h6, "Closest gene = {{cl}}"; class = "q-pa-sm"),
                xelem(:h6, "Position = {{po}}"; class = "q-pa-sm"),
                xelem(:h6, "Effect = {{an}}"; class = "q-pa-sm"),
                xelem(:h6, "Impact = {{ip}}"; class = "q-pa-sm"),
            ],
            @showif(:sr)
        ),
    ))

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

function _view_gene()

    join((
        xelem(:h4, "No variants found", @showif(:em); class = "q-pa-xl"),
        xelem(
            :div,
            [
                xelem(:h4, "Gene {{sy}}"; class = "q-pt-xl q-pb-lg"),
                _view_impacts(),
                _view_variant_buttons(),
            ],
            @showif(:sr)
        ),
    ))

end

function _view_region()

    join((
        xelem(:h4, "No variants found", @showif(:em); class = "q-pa-xl"),
        xelem(
            :div,
            [
                xelem(:h4, "Region {{ch}}:{{st}}-{{en}}"; class = "q-pt-xl q-pb-lg"),
                _view_impacts(),
                _view_variant_buttons(),
            ],
            @showif(:sr)
        ),
    ))

end

function _view_tab_panel()

    join((xelem(
        :div,
        quasar(
            Symbol("tab-panels"),
            [
                quasar(
                    Symbol("tab-panel"),
                    [
                        _view_input("text", "rsID", "rs625655", :ri),
                        _view_search_button(:cv),
                        _view_variant(),
                    ];
                    name = "t1",
                ),
                quasar(
                    Symbol("tab-panel"),
                    [
                        _view_input("text", "Symbol", "UBR3", :sy),
                        _view_search_button(:cg),
                        _view_gene(),
                    ];
                    name = "t2",
                ),
                quasar(
                    Symbol("tab-panel"),
                    [
                        quasar(
                            :select;
                            options = :ch_,
                            label = "Chromosome",
                            outlined = true,
                            bg__color = "grey-2",
                            clearable = true,
                            class = "q-pa-sm",
                            @bind(:ch)
                        ),
                        _view_input("number", "Start", "", :st),
                        _view_input("number", "End", "", :en),
                        _view_search_button(:cr),
                        _view_region(),
                    ];
                    name = "t3",
                ),
            ];
            class = "col-12",
            style = "max-width: 960px;",
            @bind(:ta),
            animated = true,
        );
        class = "row flex-center text-center",
        @showif(:ss)
    )))

end

function view()

    [
        xelem(:h1, "Nami"; class = "q-pt-lg text-center", style = "font-family: fantasy;"),
        xelem(:h6, "Window to your genome"; class = "q-pb-lg text-center", @showif(:su)),
        _view_uploader(),
        _view_vcf_path(),
        xelem(:space; class = "q-pa-lg"),
        _view_tab(),
        _view_tab_panel(),
        xelem(:space; class = "q-pa-lg"),
    ]

end
