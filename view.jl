const CO =
    (modifier = "blue-grey", low = "yellow-8", moderate = "deep-orange", high = "red-8")


function _view_variant()

    join((
        xelem(:h4, "No variant found.", @showif(:em); class = "q-pa-lg"),
        xelem(
            :div,
            [
                xelem(:h4, "Variant {{rs}}"; class = "q-pa-lg"),
                xelem(:h6, "Chromosome = {{co}}"),
                xelem(:h6, "Closest gene = {{cl}}"),
                xelem(:h6, "Position = {{po}}"),
                xelem(:h6, "Reference allele = {{a0}}"),
                xelem(:h6, "Your allele 1 = {{a1}}"),
                xelem(:h6, "Your allele 2 = {{a2}}"),
                xelem(:h6, "Effect = {{an}}"),
                xelem(:h6, "Impact = {{ip}}"),
            ],
            @showif(:sh)
        ),
    ))

end

function _view_impact(nu, na, co)

    quasar(
        :card,
        join((
            xelem(:h1, "{{$nu}}"; class = "q-pa-sm text-white"),
            xelem(:h4, "$na"; class = "q-pb-md text-white"),
        ));
        class = "bg-$co col",
        style = "max-width:160px;",
    )

end

function _view_impacts()

    xelem(
        :div,
        [
            _view_impact("im_[0]", "Modifier", CO[Symbol("modifier")]),
            _view_impact("im_[1]", "Low", CO[Symbol("low")]),
            _view_impact("im_[2]", "Moderate", CO[Symbol("moderate")]),
            _view_impact("im_[3]", "High", CO[Symbol("high")]),
        ];
        class = "row justify-evenly q-pa-lg",
    )

end

function _view_variant_buttons()

    xelem(
        :div,
        @recur("vr in va_"),
        quasar(
            :btn;
            label! = "vr.id",
            color! = "co_[vr.impact]",
            size = "md",
            class = "q-ma-md",
            @click("ta = 't1'; va = vr")
        ),
    )

end

function _view_gene()

    join((
        xelem(:h4, "No variants found.", @showif(:em); class = "q-pa-lg"),
        xelem(
            :div,
            [
                xelem(:h4, "Gene {{sy}}"; class = "q-pa-lg"),
                _view_impacts(),
                _view_variant_buttons(),
            ],
            @showif(:sh)
        ),
    ))

end

function _view_region()

    join((
        xelem(:h4, "No variants found.", @showif(:em); class = "q-pa-lg"),
        xelem(
            :div,
            [
                xelem(:h4, "Region {{ch}}:{{st}}-{{en}}"; class = "q-pa-lg"),
                _view_impacts(),
                _view_variant_buttons(),
            ],
            @showif(:sh)
        ),
    ))

end

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
                @on("uploaded", :up),
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
            xelem(:h6, "Using VCF: {{fi}}"; class = "q-pa-sm text-center col-3"),
            quasar(
                :btn;
                label = "Change",
                size = "md",
                color = "grey",
                class = "left-align col-2",
                @click("su = true; ss = false")
            ),
        ];
        class = "row flex-center",
        @showif(:ss)
    )))

end

function _view_tab()

    join((
        xelem(:h1, "Search"; class = "q-pa-lg text-center", @showif(:ss)),
        quasar(
            :tabs,
            [
                quasar(:tab, xelem(:h4, "Variant"); name = "t1"),
                quasar(:tab, xelem(:h4, "Gene"); name = "t2"),
                quasar(:tab, xelem(:h4, "Region"); name = "t3"),
            ];
            align = "justify",
            no__caps = true,
            active__bg__color = "teal-1",
            indicator__color = "teal-13",
            @bind(:ta),
            @showif(:ss)
        ),
    ))

end

function _view_tab_panel()

    join((
        xelem(
            :div,
            quasar(
                Symbol("tab-panels"),
                [
                    quasar(
                        Symbol("tab-panel"),
                        [
                            quasar(
                                :input;
                                class = "q-pa-lg",
                                outlined = true,
                                bg__color = "grey-2",
                                label = "rsID",
                                hint = "rs625655",
                                prefix = "rs",
                                clearable = true,
                                @bind(:ri)
                            ),
                            quasar(
                                :btn;
                                size = "lg",
                                color = "teal-13",
                                label = "Search",
                                @click(:cv)
                            ),
                            _view_variant(),
                        ];
                        name = "t1",
                    ),
                    quasar(
                        Symbol("tab-panel"),
                        [
                            quasar(
                                :input;
                                class = "q-pa-lg",
                                outlined = true,
                                bg__color = "grey-2",
                                label = "Symbol",
                                hint = "UBR3",
                                clearable = true,
                                @bind(:sy)
                            ),
                            quasar(
                                :btn;
                                size = "lg",
                                color = "teal-13",
                                label = "Search",
                                @click("cg = !cg")
                            ),
                            _view_gene(),
                        ];
                        name = "t2",
                    ),
                    quasar(
                        Symbol("tab-panel"),
                        [
                            quasar(
                                :select;
                                class = "q-pa-lg",
                                outlined = true,
                                bg__color = "grey-2",
                                label = "Chromosome",
                                options = :ch_,
                                clearable = true,
                                @bind(:ch)
                            ),
                            quasar(
                                :input;
                                class = "q-pa-lg",
                                outlined = true,
                                bg__color = "grey-2",
                                label = "Start",
                                type = "number",
                                clearable = true,
                                @bind(:st)
                            ),
                            quasar(
                                :input;
                                class = "q-pa-lg",
                                outlined = true,
                                bg__color = "grey-2",
                                label = "End",
                                type = "number",
                                clearable = true,
                                @bind(:en)
                            ),
                            quasar(
                                :btn;
                                size = "lg",
                                color = "teal-13",
                                label = "Search",
                                @click("cr = !cr")
                            ),
                            _view_region(),
                        ];
                        name = "t3",
                    ),
                ];
                @bind(:ta),
                animated = true,
            );
            class = "text-center",
            @showif(:ss)
        ),
    ))

end

function view()

    [
        xelem(:h1, "Nami"; class = "q-pa-lg text-center"),
        xelem(:h6, "Window to your genome"; class = "q-pb-lg text-center", @showif(:su)),
        _view_uploader(),
        _view_vcf_path(),
        _view_tab(),
        _view_tab_panel(),
    ]

end
