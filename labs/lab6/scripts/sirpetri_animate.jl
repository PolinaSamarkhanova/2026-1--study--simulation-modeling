# scripts/sirpetri_animate.jl

using Plots
using Random

include(joinpath(@__DIR__, "..", "src", "SIRPetri.jl"))
using .SIRPetri

# Параметры
β = 0.3
γ = 0.1
tmax = 50.0

# Создаём сеть и запускаем детерминированную симуляцию
net, u0, _ = build_sir_network(β, γ)
df = simulate_deterministic(net, u0, (0.0, tmax), saveat = 0.5, rates = [β, γ])

# Анимация
anim = @animate for i in 1:length(df.time)
    plot(df.time[1:i], [df.S[1:i], df.I[1:i], df.R[1:i]],
         label = ["S" "I" "R"],
         xlims = (0, tmax), ylims = (0, maximum([df.S; df.I; df.R])),
         xlabel = "Time", ylabel = "Population",
         title = "SIR Dynamics, β = $β, γ = $γ, t = $(round(df.time[i], digits=2))",
         lw = 2)
end

gif(anim, joinpath("plots", "sir_dynamics.gif"), fps = 20)
println("Анимация сохранена в plots/sir_dynamics.gif")
