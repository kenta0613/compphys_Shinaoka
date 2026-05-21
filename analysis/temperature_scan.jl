using compphys_Shinaoka
using Plots

# ---------------------------------------------------------------------------
# Core measurement function
# ---------------------------------------------------------------------------

"""
    measure(T, L; n_therm=500, n_meas=500, seed=42) -> Dict

Run a short MC simulation at temperature T on an L×L lattice.
Returns a Dict with mean E, mean |M|, and mean M².
"""
function measure(T::Float64, L::Int; n_therm=500, n_meas=500, seed=42)
    β     = 1.0 / T
    model = IsingModel(L, β, seed=seed)

    # thermalization — discard these sweeps
    run_simulation!(model, n_therm)

    # measurement
    e_sum  = 0.0
    m_sum  = 0.0
    m2_sum = 0.0

    for _ in 1:n_meas
        metropolis_sweep!(model)
        m       = magnetization(model)
        e_sum  += energy(model)
        m_sum  += abs(m)
        m2_sum += m^2
    end

    return Dict(
        "E"  => e_sum  / n_meas,
        "M"  => m_sum  / n_meas,
        "M2" => m2_sum / n_meas,
    )
end

# ---------------------------------------------------------------------------
# Temperature scan
# ---------------------------------------------------------------------------

L   = 16
Ts  = collect(range(1.0, 4.0, length=30))

println("Running temperature scan: L=$L, $(length(Ts)) temperatures")

results = [measure(T, L) for T in Ts]

Es  = [r["E"]  for r in results]
Ms  = [r["M"]  for r in results]
M2s = [r["M2"] for r in results]

# ---------------------------------------------------------------------------
# Plot
# ---------------------------------------------------------------------------

p = plot(Ts, M2s,
    xlabel = "T",
    ylabel = "⟨M²⟩",
    title  = "2D Ising model  (L=$L)",
    label  = "L=$L",
    marker = :circle,
    lw     = 2,
)

# Onsager's exact critical temperature
vline!(p, [2.269], label="Tc (Onsager)", linestyle=:dash, color=:red)

savefig(p, joinpath(@__DIR__, "M2_vs_T.png"))
println("Saved: analysis/M2_vs_T.png")
