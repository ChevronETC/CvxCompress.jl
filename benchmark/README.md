# Benchmarking
We use [PkgBenchmark.jl](http://github.com/juliaCI/PkgBenchmark.jl) which can be
installed using `Pkg.add("PkgBenchmark")`.  To run the benchmarks:
```julia
using PkgBenchmark
benchmarks = include("benchmarks.jl")
results=benchmarkpkg("CvxCompress", BenchmarkConfig(
    env=Dict("OMP_NUM_THREADS"=>Sys.CPU_THREADS, "OMP_PROC_BIND"=>"close")))
export_markdown("results.md", results)
export_markdown_mcells("results_mcells.md", results)
```
In order to compare the benchmarks against a different version:
```julia
results=judge("CvxCompress", "master")
export_markdown("results.md", results)
```
where `master` is a Git SHA or the name of a Git branch.  To run a specific
benchmark:
```julia
benchmarks=include("benchmarks.jl")
run(benchmarks.data["compression, 3D"]["compress, F32"])
```

You can profile a benchmark.  For example:
```julia
benchmarks=include("benchmarks.jl")
using Profile
@profile run(benchmarks.data["compression, 3D"]["compress, F32"])
```
Use `Profile.print()` and `using ProfileView; ProfileView.view()` to inspect the
profile.  Note that `ProfileView.view()` requires
[ProfileView.jl](http://github.com/timholy/ProfileView.jl).

For more information, please see the documentation for
[PkgBenchmark.jl](http://github.com/juliaCI/PkgBenchmark.jl) and
[BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).

# Notes
CvxCompress uses OpenMP for threading, and the `OMP_NUM_THREADS` environment
variable to determine the number of threads to run with.  Please ensure that
you set the `OMP_NUM_THREADS` variable appropriately.

