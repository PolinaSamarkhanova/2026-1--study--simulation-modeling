using Agents
using DataFrames
using CairoMakie
using StatsBase
using Random
using IterTools

include("../src/daisyworld.jl")

# Функции для подсчета маргариток
black(a::Daisy) = a.breed == :black
white(a::Daisy) = a.breed == :white
adata = [(black, count), (white, count)]

# Функция для создания комбинаций параметров
function dict_list(dict)
    keys_list = collect(keys(dict))
    values_list = [dict[k] isa Vector ? dict[k] : [dict[k]] for k in keys_list]
    
    result = []
    for combo in product(values_list...)
        d = Dict(keys_list[i] => combo[i] for i in 1:length(keys_list))
        push!(result, d)
    end
    return result
end

# Параметры эксперимента
param_dict = Dict(
    :griddims => (30, 30),
    :max_age => [25, 40],
    :init_white => [0.2, 0.8],
    :init_black => 0.2,
    :albedo_white => 0.75,
    :albedo_black => 0.25,
    :surface_albedo => 0.4,
    :solar_change => 0.005,
    :solar_luminosity => 1.0,
    :scenario => :default,
    :seed => 165,
)

# Создаем список всех комбинаций
params_list = dict_list(param_dict)

println("Всего комбинаций параметров: ", length(params_list))

for (i, params) in enumerate(params_list)
    println("Обработка комбинации $i из $(length(params_list))...")
    
    model = daisyworld(; params...)
    
    # Запуск модели на 1000 шагов
    agent_df, model_df = run!(model, 1000; adata)
    
    # Создание графика
    figure = Figure(size = (600, 400))
    ax = figure[1, 1] = Axis(figure, xlabel = "tick", ylabel = "daisy count")
    blackl = lines!(ax, agent_df[:, :time], agent_df[:, :count_black]; color = :black)
    whitel = lines!(ax, agent_df[:, :time], agent_df[:, :count_white]; color = :orange)
    Legend(figure[1, 2], [blackl, whitel], ["black", "white"], labelsize = 12)
    
    # Создание имени файла
    plt_name = "daisy-count_maxage$(params[:max_age])_white$(params[:init_white]).png"
    
    mkpath("plots")
    save(joinpath("plots", plt_name), figure)
    
    println("  Сохранено: $plt_name")
end

println("Готово! Все графики сохранены в папку plots/")
