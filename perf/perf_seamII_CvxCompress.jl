using CvxCompress, Blosc, JavaSeis, Jot

# read the earth model:
io = jsopen("/data/data248/SIVPromaxHome/tqff/model_seamII_patch-10x20x20/model.js")
nz,ny,nx = size(io)[1:3]
dz,dy,dx = pincs(io)[1:3]
vp = reshape(readtrcs(io, :, :, :, 1), nz, ny, nx)
dn = reshape(readtrcs(io, :, :, :, 2), nz, ny, nx)

# receiver coordinates:
rz = zeros(div(ny*nx,16))
ry = zeros(div(ny*nx,16))
rx = zeros(div(ny*nx,16))
itrace = 1
for iy = 1:8:ny, ix = 1:8:ny
	rz[itrace] = 2*dz
	ry[itrace] = (iy-1)*dy
	rx[itrace] = (ix-1)*dx
	itrace += 1
end

# modeling operator:
F = JotOpNlProp3DAcoIsoDen_FDTD(
	dn = dn, velmax = maximum(vp),
	dz = dz, dy = dy, dx = dx,
	rz = rz, ry = ry, rx = rx,
	sz = 10.0, sy = dy*div(ny,2), sx = dx*div(nx,2),
	ntrec = 512)

# model data (be patient... this might take a few minutes):
d = F(vp)

t_cvx_compress = Float64[]
t_cvx_decompress = Float64[]
clength_cvx = Int64[]
snr_cvx = Float64[]

t_blosc_compress = Float64[]
t_blosc_decompress = Float64[]
clength_blosc = Int64[]
snr_blosc = Float64[]

t_bloscquant_compress = Float64[]
t_bloscquant_decompress = Float64[]
clength_bloscquant = Int64[]
snr_bloscquant = Float64[]

Blosc.set_num_threads(19)

function blosc_quant(nz,ny,nx,x,y)
	xx = zeros(UInt16, nz, ny, nx)
	mn = minimum(x)
	d = maximum(x) - mn + eps(Float32)
	sc = d > eps(Float32) ? typemax(UInt16)/d : 1.0f0
	for i = 1:length(x)
		@inbounds xx[i] = unsafe_trunc(UInt16, (x[i]-mn)*sc)
	end
	clength_blosc_quant = Blosc.compress!(y, xx)
	clength_blosc_quant, mn, sc
end
function blosc_dequant(nz,ny,nx,x,y,mn,sc)
	xx = zeros(UInt16, nz*ny*nx)
	Blosc.decompress!(xx,y)
	for i = 1:length(x)
		x[i] = xx[i]/sc + mn
	end
end

io = open(F.srcfieldfile)
ts = 1:25:F.ntrec
for it in ts 
	write(STDOUT, "it=$(it).")
	seek(io, it*prod(size(F.ginsu))*4)
	x = read(io, Float32, size(F.ginsu)...)
	nz, ny, nx = size(F.ginsu)
	
	# CvxCompress -- crashes , and kills the Julia session in the process of crashing
	y = zeros(UInt32, nz*ny*nx)
	cl = CvxCompress.compress!(y, CvxCompressor(nz=nz,ny=ny,nx=nx,bz=32,by=32,bx=32), x)
	push!(clength_cvx, cl)
	push!(t_cvx_compress, @elapsed cl = CvxCompress.compress!(y, CvxCompressor(nz=nz,ny=ny,nx=nx,bz=32,by=32,bx=32), x))
	xx = similar(x)
	CvxCompress.decompress!(xx, CvxCompressor(nz=nz,ny=ny,nx=nx,bz=32,by=32,bx=32), y, cl)
	push!(t_cvx_decompress, @elapsed CvxCompress.decompress!(xx, CvxCompressor(nz=nz,ny=ny,nx=nx,bz=32,by=32,bx=32), y, cl))
	push!(snr_cvx, 10*log10(vecnorm(x)^2 / vecnorm(x-xx)^2))

	# Blosc (no quantization)
	y = zeros(UInt8, nz*ny*nx*4+512)
	push!(clength_blosc, Blosc.compress!(y, x))
	push!(t_blosc_compress, @elapsed c = Blosc.compress!(y, x))
	xx=zeros(Float32,nz*ny*nx)
	Blosc.decompress!(xx, y)
	push!(t_blosc_decompress, @elapsed Blosc.decompress!(xx, y))
	xx = reshape(xx,nz,ny,nx)
	push!(snr_blosc, 10*log10(vecnorm(x)^2 / (vecnorm(x-xx)^2)))

	# Blosc (quantize)
	c, mn, sc = blosc_quant(nz,ny,nx,x,y)
	push!(clength_bloscquant, c)
	push!(t_bloscquant_compress, @elapsed blosc_quant(nz,ny,nx,x,y))
	xx=zeros(Float32,nz,ny,nx)
	blosc_dequant(nz,ny,nx,xx,y,mn,sc)
	push!(t_bloscquant_decompress, @elapsed blosc_dequant(nz,ny,nx,x,y,mn,sc))
	push!(snr_bloscquant, 10*log10(vecnorm(x)^2 / (vecnorm(x-xx)^2)))
end
close(io)

using Mayavi,PyPlot
for (i,N) in enumerate([1,10])
	rng=N:length(ts)
	figure(i);close();figure(i,figsize=(10,10));clf()
	subplot(221)
	plot(ts[rng], (prod(size(F.ginsu))*4 ./ clength_blosc     )[rng] , label="blosc")
	plot(ts[rng], (prod(size(F.ginsu))*4 ./ clength_bloscquant)[rng] , label="blosc-quant")
	plot(ts[rng], (prod(size(F.ginsu))   ./ clength_cvx       )[rng] , label="cvx")
	title("Compression ratio");xlabel("time-step");legend()

	subplot(222);
	plot(ts[rng], t_blosc_compress[rng],      label="blosc")
	plot(ts[rng], t_bloscquant_compress[rng], label="blosc-quant")
	plot(ts[rng], t_cvx_compress[rng],        label="cvx")
	title("Compess time");xlabel("time-step");legend()

	subplot(223)
	plot(ts[rng], t_blosc_decompress[rng],      label="blosc")
	plot(ts[rng], t_bloscquant_decompress[rng], label="blosc-quant")
	plot(ts[rng], t_cvx_decompress[rng],        label="cvx")
	title("Decompress time");xlabel("time-step");legend()

	subplot(224)
	plot(ts[rng], snr_blosc[rng],      label="blosc")
	plot(ts[rng], snr_bloscquant[rng], label="blosc-quant")
	plot(ts[rng], snr_cvx[rng],        label="cvx")
	title("SNR");xlabel("time-step");legend()

	tight_layout()
end
figure(1);savefig("perf.png")
figure(2);savefig("perf-zoom.png")

io = open(F.srcfieldfile)
for it in (50,100,200,300,400,500)
	seek(io, it*prod(size(F.ginsu))*4)
	x = read(io, Float32, size(F.ginsu)...)
	sliceplot(x,clim=[-.0001,.0001], x = 50, y = 60, z = 80)
end
close(io)

sliceplot(vp,x=50,y=60,z=80,clim=[1500,2500])
