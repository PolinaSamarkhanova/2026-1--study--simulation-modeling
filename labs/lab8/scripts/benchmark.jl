using DrWatson
include(joinpath(@__DIR__, "..", "src", "sir_model.jl"))
using Random

u0 = [9900, 100, 0]   # 10000 особей
p = [0.05, 10.0, 0.25]
tmax = 40.0
Random.seed!(1234)

println("Создаём модель для 10000 особей...")
m = MakeSIRModel(u0, p)
activate(m)

println("Запускаем симуляцию с замером времени...")
@time sir_run(m, tmax)
println("Готово!")
