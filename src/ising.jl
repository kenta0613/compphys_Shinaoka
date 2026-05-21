using Random

# ---------------------------------------------------------------------------
# Lattice initialization
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Model struct
# ---------------------------------------------------------------------------

"""
    IsingModel(spins, β, J)

Holds the full state of a 2D Ising simulation.
- `spins`: L×L matrix of Int8 spins (±1)
- `β`: inverse temperature 1/T
- `J`: coupling constant
"""
struct IsingModel
    spins :: Matrix{Int8}
    β     :: Float64
    J     :: Float64
    exp4J :: Float64  # exp(-β * 4J)
    exp8J :: Float64  # exp(-β * 8J)
end

"""
    IsingModel(L, β; J=1.0, seed=nothing) -> IsingModel

Convenience constructor: create a randomly initialised L×L model.
Precomputes exp(-β*dE) for the two possible positive ΔE values (4J and 8J).
"""
function IsingModel(L::Int, β::Float64; J::Float64=1.0, seed=nothing)
    return IsingModel(init_spins(L; seed=seed), β, J,
                      exp(-β * 4.0*J),
                      exp(-β * 8.0*J))
end

# ---------------------------------------------------------------------------
# Observables
# ---------------------------------------------------------------------------

"""
    magnetization(model) -> Float64

Return the mean spin value of the lattice.
"""
function magnetization(model::IsingModel)
    return sum(model.spins) / length(model.spins)
end

"""
    energy(model) -> Float64

Return the total energy with periodic boundary conditions.
E = -J Σ σ_i σ_j over all nearest-neighbor pairs.
"""
function energy(model::IsingModel)
    spins = model.spins
    J     = model.J
    L     = size(spins, 1)
    E     = 0.0
    for i in 1:L, j in 1:L
        right = spins[mod1(i+1, L), j]
        below = spins[i, mod1(j+1, L)]
        E -= J * spins[i, j] * (right + below)
    end
    return E
end

# ---------------------------------------------------------------------------
# Metropolis update
# ---------------------------------------------------------------------------

function calc_dE(model::IsingModel, i, j)
    spins = model.spins
    J     = model.J
    L     = size(spins, 1)
    neighbors = spins[mod1(i+1, L), j] +
                spins[mod1(i-1, L), j] +
                spins[i, mod1(j+1, L)] +
                spins[i, mod1(j-1, L)]
    return 2 * J * spins[i, j] * neighbors
end

function metropolis_step!(model::IsingModel)
    L  = size(model.spins, 1)
    i, j = rand(1:L), rand(1:L)
    dE = calc_dE(model, i, j)
    p = dE == 4.0*model.J ? model.exp4J : model.exp8J
    if dE <= 0 || rand() < p
        model.spins[i, j] *= -1
    end
end

function metropolis_sweep!(model::IsingModel)
    L = size(model.spins, 1)
    for _ in 1:L*L
        metropolis_step!(model)
    end
end
