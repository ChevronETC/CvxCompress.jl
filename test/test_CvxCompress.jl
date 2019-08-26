using CvxCompress, Test, BenchmarkTools

@testset "CvxCompress, 2D copy" begin
    bz,bx,scale = 32, 16, 1e-3
    cvx = CvxCompressor((bz,bx),scale)
    cvx_copy = copy(cvx)
    @test cvx_copy.br == cvx.br
    @test cvx_copy.scale == cvx.scale
end
