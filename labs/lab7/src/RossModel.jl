module RossModel

using Random, Distributions, Statistics

export MachineParams, run_simulation, run_multiple

struct MachineParams
    N::Int          # количество работающих машин
    S::Int          # количество резервных машин
    λ::Float64      # интенсивность отказов (среднее время = 1/λ)
    μ::Float64      # интенсивность ремонта (среднее время = 1/μ)
    num_repairmen::Int
end

"""
    run_simulation(params; seed=150)

Моделирует процесс отказов и ремонтов, возвращает время до исчерпания резерва (краха).
Используется событийный подход: отказы происходят с интенсивностью N * λ,
ремонты – с интенсивностью num_repairmen * μ при наличии сломанных машин.
"""
function run_simulation(params::MachineParams; seed=150)
    rng = MersenneTwister(seed)

    # Состояние системы
    spares = params.S         # количество исправных машин в резерве
    in_repair = 0             # количество машин, находящихся в ремонте (включая обслуживаемые)
    # Динамический список времён окончания ремонтов
    repair_end_times = Float64[]
    t = 0.0                   # текущее время

    while true
        # Интенсивность отказов (работающих машин всегда N, пока есть исправные)
        λ_fail = params.N * params.λ

        # Если очередь ремонтов пуста – следующее событие только отказ
        if isempty(repair_end_times)
            dt = rand(rng, Exponential(1.0 / λ_fail))
            t += dt
            # Произошёл отказ
            if spares > 0
                spares -= 1
                in_repair += 1
                # Пытаемся начать ремонт, если есть свободный ремонтник
                if length(repair_end_times) < params.num_repairmen
                    repair_time = rand(rng, Exponential(1.0 / params.μ))
                    push!(repair_end_times, t + repair_time)
                end
            else
                return t   # крах системы
            end
        else
            # Есть активные ремонты – находим ближайший
            next_repair_end = minimum(repair_end_times)
            dt_repair = next_repair_end - t
            # Время до следующего отказа (экспоненциальное)
            dt_fail = rand(rng, Exponential(1.0 / λ_fail))

            if dt_fail < dt_repair
                # Отказ произойдёт раньше ремонта
                t += dt_fail
                if spares > 0
                    spares -= 1
                    in_repair += 1
                    if length(repair_end_times) < params.num_repairmen
                        repair_time = rand(rng, Exponential(1.0 / params.μ))
                        push!(repair_end_times, t + repair_time)
                    end
                else
                    return t
                end
            else
                # Ремонт завершится раньше отказа
                t = next_repair_end
                # Удаляем завершённый ремонт из списка
                filter!(x -> x != next_repair_end, repair_end_times)
                in_repair -= 1
                spares += 1
                # Если есть ожидающие ремонта (in_repair > кол-ва активных ремонтов),
                # запускаем новый ремонт
                if in_repair > length(repair_end_times)
                    repair_time = rand(rng, Exponential(1.0 / params.μ))
                    push!(repair_end_times, t + repair_time)
                end
            end
        end
    end
end

"""
    run_multiple(params; runs=5)

Запускает несколько повторностей, возвращает среднее время до краха и массив всех времён.
"""
function run_multiple(params::MachineParams; runs=5)
    times = Float64[]
    base_seed = 150
    for i in 1:runs
        t = run_simulation(params; seed = base_seed + i - 1)
        push!(times, t)
    end
    return mean(times), times
end

end # module
