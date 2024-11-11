using Nami

include("view.jl")

@genietools

# ---- #

const UP = joinpath("public", "upload")

if !isdir(UP)

    mkdir(UP)

end

const DA = joinpath(UP, "variant.db")

# ---- #

@app begin

    @in sr = false

    # ---- #

    db = Nami.DB(DA)

    @event up begin

        Nami.make_variant_table!(
            db,
            mv(fileuploads["path"], joinpath(UP, fileuploads["name"]); force = true),
        )

        sr = true

        @info "sr" sr

    end

    # ---- #

    @in ta = ""

    # ---- #

    @out em = false

    @out sh = false

    # ---- #

    @out rs = ""

    @in ri = 0

    @in cv = false

    @in va = Dict{Symbol, Union{Int, AbstractString}}()

    @out co = ""

    @out cl = ""

    @out po = 0

    @out a0 = ""

    @out a1 = ""

    @out a2 = ""

    @out an = ""

    @out ip = ""

    # ---- #

    @in sy = ""

    @in cg = false

    @out mi = 0

    @out lo = 0

    @out me = 0

    @out hi = 0

    @out va_ = Dict{Symbol, Union{Int, AbstractString}}[]

    # ---- #

    @out ch_ = vcat(string.(collect(range(1, 22))), ["X", "Y", "MT"])

    @in ch = ""

    @in st = 0

    @in en = 0

    @in cr = false

    # ---- #

    @onchange va begin

        @info "" va

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

            sh = true

        end

    end

    @onchange ri, sy, ch, st, en begin

        em = false

        sh = false

    end

    @onbutton cv begin

        va = Nami.get_variant(db, ri)

    end

    @onbutton cg begin

        va_ = Nami.get_variant(db, sy)

        im_ = Nami.count_impact(va_)

        if im_ == (0, 0, 0, 0)

            em = true

        else

            mi, lo, me, hi = im_

            sh = true

        end

    end

    @onbutton cr begin

        va_ = Nami.get_variant(db, ch, st, en)

        im_ = Nami.count_impact(va_)

        if im_ == (0, 0, 0, 0)

            em = true

        else

            mi, lo, me, hi = im_

            sh = true

        end

    end

end

# ---- #

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

function _view_gene()

    join((
        xelem(:h4, "No variants found.", @showif(:em); class = "q-pa-lg"),
        xelem(
            :div,
            [
                xelem(:h4, "Gene {{sy}}"; class = "q-pa-lg"),
                xelem(:h6, "Number of Modifier variants = {{mi}}"),
                xelem(:h6, "Number of Low variants = {{lo}}"),
                xelem(:h6, "Number of Moderate variants = {{me}}"),
                xelem(:h6, "Number of High variants = {{hi}}"),
                xelem(
                    :li,
                    @recur("vr in va_"),
                    quasar(:btn; label! = "vr.id", @click("ta = 't1'; va = vr")),
                ),
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
                xelem(:h6, "Number of Modifier variants = {{mi}}"),
                xelem(:h6, "Number of Low variants = {{lo}}"),
                xelem(:h6, "Number of Moderate variants = {{me}}"),
                xelem(:h6, "Number of High variants = {{hi}}"),
                xelem(
                    :li,
                    @recur("vr in va_"),
                    quasar(:btn; label! = "vr.id", @click("ta = 't1'; va = vr")),
                ),
            ],
            @showif(:sh)
        ),
    ))

end

function _view_uploader()

    join((
        xelem(:h4, "Upload your VCF"; class = "q-pt-lg text-center"),
        xelem(
            :div,
            quasar(
                :uploader;
                accept = "vcf.gz",
                maxfiles = 1,
                url! = "'/____/upload/' + channel_",
                autoupload = true,
                @on("uploaded", :up),
                flat = true,
                bordered = true,
                color = "grey-2",
                text__color = "black",
                style = "max-width: 60%; width: 95%; margin: 0 auto",
            );
            class = "q-pa-lg",
        ),
    ))

end

function _view_tab()

    join((
        xelem(:h4, "Search by"; class = "q-pa-lg text-center", @showif(:sr)),
        quasar(
            :tabs,
            [
                quasar(:tab, xelem(:h6, "Variant"); name = "t1"),
                quasar(:tab, xelem(:h6, "Gene"); name = "t2"),
                quasar(:tab, xelem(:h6, "Region"); name = "t3"),
            ];
            align = "justify",
            no__caps = true,
            indicator__color = "teal-13",
            @bind(:ta),
            @showif(:sr)
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
            @showif(:sr)
        ),
    ))

end

# ---- #

@page "/" view
