# CvxCompress.jl
Thin wrapper around CvxCompress written by Thor Johnsen.

# Dependencies
* CvxCompress (svn+ssh://ss-svn.xhl.chevrontexaco.net/devl/geophys/src/projects/fdmod2/trunk/CvxCompress)

# Obtaining CvxCompress.jl
You may prefer obtaining CvxCompress.jl and related packages from its parent project:

* http://136.171.178.114/juliafwi/ESDRDGeophysics

Following the above link will help you set up an development environment that is similar to your Chevron ETC/ESD peers.  Otherwise, you can continue reading to the end of this section.

You can obtain CvxCompress.jl using the Julia package management system.  From the Julia prompt:
```julia
Pkg.add("http://136.171.178.114/juliafwi/CvxCompress.jl")
```

# Building CvxCompress.jl
CvxCompress.jl depends on CvxCompress, written by Thor Johnsen.  To download and build CvxCompress, do:
```julia
cd CvxCompress/deps
julia build.jl
```

# Using CvxCompress.jl

## 3D
```julia
using CvxCompress

n1,n2,n3 = 100,200,300
volume = rand(Float32,n1,n2,n3)
compressed_volume = zeros(UInt32,n1*n2*n3)
decompressed_volume = zeros(Float32,n1,n2,n3)

c = CvxCompressor3D()
nbytes = compress!(compressed_volume, c, volume)
decompress!(decompressed_volume, c, compressed_volume)
```

## 2D
```julia
using CvxCompress

nz,nx = 100,300
volume = rand(Float32,n1,n2)
compressed_volume = zeros(UInt32,n1*n2)
decompressed_volume = zeros(Float32,n1,n2)

c = CvxCompressor2D()
nbytes = compress!(compressed_volume, c, volume)
decompress!(decompressed_volume, c, compressed_volume)
```

# Options
The method `CvxCompressor` accepts a number of named optional arguments.  These arguments along with their default values are listed here:

## 3D
* `b1=32,b2=32,b3=32` block size used for compression where b1 is fast and b3 is slow.  These must be powers of 2, and between 8 and 256.
* `scale=1e-2` scale factor used to determine the thresholding of the wavelet coefficients

For example:
```julia
c = CvxCompressor3D(b1=16,b2=32,b3=8,scale=1e-3)
```

## 2D
* `b1=32,b2=32` block size used for compression.  These must be powers of 2, and between 8 and 256.
* `scale=1e-2` scale factor used to determine the thresholding of the wavelet coefficients

For example:
```julia
c = CvxCompressor2D(b1=16,b2=8,scale=1e-3)
```
