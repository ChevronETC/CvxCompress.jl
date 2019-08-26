# CvxCompress.jl
Thin wrapper around CvxCompress written by Thor Johnsen.

# Dependencies
* CvxCompress (https://chevron.visualstudio.com/ETC-ESD-CvxCompress)

# Obtaining CvxCompress.jl
1. Follow the instructions at https://chevron.visualstudio.com/ETC-ESD-PkgRegistry.jl
2. From the Julia prompt, `]add CvxCompress`
3. (optional) From the Julia prompt `]dev CvxCompress`

# Building CvxCompress.jl
CvxCompress.jl depends on CvxCompress, written by Thor Johnsen.  To re-download and re-build CvxCompress, do:
```julia
]build CvxCompress
```

# Using CvxCompress.jl

## 3D
```julia
using CvxCompress

n1,n2,n3 = 100,200,300
volume = rand(Float32,n1,n2,n3)
compressed_volume = zeros(UInt32,n1*n2*n3)
decompressed_volume = zeros(Float32,n1,n2,n3)

b1,b2,b3,scale=16,16,16,1e-3
c = CvxCompressor((b1,b2,b3), scale)
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

c = CvxCompressor((b1,b2),scale)
nbytes = compress!(compressed_volume, c, volume)
decompress!(decompressed_volume, c, compressed_volume)
```

# Options
In the above examples we have,
* `b1=32,b2=32,b3=32` block size used for compression where b1 is fast and b3 is slow.  These must be powers of 2, and between 8 and 256.
* `scale=1e-2` scale factor used to determine the thresholding of the wavelet coefficients
