# scripts/sirpetri_report.jl

using DataFrames, CSV, Plots

df_det = CSV.read(joinpath("data", "sir_det.csv"), DataFrame)
df_stoch = CSV.read(joinpath("data", "sir_stoch.csv"), DataFrame)
df_scan = CSV.read(joinpath("data", "sir_scan.csv"), DataFrame)

# Сравнение детерминированной и стохастической динамики
p1 = plot(
    df_det.time,
    [df_det.I df_stoch.I[1:length(df_det.time)]],
    label = ["Deterministic I" "Stochastic I"],
    xlabel = "Time",
    ylabel = "Infected",
    title = "Comparison",
)

savefig(joinpath("plots", "comparison.png"))

# Зависимость пика I от β
p2 = plot(
    df_scan.β,
    df_scan.peak_I,
    marker = :circle,
    xlabel = "β",
    ylabel = "Peak I",
    title = "Sensitivity",
)

savefig(joinpath("plots", "sensitivity.png"))

println("Отчётные графики сохранены в plots/")
