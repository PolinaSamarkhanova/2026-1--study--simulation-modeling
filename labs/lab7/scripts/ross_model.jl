# scripts/ross_model.jl

using DrWatson
using Plots, DataFrames, CSV

include(joinpath(@__DIR__, "..", "src", "RossModel.jl"))
using .RossModel

# 1. Базовый прогон (один ремонтник)
println("=== Базовый прогон (N=10, S=3, 1 ремонтник) ===")
p_base = MachineParams(10, 3, 100.0, 1.0, 1)
mean_t, times = run_multiple(p_base; runs=5)
println("Среднее время до краха: $mean_t")
println("Индивидуальные времена: $times")
CSV.write(joinpath("data", "ross_base.csv"), DataFrame(run=1:5, crash_time=times))

# 2. Влияние числа ремонтников
println("\n=== Влияние числа ремонтников ===")
repairmen_range = 1:4
mean_times_rep = []
for r in repairmen_range
    p = MachineParams(10, 3, 100.0, 1.0, r)
    mt, _ = run_multiple(p; runs=5)
    push!(mean_times_rep, mt)
    println("Ремонтников $r: среднее время = $mt")
end
plot(repairmen_range, mean_times_rep, marker=:circle,
     xlabel="Число ремонтников", ylabel="Среднее время до краха",
     title="Зависимость от числа ремонтников")
savefig(joinpath("plots", "ross_repairmen.png"))

# 3. Влияние N (числа работающих машин) при S=3, одном ремонтнике
println("\n=== Влияние числа работающих машин N ===")
N_range = [5, 10, 15, 20]
mean_times_N = []
for n in N_range
    p = MachineParams(n, 3, 100.0, 1.0, 1)
    mt, _ = run_multiple(p; runs=5)
    push!(mean_times_N, mt)
    println("N=$n: среднее время = $mt")
end
plot(N_range, mean_times_N, marker=:circle,
     xlabel="Число работающих машин N", ylabel="Среднее время до краха",
     title="Влияние N (S=3, 1 ремонтник)")
savefig(joinpath("plots", "ross_N.png"))

# 4. Влияние S (резервных машин) при N=10, одном ремонтнике
println("\n=== Влияние числа резервных машин S ===")
S_range = [1, 3, 5, 7, 10]
mean_times_S = []
for s in S_range
    p = MachineParams(10, s, 100.0, 1.0, 1)
    mt, _ = run_multiple(p; runs=5)
    push!(mean_times_S, mt)
    println("S=$s: среднее время = $mt")
end
plot(S_range, mean_times_S, marker=:circle,
     xlabel="Число резервных машин S", ylabel="Среднее время до краха",
     title="Влияние S (N=10, 1 ремонтник)")
savefig(joinpath("plots", "ross_S.png"))

println("\nВсе графики сохранены в папку plots/")
