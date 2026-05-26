# scripts/sir_des.jl

using DrWatson
include(joinpath(@__DIR__, "..", "src", "sir_model.jl"))
using Random, StatsPlots, CSV, Dates

tmax = 40.0
u0 = [990, 10, 0]
p = [0.05, 10.0, 0.25]   # β, c, γ
Random.seed!(1234)

des_model = MakeSIRModel(u0, p)
activate(des_model)
sir_run(des_model, tmax)
data_des = out(des_model)

# График
@df data_des plot(:t, [:S :I :R], labels=["S" "I" "R"], xlabel="Время", ylabel="Численность", title="Дискретно-событийная SIR")
savefig(joinpath("plots", "sir_des.png"))

# CSV
filename = "sir_$(u0[1])_$(u0[2])_$(p[1])_$(p[2])_$(p[3]).csv"
CSV.write(joinpath("data", filename), data_des)

println("Базовый прогон завершён. График: plots/sir_des.png, данные: data/$filename")
