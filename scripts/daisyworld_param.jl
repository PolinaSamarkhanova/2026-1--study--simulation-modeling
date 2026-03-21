using Agents
using DataFrames
using CairoMakie
using StatsBase
using Random
using IterTools

include("../src/daisyworld.jl")

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
    
    daisycolor(a::Daisy) = a.breed
    
    plotkwargs = (
        agent_color = daisycolor,
        agent_size = 20,
        agent_marker = '★',
        heatarray = :temperature,
        heatkwargs = (colorrange = (-20, 60),),
    )
    
    plt1, _ = abmplot(model; plotkwargs...)
    
    step!(model, 5)
    plt2, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
    
    step!(model, 40)
    plt3, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
    
    # Создаем имена файлов
    plt1_name = "daisyworld_maxage$(params[:max_age])_white$(params[:init_white])_step01.png"
    plt2_name = "daisyworld_maxage$(params[:max_age])_white$(params[:init_white])_step05.png"
    plt3_name = "daisyworld_maxage$(params[:max_age])_white$(params[:init_white])_step45.png"
    
    mkpath("plots")
    save(joinpath("plots", plt1_name), plt1)
    save(joinpath("plots", plt2_name), plt2)
    save(joinpath("plots", plt3_name), plt3)
    
    println("  Сохранено: $plt1_name, $plt2_name, $plt3_name")
end

println("Готово! Все графики сохранены в папку plots/")
