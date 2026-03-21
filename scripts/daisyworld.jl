using Agents
using DataFrames
using Plots
using CairoMakie
using StatsBase
using Random

include("../src/daisyworld.jl")

model = daisyworld()

daisycolor(a::Daisy) = a.breed

plotkwargs = (
    agent_color = daisycolor,
    agent_size = 20,
    agent_marker = '★',
    heatarray = :temperature,
    heatkwargs = (colorrange = (-20, 60),),
)

# Создаем папку для сохранения графиков
mkpath("plots")

println("Шаг 0...")
plt1, _ = abmplot(model; plotkwargs...)
save("plots/step0.png", plt1)
println("Сохранено: plots/step0.png")

println("Шаг 5...")
step!(model, 5)
plt2, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
save("plots/step5.png", plt2)
println("Сохранено: plots/step5.png")

println("Шаг 45...")
step!(model, 40)
plt3, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
save("plots/step45.png", plt3)
println("Сохранено: plots/step45.png")

println("Готово! Графики сохранены в папку plots/")
