using Nami

@genietools

using VCF: DB, count_impact, get_variant, make_variant_table!

# ---- #

const UP = joinpath("public", "upload")

if !isdir(UP)

    mkdir(UP)

end

# ---- #

const PA = joinpath(UP, "vcf.db")

# ---- #

@app begin

    @out db = DB(PA)

    @event up begin

        make_variant_table!(
            db,
            mv(fileuploads["path"], joinpath(UP, fileuploads["name"]); force = true),
        )

    end

    # ---- #

    @in ta = ""

    # ---- #

    @out rs = ""

    @in ri = 0

    @in cv = false

    # ---- #

    @in va = Dict{Symbol, Union{Int, AbstractString}}()

    @out co = ""

    @out po = 0

    @out a0 = ""

    # TODO: Report more interpretable text
    @out qu = 0

    @out cl = ""

    @out a1 = ""

    @out a2 = ""

    @out an = ""

    @out ip = ""

    @onchange va begin

        co = va[:chrom]

        po = va[:pos]

        rs = va[:id]

        ri = parse(Int, rs[3:end])

        a0 = va[:ref]

        qu = va[:qual]

        cl = va[:gene]

        a1 = va[:allele_1]

        a2 = va[:allele_2]

        an = va[:annotation]

        ip = va[:impact]

    end

    # ---- #

    @onbutton cv begin

        @info "Searching variant $rs"

        va = get_variant(db, ri)

    end

    # ---- #

    @in sy = ""

    @in cg = false

    # ---- #

    @out ui = 0

    @out ul = 0

    @out ue = 0

    @out uh = 0

    @out va_ = Dict{Symbol, Union{Int, AbstractString}}[]

    @out vb_ = String[]

    # ---- #

    @onbutton cg begin

        @info "Searching gene $sy"

        va_ = get_variant(db, sy)

        ui, ul, ue, uh = count_impact(va_)

    end

    # ---- #

    # TODO: Hard-code in view
    @out ch_ = [
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        "11",
        "12",
        "13",
        "14",
        "15",
        "16",
        "17",
        "18",
        "19",
        "20",
        "21",
        "22",
        "X",
        "Y",
        "MT",
    ]

    @in ch = ""

    @in st = 0

    @in en = 0

    @in cr = false

    # ---- #

    # ---- #

    @onbutton cr begin

        @info "Searching region $ch:$st-$en"

        va_ = get_variant(db, ch, st, en)

        ui, ul, ue, uh = count_impact(va_)

    end

end

# TODO: Handle not-found cases

function _view_variant()

    join((
        xelem(:h4, "Variant = {{rs}}"),
        xelem(:p, "Chromosome = {{co}}"),
        xelem(:p, "Position = {{po}}"),
        xelem(:p, "Quality = {{qu}}"),
        xelem(:p, "Reference allele = {{a0}}"),
        xelem(:p, "Your allele 1 = {{a1}}"),
        xelem(:p, "Your allele 2 = {{a2}}"),
        xelem(:p, "Annotation = {{an}}"),
        xelem(:p, "Impact = {{ip}}"),
        xelem(:p, "Closest gene = {{cl}}"),
    ))

end

function _view_gene()

    join((
        xelem(:h4, "Gene = {{sy}}"),
        xelem(:p, "# Modifier = {{ui}}"),
        xelem(:p, "# Low = {{ul}}"),
        xelem(:p, "# Moderate = {{ue}}"),
        xelem(:p, "# High = {{uh}}"),
        xelem(
            :li,
            @recur("vr in va_"),
            quasar(:btn; label! = "vr.id", @click("ta = 't1'; va = vr")),
        ),
    ))

end

function _view_region()

    join((
        xelem(:h4, "Region = {{ch}}:{{st}}-{{en}}"),
        xelem(:p, "# Modifier = {{ui}}"),
        xelem(:p, "# Low = {{ul}}"),
        xelem(:p, "# Moderate = {{ue}}"),
        xelem(:p, "# High = {{uh}}"),
        xelem(
            :li,
            @recur("vr in va_"),
            quasar(:btn; label! = "vr.id", @click("ta = 't1'; va = vr")),
        ),
    ))

end

function view()

    [
        xelem(:h1, "🌊 Nami"),
        quasar(:separator),
        xelem(:h4, "🔧 Setting"),
        quasar(
            :uploader;
            label = "⬆️ Upload your VCF file",
            autoupload = true,
            url! = "'/____/upload/' + channel_",
            @on(:uploaded, :up),
            maxfiles = 1,
        ),
        # TODO
        xelem(:p, "🗃️ VCF database status = {{}}"),
        quasar(:separator),
        xelem(:h4, "🔬 Search"),
        quasar(
            :tabs,
            [
                quasar(:tab; label = "1️⃣ Variant", name = "t1"),
                quasar(:tab; label = "2️⃣ Gene", name = "t2"),
                quasar(:tab; label = "3️⃣ Region", name = "t3"),
            ];
            @bind(:ta),
        ),
        quasar(
            Symbol("tab-panels"),
            [
                quasar(
                    Symbol("tab-panel"),
                    [
                        quasar(:input; label = "RSID", prefix = "rs", @bind(:ri)),
                        quasar(:btn; label = "🤩 Search", @click(:cv)),
                        _view_variant(),
                    ];
                    name = "t1",
                ),
                quasar(
                    Symbol("tab-panel"),
                    [
                        quasar(:input; label = "Symbol", @bind(:sy)),
                        quasar(:btn; label = "🤩 Search", @click(:cg)),
                        _view_gene(),
                    ];
                    name = "t2",
                ),
                quasar(
                    Symbol("tab-panel"),
                    [
                        quasar(:select; label = "Chromosome", options = :ch_, @bind(:ch)),
                        quasar(:input; label = "Start", type = "number", @bind(:st)),
                        quasar(:input; label = "End", type = "number", @bind(:en)),
                        quasar(:btn; label = "🤩 Search", @click(:cr)),
                        _view_region(),
                    ];
                    name = "t3",
                ),
            ];
            @bind(:ta),
            animated = true,
        ),
    ]

end

# TODO: Use custom layout with favicon, title, and other goodies
@page "/" view
