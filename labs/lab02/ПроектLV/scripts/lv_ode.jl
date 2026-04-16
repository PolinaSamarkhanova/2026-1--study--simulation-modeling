using DrWatson
@quickactivate "ПроектLV"

using DifferentialEquations
using DataFrames
using StatsPlots
using LaTeXStrings
using Plots
using Statistics
using FFTW

script_name = splitdir(splitext(basename(PROGRAM_FILE))[1])[2]
mkpath(plotsdir(script_name))
mkpath(datadir(script_name))

# Модель Лотки-Вольтерры
function lotka_volterra!(du, u, p, t)
    x, y = u
    α, β, δ, γ = p
    du[1] = α*x - β*x*y
    du[2] = δ*x*y - γ*y
    nothing
end

# Параметры
p_lv = [0.1, 0.02, 0.01, 0.3]
u0_lv = [40.0, 9.0]
tspan_lv = (0.0, 200.0)
dt_lv = 0.01

# Решение
prob_lv = ODEProblem(lotka_volterra!, u0_lv, tspan_lv, p_lv)
sol_lv = solve(prob_lv, Tsit5(), reltol=1e-8, abstol=1e-10, saveat=0.1)

# Данные
df_lv = DataFrame(t=sol_lv.t, prey=[u[1] for u in sol_lv.u], predator=[u[2] for u in sol_lv.u])

# Производные
df_lv[!, :dprey_dt] = p_lv[1] .* df_lv.prey .- p_lv[2] .* df_lv.prey .* df_lv.predator
df_lv[!, :dpredator_dt] = p_lv[3] .* df_lv.prey .* df_lv.predator .- p_lv[4] .* df_lv.predator

# Вывод
println("="^60)
println("Модель Лотки-Вольтерры")
println("="^60)
println("α=", p_lv[1], " β=", p_lv[2], " δ=", p_lv[3], " γ=", p_lv[4])
println("x0=", u0_lv[1], " y0=", u0_lv[2])

# Стационарные точки
x_star = p_lv[4]/p_lv[3]
y_star = p_lv[1]/p_lv[2]
println("x*=", round(x_star, digits=3), " y*=", round(y_star, digits=3))

# График 1
plt1 = plot(df_lv.t, [df_lv.prey df_lv.predator], label=["Жертвы" "Хищники"], 
    xlabel="Время", ylabel="Популяция", title="Динамика", linewidth=2, 
    color=[:green :red])
hline!(plt1, [x_star], color=:green, linestyle=:dash, alpha=0.5, label="x*")
hline!(plt1, [y_star], color=:red, linestyle=:dash, alpha=0.5, label="y*")

# График 2
plt2 = plot(df_lv.prey, df_lv.predator, label="Фазовая траектория", 
    xlabel="Жертвы", ylabel="Хищники", title="Фазовый портрет", 
    color=:blue, linewidth=1.5)

# Стрелки
step = 50
for i in 1:step:length(df_lv.prey)-step
    plot!(plt2, [df_lv.prey[i], df_lv.prey[i+step]], 
        [df_lv.predator[i], df_lv.predator[i+step]], 
        arrow=:closed, color=:blue, alpha=0.3, label=false)
end

scatter!(plt2, [x_star], [y_star], color=:black, markersize=8, label="Точка равновесия")

# Изоклины
x_range = LinRange(0, maximum(df_lv.prey)*1.1, 100)
y_nullcline = p_lv[1] ./ (p_lv[2] .* x_range)
plot!(plt2, x_range, y_nullcline, color=:red, linestyle=:dash, label="dy/dt=0")

y_range = LinRange(0, maximum(df_lv.predator)*1.1, 100)
x_nullcline = fill(p_lv[4]/p_lv[3], length(y_range))
plot!(plt2, x_nullcline, y_range, color=:green, linestyle=:dash, label="dx/dt=0")

# График 3
plt3 = plot(df_lv.t, [df_lv.dprey_dt df_lv.dpredator_dt], 
    label=["dx/dt" "dy/dt"], xlabel="Время", ylabel="Скорость", 
    title="Производные", color=[:green :red])
hline!(plt3, [0], color=:black, linestyle=:solid, alpha=0.3, label=false)

# График 4
df_lv[!, :prey_pct] = df_lv.dprey_dt ./ df_lv.prey .* 100
df_lv[!, :predator_pct] = df_lv.dpredator_dt ./ df_lv.predator .* 100

plt4 = plot(df_lv.t, [df_lv.prey_pct df_lv.predator_pct], 
    label=["dx/x %" "dy/y %"], xlabel="Время", ylabel="%", 
    title="Относит. изменения", color=[:green :red])

# График 5 - спектр
function compute_fft(signal, dt)
    n = length(signal)
    spectrum = abs.(rfft(signal .- mean(signal)))
    freq = rfftfreq(n, 1/dt)
    return freq, spectrum
end

freq_prey, spec_prey = compute_fft(df_lv.prey, dt_lv)
freq_pred, spec_pred = compute_fft(df_lv.predator, dt_lv)

plt5 = plot(freq_prey, [spec_prey spec_pred], label=["Жертвы" "Хищники"],
    xlabel="Частота", ylabel="Амплитуда", title="Спектр", 
    xscale=:log10, yscale=:log10, color=[:green :red])

# График 6 - панель
plt6 = plot(layout=(3,2), size=(1200,900))
plot!(plt6[1], df_lv.t, df_lv.prey, label="x(t)", color=:green, title="Жертвы")
plot!(plt6[2], df_lv.t, df_lv.predator, label="y(t)", color=:red, title="Хищники")
plot!(plt6[3], df_lv.prey, df_lv.predator, label=false, color=:blue, title="Фазовый портрет")
scatter!(plt6[3], [x_star], [y_star], color=:black, markersize=5, label="точка")
plot!(plt6[4], df_lv.t, [df_lv.dprey_dt df_lv.dpredator_dt], label=["dx/dt" "dy/dt"], 
    color=[:green :red], title="Скорости")
plot!(plt6[5], freq_prey, spec_prey, label="спектр", color=:green, title="Спектр жертв", 
    xscale=:log10, yscale=:log10)
plot!(plt6[6], df_lv.t, [df_lv.prey_pct df_lv.predator_pct], 
    label=["dx/x" "dy/y"], color=[:green :red], title="Отн. изменения")

# Сохранение
savefig(plt1, plotsdir(script_name, "lv_dynamics.png"))
savefig(plt2, plotsdir(script_name, "lv_phase.png"))
savefig(plt3, plotsdir(script_name, "lv_derivatives.png"))
savefig(plt4, plotsdir(script_name, "lv_relative.png"))
savefig(plt5, plotsdir(script_name, "lv_spectrum.png"))
savefig(plt6, plotsdir(script_name, "lv_panel.png"))

println("\nГотово! Графики сохранены в plots/", script_name)