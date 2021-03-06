using CvxCompress, Blosc, LinearAlgebra

Blosc.set_num_threads(4)

nz, nx = 2048, 4096
bz, bx = 32, 32
scl = 1e0

x = rand(Float32, nz, nx)

# CvxCompress
y = zeros(UInt32, nz*nx)
clength_cvx = CvxCompress.compress!(y, CvxCompressor((bz,bx),scl), x)
t_cvx_compress = @elapsed clength_cvx = CvxCompress.compress!(y, CvxCompressor((bz,bx),scl), x)
xx = similar(x)
CvxCompress.decompress!(xx, CvxCompressor((bz,bx),scl), y, clength_cvx)
t_cvx_decompress = @elapsed CvxCompress.decompress!(xx, CvxCompressor((bz,bx),scl), y, clength_cvx)
snr_cvx = 10*log10(norm(x)^2 / norm(x-xx)^2)

# Blosc (no quantization)
y = zeros(UInt8, nz*nx*4+512)
clength_blosc = Blosc.compress!(y, x)
t_blosc_compress = @elapsed clength_blosc = Blosc.compress!(y, x)
xx=zeros(Float32,nz*nx)
Blosc.decompress!(xx, y)
t_blosc_decompress = @elapsed Blosc.decompress!(xx, y)
xx = reshape(xx,nz,nx)
snr_blosc = 10*log10(norm(x)^2 / (norm(x-xx)^2))

# Blosc (quantization)
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

clength_blosc_quant, mn, sc = blosc_quant(nz,nx,x,y)
t_bloscquant_compress = @elapsed blosc_quant(nz,nx,x,y)
blosc_dequant(nz,nx,x,y,mn,sc)
t_bloscquant_decompress = @elapsed blosc_dequant(nz,nx,x,y,mn,sc)
snr_bloscquant = 10*log10(norm(x)^2 / (norm(x-xx)^2))

#readme = open("README.md", "w")
readme = stdout
for io in (stdout, readme)
    write(io, "# times (compress, de-compress):\n")
    write(io, "* cvx:         $(t_cvx_compress),$(t_cvx_decompress) seconds\n")
    write(io, "* blosc:       $(t_blosc_compress),$(t_blosc_decompress) seconds\n")
    write(io, "* blosc-quant: $(t_bloscquant_compress),$(t_bloscquant_decompress) seconds\n")

    write(io, "\n")

    write(io, "# compression:\n")
    write(io, "* cvx:         $((clength_cvx*4)/(nz*nx*4))\n")
    write(io, "* blosc:       $((clength_blosc)/(nz*nx*4))\n")
    write(io, "* blosc-quant: $((clength_blosc_quant)/(nz*nx*4))\n")

    write(io, "\n")

    write(io, "# signal-to-noise:\n")
    write(io, "* cvx:         $(snr_cvx)\n")
    write(io, "* blosc:       $(snr_blosc)\n")
    write(io, "* blosc-quant: $(snr_bloscquant)\n")
end
#close(readme)
