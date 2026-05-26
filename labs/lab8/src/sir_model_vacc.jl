# src/sir_model_vacc.jl

include(joinpath(@__DIR__, "sir_model.jl"))

function vaccinate!(m::SIRModel, fraction::Float64, current_time::Float64)
    susceptible_ids = [i for (i, p) in enumerate(m.allIndividuals) if p.status == :S]
    n_vacc = Int(round(fraction * length(susceptible_ids)))
    if n_vacc == 0
        return
    end
    # вакцинируем первых n_vacc (для простоты, без перемешивания)
    to_vacc = susceptible_ids[1:min(n_vacc, length(susceptible_ids))]
    for idx in to_vacc
        m.allIndividuals[idx].status = :R
    end
    # обновляем статистику
    push!(m.ta, current_time)
    push!(m.Sa, count(p.status == :S for p in m.allIndividuals))
    push!(m.Ia, count(p.status == :I for p in m.allIndividuals))
    push!(m.Ra, count(p.status == :R for p in m.allIndividuals))
end

@resumable function schedule_vaccination(env, m, time::Float64, fraction::Float64)
    @yield timeout(env, time)
    vaccinate!(m, fraction, ConcurrentSim.now(env))
    println("Вакцинация проведена в момент $(ConcurrentSim.now(env))")
end
