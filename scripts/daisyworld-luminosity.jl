using Agents
using DataFrames
using CairoMakie
using StatsBase
using Random

include("../src/daisyworld.jl")

black(a::Daisy) = a.breed == :black
white(a::Daisy) = a.breed == :white
adata = [(black, count), (white, count)]

model = daisyworld(; solar_luminosity = 1.0, scenario = :ramp)

temperature(model) = StatsBase.mean(model.temperature)
mdata = [temperature, :solar_luminosity]

println("Запуск модели на 1000 шагов...")
agent_df, model_df = run!(model, 1000; adata = adata, mdata = mdata)

println("Построение комплексного графика...")

figure = CairoMakie.Figure(size = (600, 600))

# Первый график: количество маргариток
ax1 = figure[1, 1] = Axis(figure, ylabel = "daisy count")
black1 = lines!(ax1, agent_df[:, :time], agent_df[:, :count_black]; color = :red)
white1 = lines!(ax1, agent_df[:, :time], agent_df[:, :count_white]; color = :blue)

# Легенда
figure[1, 2] = Legend(figure, [black1, white1], ["black", "white"])

# Второй график: температура
ax2 = figure[2, 1] = Axis(figure, ylabel = "temperature")
lines!(ax2, model_df[:, :time], model_df[:, :temperature]; color = :red)

# Третий график: солнечная luminosity
ax3 = figure[3, 1] = Axis(figure, xlabel = "tick", ylabel = "luminosity")
lines!(ax3, model_df[:, :time], model_df[:, :solar_luminosity]; color = :red)

# Скрываем метки x для верхних графиков
for ax in (ax1, ax2)
    ax.xticklabelsvisible = false
end

# Сохраняем график
mkpath("plots")
save("plots/daisy_luminosity.png", figure)

println("График сохранен: plots/daisy_luminosity.png")
println("Готово!")
