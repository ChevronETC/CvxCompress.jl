push!(LOAD_PATH,"../src/")

using Documenter, CvxCompress

makedocs(
    sitename="CvxCompress.jl",
    modules=[CvxCompress],
    pages = [
        "Home" => "index.md",
        "User Guide" => "manual.md",
        "reference.md",
        "Performance" => "perf/perf.md"
        ]
)

deploydocs(
    repo = "github.com/ChevronETC/CvxCompress.jl"
)
