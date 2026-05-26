# scripts/seir_sim.jl

using DrWatson
include(joinpath(@__DIR__, "..", "src", "seir_model.jl"))
using Random, StatsPlots

tmax = 40.0
u0 = [990, 0, 10, 0]   # S, E, I, R
p = [0.05, 10.0, 0.25, 0.2]  # β, c, γ, σ
Random.seed!(1234)

m = MakeSEIRModel(u0, p)
activate(m)
seir_run(m, tmax)
data = out(m)

@df data plot(:t, [:S :E :I :R], labels=["S" "E" "I" "R"], xlabel="Время", ylabel="Численность", title="SEIR модель")
savefig(joinpath("plots", "seir_des.png"))
println("График SEIR сохранён в plots/seir_des.png")
