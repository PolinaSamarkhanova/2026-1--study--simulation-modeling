# scripts/dining_philosophers_report.jl

using DrWatson
using DataFrames, CSV, Plots

df_classic = CSV.read(joinpath("data", "dining_classic.csv"), DataFrame)
df_arbiter = CSV.read(joinpath("data", "dining_arbiter.csv"), DataFrame)
N = 5

# Столбцы для состояния "Ест"
eat_cols = [Symbol("Eat_$i") for i = 1:N]

p1 = plot(
    df_classic.time,
    Matrix(df_classic[:, eat_cols]),
    label = ["Ф $i" for i = 1:N],
    xlabel = "Время",
    ylabel = "Ест (1/0)",
    title = "Классическая сеть",
)

p2 = plot(
    df_arbiter.time,
    Matrix(df_arbiter[:, eat_cols]),
    label = ["Ф $i" for i = 1:N],
    xlabel = "Время",
    ylabel = "Ест (1/0)",
    title = "Сеть с арбитром",
)

p_final = plot(p1, p2, layout = (2, 1), size = (800, 600))
savefig(joinpath("plots", "final_report.png"))

println("Отчёт сохранён в plots/final_report.png")
