using CvxCompress

nz = 128
ny = 129
nx = 130

# 3D - 32 bit
x = rand(Float32, nz, ny, nx)
y = Array(UInt32, nz*ny*nx)
c = CvxCompressor3D()
compressed_length = compress!(y,c,x)

xx = zeros(Float32, nz, ny, nx)
decompress!(xx,c,y,compressed_length)

@show vecnorm(x-xx)
@show compressed_length / length(x)

using Mayavi
sliceplot(x,clim=[-1,1])
sliceplot(xx,clim=[-1,1])
sliceplot(x-xx,clim=[-1,1])

# 3D - 64 bit
x = rand(Float64, nz, ny, nx)
y = Array(UInt32, nz*ny*nx)
c = CvxCompressor3D()
compressed_length = compress!(y,c,x)

xx = zeros(Float64, nz, ny, nx)
decompress!(xx,c,y,compressed_length)

@show vecnorm(x-xx)
@show compressed_length / length(x)

sliceplot(x,clim=[-1,1])
sliceplot(xx,clim=[-1,1])
sliceplot(x-xx,clim=[-1,1])

# 2D - 32 bit
x = rand(Float32, nz, nx)
y = Array(UInt32, nz*nx)
c = CvxCompressor2D()
compressed_length = compress!(y,c,x)

xx = zeros(Float32, nz, nx)
decompress!(xx,c,y,compressed_length)

@show vecnorm(x-xx)
@show compressed_length / length(x)

using PyPlot
figure(1);clf();subplot(131);imshow(x,clim=[-1,1]);subplot(132);imshow(xx,clim=[-1,1]);subplot(133);imshow(x-xx,clim=[-1,1])

# 2D - 64 bit
x = rand(Float64, nz, nx)
y = Array(UInt32, nz*nx)
c = CvxCompressor2D()
compressed_length = compress!(y,c,x)

xx = zeros(Float64, nz, nx)
decompress!(xx,c,y,compressed_length)

@show vecnorm(x-xx)
@show compressed_length / length(x)

figure(2);clf();subplot(131);imshow(x,clim=[-1,1]);subplot(132);imshow(xx,clim=[-1,1]);subplot(133);imshow(x-xx,clim=[-1,1])

if isinteractive() == false
	sleep(9999999)
end
