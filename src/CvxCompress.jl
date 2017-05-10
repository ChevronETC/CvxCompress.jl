__precompile__()

module CvxCompress

import Base.copy

const _jl_libcvxcompress = normpath(joinpath(Base.source_path(), "../../deps/usr/lib/libcvxcompress"))

type CvxCompressor{N}
    br::Array{Int64,1} # [bz,by,bx] for 3D or [bz,bx] for 2D
    scale::Float32
    compressed_length::Base.RefValue{Clong}
end

function CvxCompressor3D(;b1::Integer=32,b2::Integer=32,b3::Integer=32,scale::Real=1e-2)
    if b1 < 8 || b2 > 256 || nextpow(2,b3) != b3
        throw(ArgumentError("must have 8 <= b3 <= 256, and b3 must be a power of 2 got b3=$(b3)"))
    end
    if b2 < 8 || b2 > 256 || nextpow(2,b2) != b2
        throw(ArgumentError("must have 8 <= b2 <= 256, and by must be a power of 2 got b2=$(b2)"))
    end
    if b3 < 8 || b3 > 256 || nextpow(2,b3) != b3
        throw(ArgumentError("must have 8 <= b3 <= 256, and b3 must be a power of 2 got b3=$(b3)"))
    end
    CvxCompressor{3}([Int64(b1) ; Int64(b2) ; Int64(b3)], Float32(scale), Ref{Clong}(0))
end

function CvxCompressor2D(;b1::Integer=32,b2::Integer=32,scale::Real=1e-2)
    if b1 < 8 || b1 > 256 || nextpow(2,b1) != b1
        throw(ArgumentError("must have 8 <= b1 <= 256, and b1 must be a power of 2 got b1=$(b1)"))
    end
    if b2 < 8 || b2 > 256 || nextpow(2,b2) != b2
        throw(ArgumentError("must have 8 <= b2 <= 256, and b2 must be a power of 2 got b2=$(b2)"))
    end
    CvxCompressor{2}([Int64(b1) ; Int64(b2)], Float32(scale), Ref{Clong}(0))
end

# backwards compat:
CvxCompressor(;b1::Integer=32,b2::Integer=32,b3::Integer=32,scale::Real=1e-2) = CvxCompressor3D(b1=b1,b2=b2,b3=b3,scale=scale)

copy{N}(c::CvxCompressor{N}) = CvxCompressor{N}(copy(c.br), c.scale, Ref{Clong}(0))

# 3D
function compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{3}, volume::Array{Float32,3})
    nz, ny, nx = size(volume)
    ccall((:cvx_compress, CvxCompress._jl_libcvxcompress),
          Float32,
          (Cfloat, Ptr{Cfloat}, Cint, Cint, Cint, Cint,    Cint,    Cint,    Ptr{Cuint},        Ref{Clong}),
          c.scale, volume,      nz,   ny,   nx,   c.br[1], c.br[2], c.br[3], compressed_volume, c.compressed_length)
    c.compressed_length[]
end
compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{3}, volume::Array{Float64,3}) = compress!(compressed_volume, c, convert(Array{Float32,3}, volume))

function decompress!(volume::Array{Float32,3}, c::CvxCompressor{3}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)
    nz, ny, nx = size(volume)
    ccall((:cvx_decompress_inplace, CvxCompress._jl_libcvxcompress),
          Void,
          (Ptr{Cfloat}, Cint, Cint, Cint, Ptr{Cuint},        Clong),
          volume,       nz,   ny,   nx,   compressed_volume, compressed_length)
end
function decompress!(volume::Array{Float64,3}, c::CvxCompressor{3}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)
    v = Array{Float32}(size(volume))
    decompress!(v, c, compressed_volume, compressed_length)
    volume[:] = v[:]
end

# 2D
function compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{2}, volume::Array{Float32,2})
    nz, nx = size(volume)
    ccall((:cvx_compress, CvxCompress._jl_libcvxcompress),
          Float32,
          (Cfloat, Ptr{Cfloat}, Cint, Cint, Cint, Cint,    Cint,    Cint,    Ptr{Cuint},        Ref{Clong}),
          c.scale, volume,      nz,   nx,   1,    c.br[1], c.br[2], 1,       compressed_volume, c.compressed_length)
    c.compressed_length[]
end
compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{2}, volume::Array{Float64,2}) = compress!(compressed_volume, c, convert(Array{Float32,2}, volume))

function decompress!(volume::Array{Float32,2}, c::CvxCompressor{2}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)
    nz, nx = size(volume)
    ccall((:cvx_decompress_inplace, CvxCompress._jl_libcvxcompress),
          Void,
          (Ptr{Cfloat}, Cint, Cint, Cint, Ptr{Cuint},        Clong),
          volume,       nz,   nx,   1,    compressed_volume, compressed_length)
end
function decompress!(volume::Array{Float64,2}, c::CvxCompressor{2}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)
    v = Array{Float32}(size(volume))
    decompress!(v, c, compressed_volume, compressed_length)
    volume[:] = v[:]
end

export CvxCompressor
export CvxCompressor2D
export CvxCompressor3D
export compress!
export decompress!

end
