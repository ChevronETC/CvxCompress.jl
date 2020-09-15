var documenterSearchIndex = {"docs":
[{"location":"perf/perf/#Performance-results:","page":"Performance","title":"Performance results:","text":"","category":"section"},{"location":"perf/perf/#D,-SEAM","page":"Performance","title":"3D, SEAM","text":"","category":"section"},{"location":"perf/perf/","page":"Performance","title":"Performance","text":"(Image: Perf) (Image: Perf zoom)","category":"page"},{"location":"perf/perf/","page":"Performance","title":"Performance","text":"(Image: model) (Image: fields)","category":"page"},{"location":"perf/perf/#D,-Sigsbee","page":"Performance","title":"2D, Sigsbee","text":"","category":"section"},{"location":"perf/perf/","page":"Performance","title":"Performance","text":"(Image: Perf) (Image: Perf zoom)","category":"page"},{"location":"perf/perf/","page":"Performance","title":"Performance","text":"(Image: model) (Image: fields)","category":"page"},{"location":"manual/#Manual","page":"User Guide","title":"Manual","text":"","category":"section"},{"location":"manual/#Obtaining-CvxCompress.jl","page":"User Guide","title":"Obtaining CvxCompress.jl","text":"","category":"section"},{"location":"manual/","page":"User Guide","title":"User Guide","text":"From the Julia prompt, ]add CvxCompress\n(optional) From the Julia prompt ]dev CvxCompress","category":"page"},{"location":"manual/#Building-CvxCompress.jl","page":"User Guide","title":"Building CvxCompress.jl","text":"","category":"section"},{"location":"manual/","page":"User Guide","title":"User Guide","text":"CvxCompress.jl depends on CvxCompress, written by Thor Johnsen.  To re-download and re-build CvxCompress, do:","category":"page"},{"location":"manual/","page":"User Guide","title":"User Guide","text":"]build CvxCompress","category":"page"},{"location":"manual/#Using-CvxCompress.jl","page":"User Guide","title":"Using CvxCompress.jl","text":"","category":"section"},{"location":"manual/#D","page":"User Guide","title":"3D","text":"","category":"section"},{"location":"manual/","page":"User Guide","title":"User Guide","text":"using CvxCompress\n\nn1,n2,n3 = 100,200,300\nvolume = rand(Float32,n1,n2,n3)\ncompressed_volume = zeros(UInt32,n1*n2*n3)\ndecompressed_volume = zeros(Float32,n1,n2,n3)\n\nb1,b2,b3,scale=16,16,16,1e-3\nc = CvxCompressor((b1,b2,b3), scale)\nnbytes = compress!(compressed_volume, c, volume)\ndecompress!(decompressed_volume, c, compressed_volume)","category":"page"},{"location":"manual/#D-2","page":"User Guide","title":"2D","text":"","category":"section"},{"location":"manual/","page":"User Guide","title":"User Guide","text":"using CvxCompress\n\nnz,nx = 100,300\nvolume = rand(Float32,n1,n2)\ncompressed_volume = zeros(UInt32,n1*n2)\ndecompressed_volume = zeros(Float32,n1,n2)\n\nc = CvxCompressor((b1,b2),scale)\nnbytes = compress!(compressed_volume, c, volume)\ndecompress!(decompressed_volume, c, compressed_volume)","category":"page"},{"location":"manual/#Options","page":"User Guide","title":"Options","text":"","category":"section"},{"location":"manual/","page":"User Guide","title":"User Guide","text":"In the above examples we have,","category":"page"},{"location":"manual/","page":"User Guide","title":"User Guide","text":"b1=32,b2=32,b3=32 block size used for compression where b1 is fast and b3 is slow.  These must be powers of 2, and between 8 and 256.\nscale=1e-2 scale factor used to determine the thresholding of the wavelet coefficients","category":"page"},{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"Modules = [CvxCompress]\nOrder = [:function]","category":"page"},{"location":"reference/#Base.copy-Union{Tuple{CvxCompressor{N}}, Tuple{N}} where N","page":"Reference","title":"Base.copy","text":"copy(c::CvxCompressor{N})\n\nCreate a copy of a CvxCompressor struct\n\n\n\n\n\n","category":"method"},{"location":"reference/#CvxCompress.compress!-Tuple{Array{UInt32,1},CvxCompressor{2},Array{Float32,2}}","page":"Reference","title":"CvxCompress.compress!","text":"compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{2}, volume::Array{Float32,2})\n\n2D compression of a volume\n\n\n\n\n\n","category":"method"},{"location":"reference/#CvxCompress.compress!-Tuple{Array{UInt32,1},CvxCompressor{2},Array{Float64,2}}","page":"Reference","title":"CvxCompress.compress!","text":"compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{2}, volume::Array{Float64,2})\n\n2D compression of a volume\n\n\n\n\n\n","category":"method"},{"location":"reference/#CvxCompress.compress!-Tuple{Array{UInt32,1},CvxCompressor{3},Array{Float32,3}}","page":"Reference","title":"CvxCompress.compress!","text":"compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{3}, volume::Array{Float32,3})\n\n3D compression of a volume\n\n\n\n\n\n","category":"method"},{"location":"reference/#CvxCompress.compress!-Tuple{Array{UInt32,1},CvxCompressor{3},Array{Float64,3}}","page":"Reference","title":"CvxCompress.compress!","text":"compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{3}, volume::Array{Float64,3})\n\n3D compression of a volume\n\n\n\n\n\n","category":"method"},{"location":"reference/#CvxCompress.decompress!-Tuple{Array{Float32,2},CvxCompressor{2},Array{UInt32,1},Integer}","page":"Reference","title":"CvxCompress.decompress!","text":"decompress!(volume::Array{Float32,2}, c::CvxCompressor{2}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)\n\n2D de-compression of a volume\n\n\n\n\n\n","category":"method"},{"location":"reference/#CvxCompress.decompress!-Tuple{Array{Float32,3},CvxCompressor{3},Array{UInt32,1},Integer}","page":"Reference","title":"CvxCompress.decompress!","text":"decompress!(volume::Array{Float32,3}, c::CvxCompressor{3}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)\n\n3D de-compression of a volume\n\n\n\n\n\n","category":"method"},{"location":"reference/#CvxCompress.decompress!-Tuple{Array{Float64,2},CvxCompressor{2},Array{UInt32,1},Integer}","page":"Reference","title":"CvxCompress.decompress!","text":"decompress!(volume::Array{Float64,2}, c::CvxCompressor{2}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)\n\n2D de-compression of a volume\n\n\n\n\n\n","category":"method"},{"location":"reference/#CvxCompress.decompress!-Tuple{Array{Float64,3},CvxCompressor{3},Array{UInt32,1},Integer}","page":"Reference","title":"CvxCompress.decompress!","text":"decompress!(volume::Array{Float64,3}, c::CvxCompressor{3}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)\n\n3D de-compression of a volume\n\n\n\n\n\n","category":"method"},{"location":"reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"","category":"page"},{"location":"#CvxCompress.jl","page":"Home","title":"CvxCompress.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Thin wrapper around CvxCompress written by Thor Johnsen.","category":"page"}]
}
