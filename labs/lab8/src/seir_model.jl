# src/seir_model.jl

using ResumableFunctions, ConcurrentSim, Distributions, DataFrames, Random

function inc!(a) push!(a, a[end] + 1) end
function dec!(a) push!(a, a[end] - 1) end
function carry!(a) push!(a, a[end]) end

mutable struct SEIRPerson
    id::Int64
    status::Symbol   # :S, :E, :I, :R
end

mutable struct SEIRModel
    sim::ConcurrentSim.Simulation
    β::Float64
    c::Float64
    γ::Float64
    σ::Float64
    ta::Array{Float64}
    Sa::Array{Int64}
    Ea::Array{Int64}
    Ia::Array{Int64}
    Ra::Array{Int64}
    allIndividuals::Array{SEIRPerson}
end

function infection_update!(sim, m)
    push!(m.ta, ConcurrentSim.now(sim))
    dec!(m.Sa)
    inc!(m.Ea)
    carry!(m.Ia)
    carry!(m.Ra)
end

function latent_update!(sim, m)
    push!(m.ta, ConcurrentSim.now(sim))
    carry!(m.Sa)
    dec!(m.Ea)
    inc!(m.Ia)
    carry!(m.Ra)
end

function recovery_update!(sim, m)
    push!(m.ta, ConcurrentSim.now(sim))
    carry!(m.Sa)
    carry!(m.Ea)
    dec!(m.Ia)
    inc!(m.Ra)
end

@resumable function live(env, individual, m)
    while individual.status == :S
        @yield timeout(env, rand(Exponential(1/m.c)))
        alter = individual
        while alter == individual
            N = length(m.allIndividuals)
            alter = m.allIndividuals[rand(DiscreteUniform(1, N))]
        end
        if alter.status == :I && rand() < m.β
            individual.status = :E
            infection_update!(env, m)
        end
    end
    if individual.status == :E
        @yield timeout(env, rand(Exponential(1/m.σ)))
        individual.status = :I
        latent_update!(env, m)
    end
    if individual.status == :I
        @yield timeout(env, rand(Exponential(1/m.γ)))
        individual.status = :R
        recovery_update!(env, m)
    end
end

function MakeSEIRModel(u0, p)
    S0, E0, I0, R0 = u0
    N = S0 + E0 + I0 + R0
    β, c, γ, σ = p
    sim = ConcurrentSim.Simulation()
    allIndividuals = SEIRPerson[]
    for i in 1:S0
        push!(allIndividuals, SEIRPerson(i, :S))
    end
    for i in (S0+1):(S0+E0)
        push!(allIndividuals, SEIRPerson(i, :E))
    end
    for i in (S0+E0+1):(S0+E0+I0)
        push!(allIndividuals, SEIRPerson(i, :I))
    end
    for i in (S0+E0+I0+1):N
        push!(allIndividuals, SEIRPerson(i, :R))
    end
    ta = [0.0]
    Sa = [S0]
    Ea = [E0]
    Ia = [I0]
    Ra = [R0]
    SEIRModel(sim, β, c, γ, σ, ta, Sa, Ea, Ia, Ra, allIndividuals)
end

function activate(m::SEIRModel)
    for ind in m.allIndividuals
        @process live(m.sim, ind, m)
    end
end

function seir_run(m::SEIRModel, tf::Float64)
    ConcurrentSim.run(m.sim, tf)
end

function out(m::SEIRModel)
    DataFrame(t=m.ta, S=m.Sa, E=m.Ea, I=m.Ia, R=m.Ra)
end
