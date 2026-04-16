using Agents
using DataFrames
using CairoMakie
using StatsBase
using Random

include("../src/daisyworld.jl")

black(a::Daisy) = a.breed == :black
white(a::Daisy) = a.breed == :white
adata = [(black, count), (white, count)]

model = daisyworld(; solar_luminosity = 1.0)

println("Запуск модели на 1000 шагов...")
agent_df, model_df = run!(model, 1000; adata)

println("Построение графика...")
figure = Figure(size = (600, 400))

ax = figure[1, 1] = Axis(figure, xlabel = "tick", ylabel = "daisy count")
blackl = lines!(ax, agent_df[:, :time], agent_df[:, :count_black]; color = :black)
whitel = lines!(ax, agent_df[:, :time], agent_df[:, :count_white]; color = :orange)
Legend(figure[1, 2], [blackl, whitel], ["black", "white"], labelsize = 12)

mkpath("plots")
save("plots/daisy_count.png", figure)

println("График сохранен: plots/daisy_count.png")
println("Готово!")
