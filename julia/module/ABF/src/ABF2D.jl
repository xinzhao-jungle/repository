using LinearAlgebra
using SparseArrays

export ham_fd, LUT, redef1, redef2, project!, project, U_fe, ham_fe

function ham_fd(ltc::Lattice2D, Ea::F, Eb::F) where F <: AbstractFloat
    @assert ltc.U == 2
    return spdiagm(0 => repeat([F(Ea), F(Eb)], ltc.M*ltc.N))
end

function LUT(ltc::Lattice2D, θ::F) where F <: AbstractFloat
    num_sites = ltc.M*ltc.N*ltc.U
    cos_θ = cospi(θ)
    sin_θ = sinpi(θ)
    I = Int64[]; J = Int64[]; V = F[]
    for m in 1:ltc.M, n in 1:ltc.N
        push!(I, index(ltc, (m,n,1)))
        push!(J, index(ltc, (m,n,1)))
        push!(V, cos_θ )

        push!(I, index(ltc, (m,n,2)))
        push!(J, index(ltc, (m,n,1)))
        push!(V, -sin_θ )

        push!(I, index(ltc, (m,n,1)))
        push!(J, index(ltc, (m,n,2)))
        push!(V, sin_θ )

        push!(I, index(ltc, (m,n,2)))
        push!(J, index(ltc, (m,n,2)))
        push!(V, cos_θ )
    end
    return sparse(I, J, V, num_sites, num_sites)
end

function LUT(ltc::Lattice2D, θ::F, ϕ1::F, ϕ2::F) where F <: AbstractFloat
    num_sites = ltc.M*ltc.N*ltc.U
    cos_θ = cospi(θ)
    sin_θ = sinpi(θ)
    exp_phi1 = exp(im*ϕ1)
    exp_phi2 = exp(im*ϕ2)
    exp_phi1m = 1/exp_phi1
    exp_phi2m = 1/exp_phi2

    I = Int64[]; J = Int64[]; V = Complex{F}[]
    for m in 1:ltc.M, n in 1:ltc.N
        push!(I, index(ltc, (m,n,1)))
        push!(J, index(ltc, (m,n,1)))
        push!(V, exp_phi1*cos_θ)

        push!(I, index(ltc, (m,n,2)))
        push!(J, index(ltc, (m,n,1)))
        push!(V, -exp_phi2m*sin_θ)

        push!(I, index(ltc, (m,n,1)))
        push!(J, index(ltc, (m,n,2)))
        push!(V, exp_phi2*sin_θ)

        push!(I, index(ltc, (m,n,2)))
        push!(J, index(ltc, (m,n,2)))
        push!(V, exp_phi1m*cos_θ)
    end
    return sparse(I, J, V, num_sites, num_sites)
end

function redef1(ltc::Lattice2D; vartype = Float64)
    num_sites = ltc.M*ltc.N*ltc.U
    I = Int64[]; J = Int64[]; V = vartype[]
    for m in 1:ltc.M, n in 1:ltc.N
        push!(I, index(ltc, (m,n,1)))
        push!(J, index(ltc, (m,n,1)))
        push!(V, one(vartype))

        push!(I, index(ltc, (m,n,2)))
        push!(J, index(ltc, (m,n+1,2)))
        push!(V, one(vartype))
    end
    return sparse(I, J, V, num_sites, num_sites)
end

function redef2(ltc::Lattice2D; vartype = Float64)
    num_sites = ltc.M*ltc.N*ltc.U
    I = Int64[]; J = Int64[]; V = vartype[]
    for m in 1:ltc.M, n in 1:ltc.N
        push!(I, index(ltc, (m,n,1)))
        push!(J, index(ltc, (m,n,1)))
        push!(V, one(vartype))

        push!(I, index(ltc, (m,n,2)))
        push!(J, index(ltc, (m+1,n,2)))
        push!(V, one(vartype))
    end
    return sparse(I, J, V, num_sites, num_sites)
end

function U_fe(ltc::Lattice2D, θ::F) where F <: AbstractFloat
    U1 = LUT(ltc,θ)
    T1 = redef1(ltc, vartype = F)
    T2 = redef2(ltc, vartype = F)
    return U1*T2*U1*T1*U1
end

function U_fe(ltc::Lattice2D, θ::F, ϕ1::F, ϕ2::F) where F <: AbstractFloat
    U1 = LUT(ltc,θ, ϕ1, ϕ2)
    T1 = redef1(ltc, vartype = F)
    T2 = redef2(ltc, vartype = F)
    return U1*T2*U1*T1*U1
end

function ham_fe(ltc::Lattice2D, Ea::F, Eb::F, θ::F) where F <: AbstractFloat
    U = U_fe(ltc, θ)
    H_fd = ham_fd(ltc, Ea, Eb)
    H_fe = U*H_fd*U'
    return H_fe, U
end

function ham_fe(L::Integer, M::Integer, Ea::F, Eb::F, θ::F) where F <: AbstractFloat
    return ham_fe(Lattice2D(L, M, 2), Ea, Eb, θ) 
end

function ham_fe(ltc::Lattice2D, Ea::F, Eb::F, θ::F, ϕ1::F, ϕ2::F) where F <: AbstractFloat
    U = U_fe(ltc, θ, ϕ1, ϕ2)
    H_fd = ham_fd(ltc, Ea, Eb)
    H_fe = U*H_fd*U'
    return H_fe, U
end
