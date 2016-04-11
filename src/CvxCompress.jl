__precompile__()

module CvxCompress

import Base.copy

const _jl_libcvxcompress = normpath(joinpath(Base.source_path(), "../../deps/usr/lib/libcvxcompress"))

type CvxCompressor
	bz::Int64
	by::Int64
	bx::Int64
	scale::Float32
end
function CvxCompressor(;bz::Integer=32,by::Integer=32,bx::Integer=32,scale::Real=1e-2)
	if bz < 8 || bz > 256 || nextpow(2,bz) != bz
		throw(ArgumentError("must have 8 <= bz <= 256, and bz must be a power of 2 got bz=$(bz)"))
	end
	if by < 8 || by > 256 || nextpow(2,by) != by
		throw(ArgumentError("must have 8 <= by <= 256, and by must be a power of 2 got by=$(by)"))
	end
	if bx < 8 || bx > 256 || nextpow(2,bx) != bx
		throw(ArgumentError("must have 8 <= bx <= 256, and bz must be a power of 2 got bx=$(bx)"))
	end
	CvxCompressor(Int64(bz), Int64(by), Int64(bx), Float64(scale))
end

copy(c::CvxCompressor) = CvxCompressor(c.bz, c.by, c.bx, c.scale)

function compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor, volume::Array{Float32,3})
	nz, ny, nx = size(volume)
	compressed_length = Ref{Clong}(1)
	ccall((:cvx_compress, CvxCompress._jl_libcvxcompress),
	      Float32,
	      (Cfloat, Ptr{Cfloat}, Cint, Cint, Cint, Cint, Cint, Cint, Ptr{Cuint},        Ref{Clong}),
	      c.scale, volume,      nz,   ny,   nx,   c.bz, c.by, c.bx, compressed_volume, compressed_length)
	compressed_length[]
end
compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor, volume::Array{Float64,3}) = compress!(compressed_volume, c, convert(Array{Float32,3}, volume))

function decompress!(volume::Array{Float32,3}, c::CvxCompressor, compressed_volume::Array{UInt32,1}, compressed_length::Integer)
	nz, ny, nx = size(volume)
	ccall((:cvx_decompress_inplace, CvxCompress._jl_libcvxcompress),
	      Ptr{Void},
	      (Ptr{Cfloat}, Cint, Cint, Cint, Ptr{Cuint},        Clong),
	      volume,       nz,   ny,   nx,   compressed_volume, compressed_length)
end
function decompress!(volume::Array{Float64,3}, c::CvxCompressor, compressed_volume::Array{UInt32,1}, compressed_length::Integer)
	v = convert(Array{Float32,3}, volume)
	decompress!(v, c, compressed_volume, compressed_length)
end

export CvxCompressor
export compress!
export decompress!

end
