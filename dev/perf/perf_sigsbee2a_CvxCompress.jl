using CvxCompress, Blosc, TeaSeis, Jot

# read the earth model:
io = jsopen("/data/data248/SIVPromaxHome/tqff/model_sigsbee2a/model.js")
nz,nx = size(io)[1:2]
dz,dx = pincs(io)[1:2]
vp = readframetrcs(io,1)
dn = readframetrcs(io,2)

# receiver coordinates:
rz = [dz ; dz]
rx = [0.0 ; (nx-1)*dx]

# source coordinates
sz = 2*dz
sx = div(nx,2)*dx

# modeling operator:
F = JotOpNlProp2DAcoIsoDen_DEO1_FDTD(
    dn = dn, velmax = maximum(vp),
    dz = dz, dx = dx,
    rz = rz, rx = rx,
    sz = sz, sx = sx,
    ntrec = 2048)

# model data
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

Blosc.set_num_threads(23)
ENV["OMP_NUM_THREADS"] = 23

function blosc_quant(nz,nx,x,y)
    xx = zeros(UInt16, nz, nx)
    mn = minimum(x)
    d = maximum(x) - mn + eps(Float32)
    sc = d > eps(Float32) ? typemax(UInt16)/d : 1.0f0
    for i = 1:length(x)
        @inbounds xx[i] = unsafe_trunc(UInt16, (x[i]-mn)*sc)
    end
    clength_blosc_quant = Blosc.compress!(y, xx)
    clength_blosc_quant, mn, sc
end
function blosc_dequant(nz,nx,x,y,mn,sc)
    xx = zeros(UInt16, nz*nx)
    Blosc.decompress!(xx,y)
    for i = 1:length(x)
        x[i] = xx[i]/sc + mn
    end
end

io = open("$(F.srcfieldfile)-p")
ts = 1:F.ntrec
for it in ts
    write(stdout, "it=$(it).")

    # read uncrompressed field into x
    seek(io, (it-1)*prod(size(F.ginsu,interior=true))*4)
    x = read(io, Float32, size(F.ginsu,interior=true)...)
    nz, nx = size(F.ginsu,interior=true)

    #
    # CvxCompress
    #
    cvx = CvxCompressor2D(32,32)

    # compression - compressed buffer is y
    y = zeros(UInt32, nz*nx)
    cl = CvxCompress.compress!(y, cvx, x)
    push!(clength_cvx, cl)
    push!(t_cvx_compress, @elapsed cl = CvxCompress.compress!(y, cvx, x))

    # decompression - decompressed buffer is xx
    xx = similar(x)
    CvxCompress.decompress!(xx, cvx, y, cl)
    push!(t_cvx_decompress, @elapsed CvxCompress.decompress!(xx, cvx, y, cl))
    push!(snr_cvx, 10*log10(norm(x)^2 / norm(x-xx)^2))

    #
    # Blosc (no quantization)
    #

    # compression - compressed buffer is y
    y = zeros(UInt8, nz*nx*4+512)
    push!(clength_blosc, Blosc.compress!(y, x))
    push!(t_blosc_compress, @elapsed c = Blosc.compress!(y, x))

    # decompression - decompressed buffer is xx
    xx = Array{Float32}(nz*nx)
    Blosc.decompress!(xx, y)
    push!(t_blosc_decompress, @elapsed Blosc.decompress!(xx, y))
    xx = reshape(xx,nz,nx)
    push!(snr_blosc, 10*log10(norm(x)^2 / (norm(x-xx)^2)))

    #
    # Blosc (with quantization)
    #

    # compression - compressed buffer is y
    c, mn, sc = blosc_quant(nz,nx,x,y)
    push!(clength_bloscquant, c)
    push!(t_bloscquant_compress, @elapsed blosc_quant(nz,nx,x,y))

    # decompression - decompressed buffer is xx
    xx=zeros(Float32,nz,nx)
    blosc_dequant(nz,nx,xx,y,mn,sc)
    push!(t_bloscquant_decompress, @elapsed blosc_dequant(nz,nx,xx,y,mn,sc))
    push!(snr_bloscquant, 10*log10(norm(x)^2 / (norm(x-xx)^2)))
end
close(io)

using PyPlot
for (i,N) in enumerate([1,800])
    rng=N:length(ts)
    figure(i);close();figure(i,figsize=(10,10));clf()
    subplot(221)
    plot(ts[rng], (prod(size(F.ginsu,interior=true))*4 ./ clength_blosc     )[rng] , label="blosc")
    plot(ts[rng], (prod(size(F.ginsu,interior=true))*4 ./ clength_bloscquant)[rng] , label="blosc-quant")
    plot(ts[rng], (prod(size(F.ginsu,interior=true))*4 ./ clength_cvx       )[rng] , label="cvx")
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
figure(1);savefig("perf-2D.png")
figure(2);savefig("perf-2D-zoom.png")

figure(3);close();figure(3,figsize=(8,6));clf()
io = open("$(F.srcfieldfile)-p")
clp=1.0
for (i,it) in enumerate([50,350,650,950,1250,1550])
    seek(io, it*prod(size(F.ginsu,interior=true))*4)
    x = read(io, Float32, size(F.ginsu,interior=true)...)
    if i == 1
        clp = maxabs(x)*.1
    end
    subplot(3,2,i);imshow(x,clim=clp*[-1,1],cmap="seismic_r");title("it=$(it)")
end
tight_layout()
figure(3);savefig("fields-2D.png")
close(io)

figure(4);imshow(vp,clim=[1500,2500])
