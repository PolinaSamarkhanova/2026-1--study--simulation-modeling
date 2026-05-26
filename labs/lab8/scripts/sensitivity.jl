# scripts/sensitivity.jl

using DrWatson
include(joinpath(@__DIR__, "..", "src", "sir_model.jl"))
using Random, StatsPlots

tmax = 40.0
u0 = [990, 10, 0]
Random.seed!(1234)

# ---- β ----
betas = [0.03, 0.05, 0.07]
c_fixed = 10.0
γ_fixed = 0.25
p1 = plot(xlabel="Время", ylabel="Инфицированные", title="Чувствительность к β")
for β in betas
    m = MakeSIRModel(u0, [β, c_fixed, γ_fixed])
    activate(m)
    sir_run(m, tmax)
    data = out(m)
    plot!(p1, data.t, data.I, label="β=$β")
end
savefig(joinpath("plots", "sensitivity_beta.png"))

# ---- c ----
cs = [5.0, 10.0, 15.0]
β_fixed = 0.05
γ_fixed = 0.25
p2 = plot(xlabel="Время", ylabel="Инфицированные", title="Чувствительность к c")
for c_val in cs
    m = MakeSIRModel(u0, [β_fixed, c_val, γ_fixed])
    activate(m)
    sir_run(m, tmax)
    data = out(m)
    plot!(p2, data.t, data.I, label="c=$c_val")
end
savefig(joinpath("plots", "sensitivity_c.png"))

# ---- γ ----
γs = [0.15, 0.25, 0.35]
β_fixed = 0.05
c_fixed = 10.0
p3 = plot(xlabel="Время", ylabel="Инфицированные", title="Чувствительность к γ")
for γ_val in γs
    m = MakeSIRModel(u0, [β_fixed, c_fixed, γ_val])
    activate(m)
    sir_run(m, tmax)
    data = out(m)
    plot!(p3, data.t, data.I, label="γ=$γ_val")
end
savefig(joinpath("plots", "sensitivity_gamma.png"))

println("Графики чувствительности сохранены в plots/")
