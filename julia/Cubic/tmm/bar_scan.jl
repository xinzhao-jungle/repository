<<<<<<< HEAD
=======
include("/home/yjkim/codes/repository/julia/module/NNQuasi1D/src/tmm.jl")
>>>>>>> 62e5f8ad7a4699cd5243fd89f7460e2850995195
using Random
using LinearAlgebra
using SparseArrays
using MAT
println("Number of Threads: ",Threads.nthreads())
LinearAlgebra.BLAS.set_num_threads(1)
W = [10., 10.5, 11.0, 11.5, 12.0, 12.5, 13.0, 13.5, 14.0,
    14.3, 14.5, 15.0, 15.3, 15.5, 15.8, 16.0, 16.1, 16.2, 16.3, 16.4,
    16.5, 16.6, 16.7, 16.8, 17.0, 17.2, 17.5, 18.0, 18.5, 19.0,
    20.0, 21.0, 22.0, 24.0, 26.0, 28.0, 30.0]
<<<<<<< HEAD
M = collect(3:1:11)
seed = [12411 + i for i in 1:100]
rng = [MersenneTwister(seed[i]) for i in 1:40]
N = Int64(2*10^2)
=======
M = collect(3:1:10)
seed = [12411 + i for i in 1:100]
rng = [MersenneTwister(seed[i]) for i in 1:length(W)]
N = Int64(10^3)
>>>>>>> 62e5f8ad7a4699cd5243fd89f7460e2850995195

xi = Array{Float64}(undef, length(W), length(M))
<<<<<<< HEAD
@time @Threads.threads for i in 1:length(W)
    rng_inner = rng[i]
    for j in 1:length(M)
        xi[i, j] = tmm_bar(M = M[j], E = 0., W = W[i], rng = rng_inner, N = N, N_qr = 10)
=======
@time for i in 1:length(M)
    @Threads.threads for j in 1:length(W)
	    xi[j, i] = tmm_bar(M = M[i], E = 0., W = W[j], rng = rng[Threads.threadid()], N = N, N_qr = 10)
>>>>>>> 62e5f8ad7a4699cd5243fd89f7460e2850995195
    end
end

for i in 1:length(M)
    xi[:, i] /= M[i]
end

MAT.matwrite("xi-cubic.mat", Dict("xi" => xi, "W" => W, "M" => M, "N"=>N, "seed"=>seed, "N_qr" => 10))
