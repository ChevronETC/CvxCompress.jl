using BenchmarkTools, CvxCompress, LinearAlgebra, Pkg

wavefields = Pkg.artifact"wavefields"
p3d = read!(joinpath(wavefields, "field_3D_for_compression_Float32_201x401x101.bin"), Array{Float32,3}(undef,201,401,101))
p2d = read!(joinpath(wavefields, "field_2D_for_compression_Float32_352x688.bin"), Array{Float32,2}(undef,352,688))

p3d_compressed = Vector{UInt32}(undef, length(p3d))
p2d_compressed = Vector{UInt32}(undef, length(p2d))

p3d_decompressed = similar(p3d)
p2d_decompressed = similar(p2d)

compressor_3d = CvxCompressor((32,32,32), 1e-2)
compressor_2d = CvxCompressor((32,32), 1e-2)

const SUITE = BenchmarkGroup()

n_2d = compress!(p2d_compressed, compressor_2d, p2d)
decompress!(p2d_decompressed, compressor_2d, p2d_compressed, n_2d)
ratio_2d = length(p2d) / n_2d
snr_2d = 20*log10(norm(p2d) / norm(p2d - p2d_decompressed))

SUITE["compression, 2D"] = BenchmarkGroup([Dict("compression ratio"=>ratio_2d, "signal-to-noise ratio"=>snr_2d, "ncells"=>length(p2d))])
SUITE["compression, 2D"]["compress, F32"] = @benchmarkable compress!($p2d_compressed, $compressor_2d, $p2d)
SUITE["compression, 2D"]["decompress, F32"] = @benchmarkable decompress!($p2d_decompressed, $compressor_2d, $p2d_compressed, $n_2d)

n_3d = compress!(p3d_compressed, compressor_3d, p3d)
decompress!(p3d_decompressed, compressor_3d, p3d_compressed, n_3d)
ratio_3d = length(p3d) / n_3d
snr_3d = 20*log10(norm(p3d) / norm(p3d - p3d_decompressed))

SUITE["compression, 3D"] = BenchmarkGroup([Dict("compression ratio"=>ratio_3d, "signal-to-noise ratio"=>snr_3d, "ncells"=>length(p3d))])
SUITE["compression, 3D"]["compress, F32"] = @benchmarkable compress!($p3d_compressed, $compressor_3d, $p3d)
SUITE["compression, 3D"]["decompress, F32"] = @benchmarkable decompress!($p3d_decompressed, $compressor_3d, $p3d_compressed, $n_3d)

include(joinpath(pkgdir(CvxCompress), "benchmark", "mcells_per_second.jl"))

SUITE