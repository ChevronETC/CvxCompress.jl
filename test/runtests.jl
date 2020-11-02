using CvxCompress, Test, Random

# set random seed to promote repeatability in CI unit tests
Random.seed!(101)

@testset "CvxCompress, 2D" begin
    nz,nx,bz,bx,σ = 2048,4096,32,32,1e-3
    x = rand(Float32, nz, nx)
    y = zeros(Float32, nz, nx)
    z = zeros(UInt32, nz*nx)
    n = CvxCompress.compress!(z, CvxCompressor((bz,bx),σ), x)
    CvxCompress.decompress!(y, CvxCompressor((bz,bx),σ), z, n)

    @test x ≈ y rtol=1e-3
end

@testset "CvxCompress, 3D" begin
    nz,ny,nx,bz,by,bx,σ = 128,64,256,32,32,32,1e-3
    x = rand(Float32, nz, ny, nx)
    y = zeros(Float32, nz, ny, nx)
    z = zeros(UInt32, nz*ny*nx)
    n = CvxCompress.compress!(z, CvxCompressor((bz,by,bx),σ), x)
    CvxCompress.decompress!(y, CvxCompressor((bz,by,bx),σ), z, n)

    @test x ≈ y rtol=1e-3
end
