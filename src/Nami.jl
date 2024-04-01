module Nami

# ----------------------------------------------------------------------------------------------- #
# Variable
# ----------------------------------------------------------------------------------------------- #
# ch: Chromosome :: String
# st: Start position :: Int
# en: End position :: Int

# ----------------------------------------------------------------------------------------------- #
# Sample
# ----------------------------------------------------------------------------------------------- #

const SA = "/path/to/sample/(*.json)"

function list_sample()

    SA

    [("SampleID", "VCFPath", "OtherPromissedValue")]

end

function load_sample(sa)

    SA

    ("SampleID", "VCFPath", "OtherPromissedValue")

end

# ----------------------------------------------------------------------------------------------- #
# Reference Genome
# ----------------------------------------------------------------------------------------------- #

const GR = "/path/to/reference_genome/(fixed_name.fasta, fixed_name.vcf, ...)"

function load_reference_genome()

    GR

    sq

end

# ----------------------------------------------------------------------------------------------- #
# Sample Genome
# ----------------------------------------------------------------------------------------------- #

const GS = "/path/to/sample_genome/(fixed_name.vcf, ...)"

function load_sample_genome()

    GS

    sq

end

# ----------------------------------------------------------------------------------------------- #
# Access
# ----------------------------------------------------------------------------------------------- #

function search_by_region(se, sa, ch, st, en)

end

function search_by_gene(se, sa, ge)

end

function search_by_rsid(se, sa, rs)

end

# ----------------------------------------------------------------------------------------------- #
# Configuration
# ----------------------------------------------------------------------------------------------- #

const CO = "/path/to/configuration.json"

function list_configuration()

    read(CO)

end

function set_configuration!(ke, va)

    read(CO)

    CO[ke] = va

    write(CO)

    nothing

end

# ----------------------------------------------------------------------------------------------- #
# Server
# ----------------------------------------------------------------------------------------------- #

function load_state()

end

function set_state()

end

function run(po)

    SA = if xx == 1

        load_state()

    elseif xx == 2

        "2"

    else

        set_sample()

    end

    TR = load_reference_genome()

    TS = load_sample_genome()

    # TODO: Implement routes.

    # TODO: As the app stops.
    set_state()

end

end
