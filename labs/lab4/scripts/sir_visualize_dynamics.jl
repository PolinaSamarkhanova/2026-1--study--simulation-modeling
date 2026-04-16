# scripts/sir_visualize_dynamics.jl

using DrWatson
using Agents, DataFrames, Plots, CSV

# Подключаем модель (для вспомогательных функций, если нужны)
include(joinpath(@__DIR__, "..", "src", "sir_model.jl"))

# Загружаем результаты сканирования
df = CSV.read(joinpath("data", "beta_scan_all.csv"), DataFrame)

# Создаём составной график
p1 = plot(df.beta, df.peak, label = "Пик", xlabel = "β", ylabel = "Доля инфицированных")
plot!(p1, df.beta, df.final_inf, label = "Конечная")

p2 = plot(df.beta, df.deaths, xlabel = "β", ylabel = "Число умерших")

p3 = plot(df.beta, df.final_rec, xlabel = "β", ylabel = "Доля выздоровевших")

plot(p1, p2, p3, layout = (3, 1), size = (800, 900))
savefig(joinpath("plots", "comprehensive_analysis.png"))

println("График сохранён в plots/comprehensive_analysis.png")
