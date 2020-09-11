module CvxCompress

import Base.copy

const _jl_libcvxcompress = normpath(joinpath(Base.source_path(), "../../deps/usr/lib/libcvxcompress"))

"""
    CvxCompressor{N}

Struct used for managing the compression target
"""
mutable struct CvxCompressor{N}
    br::NTuple{N,Int}
    scale::Float32
    compressed_length::Base.RefValue{Clong}
end

"""
    CvxCompressor(b::NTuple{N,Int}, scale=1e-2)

Create a compressor struc instance
"""
CvxCompressor(b::NTuple{N,Int}, scale=1e-2) where {N} = CvxCompressor{N}(b, scale, Ref{Clong}(0))

"""
    CvxCompressor(b::Vararg{Int,N})

Create a compressor struc instance
"""
CvxCompressor(b::Vararg{Int,N}) where {N} = CvxCompressor(b)

"""
    copy(c::CvxCompressor{N})

Create a copy of a CvxCompressor struct
"""
copy(c::CvxCompressor{N}) where {N} = CvxCompressor{N}(c.br, c.scale, Ref{Clong}(0))

"""
    compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{3}, volume::Array{Float32,3})

3D compression of a volume
"""
function compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{3}, volume::Array{Float32,3})
    nz, ny, nx = size(volume)
    ccall((:cvx_compress, CvxCompress._jl_libcvxcompress),
          Float32,
          (Cfloat, Ptr{Cfloat}, Cint, Cint, Cint, Cint,    Cint,    Cint,    Ptr{Cuint},        Ref{Clong}),
          c.scale, volume,      nz,   ny,   nx,   c.br[1], c.br[2], c.br[3], compressed_volume, c.compressed_length)
    c.compressed_length[]
end

"""
    compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{3}, volume::Array{Float64,3})

3D compression of a volume
"""
compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{3}, volume::Array{Float64,3}) = compress!(compressed_volume, c, convert(Array{Float32,3}, volume))

"""
    decompress!(volume::Array{Float32,3}, c::CvxCompressor{3}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)

3D de-compression of a volume
"""
function decompress!(volume::Array{Float32,3}, c::CvxCompressor{3}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)
    nz, ny, nx = size(volume)
    ccall((:cvx_decompress_inplace, CvxCompress._jl_libcvxcompress),
          Cvoid,
          (Ptr{Cfloat}, Cint, Cint, Cint, Ptr{Cuint},        Clong),
          volume,       nz,   ny,   nx,   compressed_volume, compressed_length)
end

"""
    decompress!(volume::Array{Float64,3}, c::CvxCompressor{3}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)

3D de-compression of a volume
"""
function decompress!(volume::Array{Float64,3}, c::CvxCompressor{3}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)
    v = Array{Float32}(undef, size(volume))
    decompress!(v, c, compressed_volume, compressed_length)
    volume[:] = v[:]
end

"""
    compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{2}, volume::Array{Float32,2})

2D compression of a volume
"""
function compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{2}, volume::Array{Float32,2})
    nz, nx = size(volume)
    ccall((:cvx_compress, CvxCompress._jl_libcvxcompress),
          Float32,
          (Cfloat, Ptr{Cfloat}, Cint, Cint, Cint, Cint,    Cint,    Cint,    Ptr{Cuint},        Ref{Clong}),
          c.scale, volume,      nz,   nx,   1,    c.br[1], c.br[2], 1,       compressed_volume, c.compressed_length)
    c.compressed_length[]
end

"""
    compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{2}, volume::Array{Float64,2})

2D compression of a volume
"""
compress!(compressed_volume::Array{UInt32,1}, c::CvxCompressor{2}, volume::Array{Float64,2}) = compress!(compressed_volume, c, convert(Array{Float32,2}, volume))

"""
    decompress!(volume::Array{Float32,2}, c::CvxCompressor{2}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)

2D de-compression of a volume
"""
function decompress!(volume::Array{Float32,2}, c::CvxCompressor{2}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)
    nz, nx = size(volume)
    ccall((:cvx_decompress_inplace, CvxCompress._jl_libcvxcompress),
          Cvoid,
          (Ptr{Cfloat}, Cint, Cint, Cint, Ptr{Cuint},        Clong),
          volume,       nz,   nx,   1,    compressed_volume, compressed_length)
end

"""
    decompress!(volume::Array{Float64,2}, c::CvxCompressor{2}, compressed_volume::Array{UInt32,1}, compressed_length::Integer)

2D de-compression of a volume
"""
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
