using Agents, DataFrames, Plots
using JLD2
using DrWatson

# Подключаем модель из папки src
include(joinpath(@__DIR__, "..", "src", "sir_model.jl"))

# Параметры эксперимента
params = Dict(
    :Ns => [1000, 1000, 1000],
    :B_und => [0.5, 0.5, 0.5],
    :B_det => [0.05, 0.05, 0.05],
    :infection_period => 14,
    :detection_time => 7,
    :death_rate => 0.02,
    :reinfection_probability => 0.1,
    :Is => [0, 0, 1],
    :seed => 42,
    :n_steps => 100,
)

# Инициализация модели
model = initialize_sir(; params...)

# Подготовка массивов для хранения данных
times = Int[]
S_vals = Int[]
I_vals = Int[]
R_vals = Int[]
total_vals = Int[]

# Запуск симуляции вручную
for step = 1:params[:n_steps]
    Agents.step!(model, 1)

    push!(times, step)
    push!(S_vals, susceptible_count(model))
    push!(I_vals, infected_count(model))
    push!(R_vals, recovered_count(model))
    push!(total_vals, total_count(model))
end

# Создаём DataFrame
agent_df = DataFrame(time = times, susceptible = S_vals, infected = I_vals, recovered = R_vals)
model_df = DataFrame(time = times, total = total_vals)

# Визуализация
plot(
    agent_df.time,
    agent_df.susceptible,
    label = "Восприимчивые",
    xlabel = "Дни",
    ylabel = "Количество",
)
plot!(agent_df.time, agent_df.infected, label = "Инфицированные")
plot!(agent_df.time, agent_df.recovered, label = "Выздоровевшие")
plot!(agent_df.time, model_df.total, label = "Всего (включая умерших)", linestyle = :dash)
savefig(joinpath("plots", "sir_basic_dynamics.png"))

# Сохранение данных
@save joinpath("data", "sir_basic_agent.jld2") agent_df
@save joinpath("data", "sir_basic_model.jld2") model_df
