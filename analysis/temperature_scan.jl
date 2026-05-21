using compphys_Shinaoka

# Parameters
const L        = 16
const N_THERM  = 500   # thermalization sweeps (discarded)
const N_MEAS   = 500   # measurement sweeps

function temperature_scan(betas)
    ms = Float64[]
    es = Float64[]

    for β in betas
        model = IsingModel(L, β, seed=42)

        # thermalization
        run_simulation!(model, N_THERM)

        # measurement
        m_sum = 0.0
        e_sum = 0.0
        for _ in 1:N_MEAS
            metropolis_sweep!(model)
            m_sum += abs(magnetization(model))
            e_sum += energy(model)
        end

        push!(ms, m_sum / N_MEAS)
        push!(es, e_sum / N_MEAS)
    end

    return ms, es
end

betas = range(0.1, 1.5, length=30)
ms, es = temperature_scan(collect(betas))

for (β, m, e) in zip(betas, ms, es)
    println("β=$(round(β, digits=3))  |m|=$(round(m, digits=4))  E=$(round(e, digits=2))")
end
