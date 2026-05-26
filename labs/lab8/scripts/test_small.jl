using DrWatson
include(joinpath(@__DIR__, "..", "src", "sir_model.jl"))
using Random

u0 = [990, 10, 0]   # 1000 особей
p = [0.05, 10.0, 0.25]
tmax = 40.0
Random.seed!(1234)

println("Создаём модель...")
m = MakeSIRModel(u0, p)
activate(m)

println("Запускаем симуляцию...")
sir_run(m, tmax)
println("Симуляция завершена!")
