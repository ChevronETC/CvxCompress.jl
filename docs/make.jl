push!(LOAD_PATH,"../src/")

using Documenter, CvxCompress

makedocs(
    sitename="CvxCompress",
    modules=[CvxCompress],
    pages = [
        "index.md",
        "manual.md",
        "reference.md",
        "perf/perf.md"
        ]
)

deploydocs(
    repo = "github.com/ChevronETC/CvxCompress.jl.git"
)
