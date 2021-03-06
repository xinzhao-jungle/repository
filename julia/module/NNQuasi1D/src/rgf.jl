using Random
using LinearAlgebra

@doc """
Hamiltonian of isolated strip used for RGF.
"""
function isolated_strip!(H_n; M::Integer = 3, W::Real = 1., t::Real = 1., rng = Random.GLOBAL_RNG)
    @assert M >= 3 # Required due to periodic boundary condition
    H_n[diagind(H_n)] = W*(rand(rng, M) .- 0.5)
    for i in 1:M
        H_n[i, mod1(i+1, M)] = t
        H_n[i, mod1(i-1, M)] = t
        H_n[mod1(i+1, M), i] = t
        H_n[mod1(i-1, M), i] = t
    end
end

@doc """
Hamiltonian of isolated strip used for RGF.
"""
function isolated_strip(; M::Integer = 3, W::Real = 1., t::Real = 1., rng = Random.GLOBAL_RNG)
    @assert M >= 3 # Required due to periodic boundary condition

    H_n = diagm(0 => W*(rand(rng, M) .- 0.5))
    for i in 1:M
        H_n[i, mod1(i+1, M)] = t
        H_n[i, mod1(i-1, M)] = t
        H_n[mod1(i+1, M), i] = t
        H_n[mod1(i-1, M), i] = t
    end
    return H_n
end
@doc """
Hamiltonian of isolated bar used for RGF.
"""
function isolated_bar(;M::Integer = 3, W::Real = 1., t::Real = 1.)
    H_n = diagm(0 => W*(rand(M^2) .- 0.5))
    if M >= 2
        for m in 0:M-1, n in 0:M-1
            i = M*m + n + 1
            ip_x = M*mod(m+1, M) + n + 1
            im_x = M*mod(m-1, M) + n + 1
            ip_y = M*m + mod(n+1, M) + 1
            im_y = M*m + mod(n-1, M) + 1
            H_n[i, ip_x] = t
            H_n[i, im_x] = t
            H_n[i, ip_y] = t
            H_n[i, im_y] = t

            H_n[ip_x, i] = t
            H_n[im_x, i] = t
            H_n[ip_y, i] = t
            H_n[im_y, i] = t
        end

    end
    return H_n
end

@doc """
bar RGF original recursion
"""
function rgf_true_strip(;E::Real = 0., W::Real = 1., M::Integer = 3, N::Integer = 10000)
    t = 1.
    H_n = isolated_strip(M = M, W = W, t = t)

    G_nn = zeros(BigFloat, M, M)
    G_1n = convert.(BigFloat, I(M))
    for n in 1:N
        H_n = convert.(BigFloat, isolated_strip(M = M, W = W, t = t))

        G_nn = inv(E*I(M) - H_n - G_nn)
        G_1n = G_1n*G_nn
    end
    return -2N/log((sum(x -> x^2, G_1n)))
end

function rgf_strip(;E = 0., W = 1., M = 3, N = 10000)
    t = 1. # Hopping must be 1

    I??? = convert.(Float64, I(M))
    EI??? = E*I???

    # Initial values
    H??? = isolated_strip(M = M, W = W, t = t)
    A??? = I???
    A????????? = zeros(Float64, M, M)
    B??? = I???
    c??? = 0.
    for n in 1:N
        A???????? = inv(A???)
        if n%5  == 0
            A????????? *= A????????
            A??? = I???
            #----------------------#
            B??? *= A????????
            b??? = sqrt(sum(abs2, B???))
            B??? /= b???
            c??? += log(b???)
            #----------------------#
        end
        H??? = isolated_strip(M = M, W = W, t = t)
        A?????????= (EI??? - H???)A??? - A?????????

        A????????? = A???
        A??? = A?????????
    end
    return -N/c???
end


function rgf_bar(;E = 0., W = 1., M = 3, N = 10000)
    t = 1. # Hopping must be 1

    I??? = convert.(Float64, I(M^2))
    EI??? = E*I???

    # Initial values
    H??? = isolated_bar(M = M, W = W, t = t)
    A??? = I???
    A????????? = zeros(Float64, M^2, M^2)
    B??? = I???
    c??? = 0.
    for n in 1:N
        A???????? = inv(A???)
        if n%5  == 0
            A????????? *= A????????
            A??? = I???
            #----------------------#
            B??? *= A????????
            b??? = sqrt(sum(abs2, B???))
            B??? /= b???
            c??? += log(b???)
            #----------------------#
        end
        H??? = isolated_bar(M = M, W = W, t = t)
        A?????????= (EI??? - H???)A??? - A?????????

        A????????? = A???
        A??? = A?????????
    end
    return -N/c???
end
