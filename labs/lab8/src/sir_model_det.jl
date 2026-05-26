# src/sir_model_det.jl

using ResumableFunctions, ConcurrentSim, Distributions, DataFrames, Random

function increment_det!(a::Array{Int64})
    push!(a, a[end] + 1)
end
function decrement_det!(a::Array{Int64})
    push!(a, a[end] - 1)
end
function carryover_det!(a::Array{Int64})
    push!(a, a[end])
end

mutable struct SIRPersonDet
    id::Int64
    status::Symbol
end

mutable struct SIRModelDet
    sim::ConcurrentSim.Simulation
    β::Float64
    c::Float64
    γ::Float64
    ta::Array{Float64}
    Sa::Array{Int64}
    Ia::Array{Int64}
    Ra::Array{Int64}
    allIndividuals::Array{SIRPersonDet}
end

function infection_update_det!(sim::ConcurrentSim.Simulation, m::SIRModelDet)
    push!(m.ta, ConcurrentSim.now(sim))
    decrement_det!(m.Sa)
    increment_det!(m.Ia)
    carryover_det!(m.Ra)
end

function recovery_update_det!(sim::ConcurrentSim.Simulation, m::SIRModelDet)
    push!(m.ta, ConcurrentSim.now(sim))
    carryover_det!(m.Sa)
    decrement_det!(m.Ia)
    increment_det!(m.Ra)
end

@resumable function live_det(env::ConcurrentSim.Simulation, individual::SIRPersonDet, m::SIRModelDet)
    while individual.status == :S
        @yield timeout(env, rand(Exponential(1/m.c)))
        alter = individual
        while alter == individual
            N = length(m.allIndividuals)
            index = rand(DiscreteUniform(1, N))
            alter = m.allIndividuals[index]
        end
        if alter.status == :I && rand() < m.β
            individual.status = :I
            infection_update_det!(env, m)
        end
    end
    if individual.status == :I
        # !!! фиксированное время выздоровления, а не экспоненциальное !!!
        @yield timeout(env, 1/m.γ)
        individual.status = :R
        recovery_update_det!(env, m)
    end
end

function MakeSIRModelDet(u0, p)
    S, I, R = u0
    N = S + I + R
    β, c, γ = p
    sim = ConcurrentSim.Simulation()
    allIndividuals = SIRPersonDet[]
    for i in 1:S
        push!(allIndividuals, SIRPersonDet(i, :S))
    end
    for i in (S+1):(S+I)
        push!(allIndividuals, SIRPersonDet(i, :I))
    end
    for i in (S+I+1):N
        push!(allIndividuals, SIRPersonDet(i, :R))
    end
    ta = Float64[0.0]
    Sa = Int64[S]
    Ia = Int64[I]
    Ra = Int64[R]
    SIRModelDet(sim, β, c, γ, ta, Sa, Ia, Ra, allIndividuals)
end

function activate_det(m::SIRModelDet)
    for individual in m.allIndividuals
        @process live_det(m.sim, individual, m)
    end
end

function sir_run_det(m::SIRModelDet, tf::Float64)
    ConcurrentSim.run(m.sim, tf)
end

function out_det(m::SIRModelDet)
    DataFrame(t=m.ta, S=m.Sa, I=m.Ia, R=m.Ra)
end
