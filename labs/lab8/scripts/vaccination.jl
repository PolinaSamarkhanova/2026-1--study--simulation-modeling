# scripts/vaccination.jl

using DrWatson
include(joinpath(@__DIR__, "..", "src", "sir_model_vacc.jl"))
using Random, StatsPlots

tmax = 40.0
u0 = [990, 10, 0]
p = [0.05, 10.0, 0.25]
Random.seed!(1234)

m = MakeSIRModel(u0, p)
activate(m)

# вакцинация через 10 единиц времени, вакцинируем 50% текущих восприимчивых
@process schedule_vaccination(m.sim, m, 10.0, 0.5)

sir_run(m, tmax)
data = out(m)

@df data plot(:t, [:S :I :R], labels=["S" "I" "R"], xlabel="Время", ylabel="Численность", title="SIR с вакцинацией 50% S на 10-й день")
savefig(joinpath("plots", "sir_vaccination.png"))
println("График вакцинации сохранён в plots/sir_vaccination.png")
