# scripts/compare_recovery.jl

using DrWatson
include(joinpath(@__DIR__, "..", "src", "sir_model.jl"))
include(joinpath(@__DIR__, "..", "src", "sir_model_det.jl"))
using Random, StatsPlots

tmax = 40.0
u0 = [990, 10, 0]
p = [0.05, 10.0, 0.25]
Random.seed!(1234)

# Стохастическая (экспоненциальное выздоровление)
m_stoch = MakeSIRModel(u0, p)
activate(m_stoch)
sir_run(m_stoch, tmax)
data_stoch = out(m_stoch)

# Детерминированная (фиксированное время)
m_det = MakeSIRModelDet(u0, p)
activate_det(m_det)
sir_run_det(m_det, tmax)
data_det = out_det(m_det)

plot(data_stoch.t, data_stoch.I, label="Stochastic (exp)", xlabel="Time", ylabel="Infected", linewidth=2)
plot!(data_det.t, data_det.I, label="Deterministic (fixed recovery)", linestyle=:dash)
title!("Сравнение случайного и фиксированного времени выздоровления")
savefig(joinpath("plots", "compare_recovery.png"))
println("График сравнения сохранён в plots/compare_recovery.png")
