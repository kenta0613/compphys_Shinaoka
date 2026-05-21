module compphys_Shinaoka

include("ising.jl")

export init_spins, IsingModel, magnetization, energy, calc_dE, metropolis_step!, metropolis_sweep!

end # module compphys_Shinaoka
