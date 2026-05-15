# src/MMcQueue.jl

module MMcQueue

using StableRNGs
using Distributions
using ConcurrentSim
using ResumableFunctions

export setup_and_run, SimulationParams

# Структура для хранения параметров (добавлено для удобства, но не меняет логику)
struct SimulationParams
    num_customers::Int
    num_servers::Int
    mu::Float64
    lam::Float64
    seed::Int
end

# Задание параметров по умолчанию (как в методичке)
default_params = SimulationParams(10, 2, 1.0/2, 0.9, 123)

# Функция поведения клиента (точно из методички)
@resumable function customer(
    env::Environment,
    server::Resource,
    id::Integer,
    t_a::Float64,
    d_s::Distribution,
    rng::StableRNG,
)
    @yield timeout(env, t_a)   # клиент прибывает
    println("Customer $id arrived: ", now(env))
    @yield request(server)      # клиент начинает обслуживание
    @yield timeout(env, rand(rng, d_s))  # сервер занят
    @yield release(server)      # клиент покидает сервер (в методичке используется unlock, но release — корректно)
    println("Customer $id exited service: ", now(env))
end

# Функция настройки и запуска симуляции (точно из методички)
function setup_and_run(;
    num_customers = default_params.num_customers,
    num_servers = default_params.num_servers,
    mu = default_params.mu,
    lam = default_params.lam,
    seed = default_params.seed,
)
    rng = StableRNG(seed)
    arrival_dist = Exponential(1 / lam)
    service_dist = Exponential(1 / mu)

    sim = Simulation()
    server = Resource(sim, num_servers)

    arrival_time = 0.0
    for i in 1:num_customers
        arrival_time += rand(rng, arrival_dist)
        @process customer(sim, server, i, arrival_time, service_dist, rng)
    end

    run(sim)
end

end # module
