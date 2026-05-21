using Random

"""
    init_spins(L; seed=nothing) -> Matrix{Int8}

Return an L×L matrix of spins randomly drawn from {+1, -1}.
Pass `seed` to fix the RNG for reproducibility.
"""
function init_spins(L; seed=nothing)
    if seed !== nothing
        Random.seed!(seed)
    end
    return rand(Int8[1, -1], L, L)
end

"""
    magnetization(spins) -> Float64

Return the mean spin value of the lattice.
"""
function magnetization(spins)
    return sum(spins) / length(spins)
end

"""
    energy(spins; J=1.0) -> Float64

Return the total energy of the 2D Ising lattice with periodic boundary conditions.
E = -J Σ σ_i σ_j over all nearest-neighbor pairs.
"""
function energy(spins; J=1.0)
    L = size(spins, 1)
    E = 0.0
    for i in 1:L, j in 1:L
        right = spins[mod1(i+1, L), j]
        below = spins[i, mod1(j+1, L)]
        E -= J * spins[i, j] * (right + below)
    end
    return E
end

