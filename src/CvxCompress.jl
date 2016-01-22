__precompile__()

module CvxCompress

const _jl_libcvxcompress = normpath(joinpath(Base.source_path(), "../../deps/usr/lib/libcvxcompress"))

type CvxCompressor
	bz::Int64
	by::Int64
	bx::Int64
	scale::Float32
end
function CvxCompressor(;bz=32,by=32,bx=32,nz=-1,ny=-1,nx=-1,scale=1e-4)
	if nz < 0 || ny < 0 || nx < 0
		throw(ArgumentError("must specify, nz,ny,nx\n"))
	end
	# find bz,by,bx that are less than or equal to nz,ny,nx and are a scalar multiple of 8 for simd
	bz = blocksize(bz,nz)
	by = blocksize(by,ny)
	bx = blocksize(bx,nx)
	CvxCompressor(bz, by, bx, scale)
end

function blocksize(b,n)
	b = b > n ? n : b
	while rem(b,8) != 0
		b -= 1
	end
	b
end

function compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor, volume::Array{Float32,3})
	nz, ny, nx = size(volume)
	compressed_length = Ref{Clong}(1)
	ccall((:cvx_compress, CvxCompress._jl_libcvxcompress),
	      Float32,
	      (Cfloat, Ptr{Cfloat}, Cint, Cint, Cint, Cint, Cint, Cint, Ptr{Cuint},        Ref{Clong}),
	      c.scale, volume,      nz,   ny,   nx,   c.bz, c.by, c.bx,   compressed_volume, compressed_length)
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
