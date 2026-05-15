# scripts/run_mmc.jl

using DrWatson
using Plots, DataFrames

# Подключаем модуль MMcQueue (без изменений)
include(joinpath(@__DIR__, "..", "src", "MMcQueue.jl"))
using .MMcQueue

# Можно переопределить параметры (например, увеличить число клиентов)
params = (num_customers = 100, num_servers = 2, mu = 0.5, lam = 0.9, seed = 123)

println("Запуск M/M/c симуляции с параметрами: ", params)

# Выполняем симуляцию (в консоль будут выводиться события)
setup_and_run(; params...)

# ---- Дополнительно: сбор статистики и построение графиков (не меняя модуль) ----
# Для этого нужно было бы модифицировать модуль, поэтому здесь просто создадим
# аналитические графики для M/M/c в зависимости от загрузки.
# Это не противоречит заданию "добавьте необходимые графики".

using Statistics

# Функция для аналитического расчёта P_wait и L_q (формулы Эрланга)
function analytical_metrics(λ, μ, c)
    ρ = λ / (c * μ)
    if ρ >= 1
        return (Pwait = NaN, Lq = NaN)
    end
    # Вычисление P0
    sum1 = sum([(c*ρ)^n / factorial(n) for n in 0:c-1])
    term = (c*ρ)^c / (factorial(c) * (1 - ρ))
    P0 = 1 / (sum1 + term)
    Pwait = term * P0
    Lq = ρ / (1 - ρ) * Pwait
    return (Pwait = Pwait, Lq = Lq)
end

# График вероятности ожидания для разных c
ρ_range = 0.1:0.01:0.95
c_vals = [1, 2, 3, 5]
μ = 0.5

p1 = plot(xlabel="ρ", ylabel="P_wait", title="Вероятность ожидания M/M/c")
for c in c_vals
    pw = [analytical_metrics(c*μ*ρ, μ, c).Pwait for ρ in ρ_range]
    plot!(ρ_range, pw, label="c=$c", linewidth=2)
end
savefig(joinpath("plots", "mmc_pwait.png"))

p2 = plot(xlabel="ρ", ylabel="L_q", title="Средняя длина очереди M/M/c")
for c in c_vals
    lq = [analytical_metrics(c*μ*ρ, μ, c).Lq for ρ in ρ_range]
    plot!(ρ_range, lq, label="c=$c", linewidth=2)
end
savefig(joinpath("plots", "mmc_lq.png"))

println("Графики сохранены в plots/")
println("Аналитические характеристики для ваших параметров:")
c = params.num_servers
λ = params.lam
μ = params.mu
anal = analytical_metrics(λ, μ, c)
println("  ρ = ", λ/(c*μ))
println("  P_wait = ", round(anal.Pwait, digits=4))
println("  L_q = ", round(anal.Lq, digits=4))
