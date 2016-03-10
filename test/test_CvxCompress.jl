using CvxCompress, BaseTestNext

@testset "CvxCompress, 2D copy" begin
	bz,bx,scale = 32, 16, 1e-3
	cvx = CvxCompressor2D(bz=bz,bx=bx,scale=scale)
	cvx_copy = copy(cvx)
	@test cvx_copy.br == cvx.br
	@test cvx_copy.scale == cvx.scale
	@test (pointer(cvx_copy.br) == pointer(cvx.br)) == false
end
