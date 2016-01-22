using CvxCompress

nz = 128
ny = 129
nx = 130

# 32 bit
x = rand(Float32, nz, ny, nx)
y = Array(UInt32, nz*ny*nx)
c = CvxCompressor(nz=nz,ny=ny,nx=nx)
compressed_length = compress!(y,c,x)

xx = zeros(Float32, nz, ny, nx)
decompress!(xx,c,y,compressed_length)

@show vecnorm(x-xx)
@show compressed_length / length(x)

using Mayavi
sliceplot(x,clim=[-1,1])
sliceplot(xx,clim=[-1,1])
sliceplot(x-xx,clim=[-1,1])

# 64 bit
x = rand(Float64, nz, ny, nx)
y = Array(UInt32, nz*ny*nx)
c = CvxCompressor()
compressed_length = compress!(y,c,x)

xx = zeros(Float64, nz, ny, nx)
decompress!(xx,c,y,compressed_length)

@show vecnorm(x-xx)
@show compressed_length / length(x)

sliceplot(x,clim=[-1,1])
sliceplot(xx,clim=[-1,1])
sliceplot(x-xx,clim=[-1,1])

if isinteractive() == false
	sleep(9999999)
end
