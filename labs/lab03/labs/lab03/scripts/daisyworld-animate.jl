using Agents
using DataFrames
using Plots
using CairoMakie
using StatsBase
using Random

include("../src/daisyworld.jl")

model = daisyworld()

daisycolor(a::Daisy) = a.breed

plotkwargs = (
    agent_color = daisycolor,
    agent_size = 20,
    agent_marker = '♠',
    heatarray = :temperature,
    heatkwargs = (colorrange = (-20, 60),),
)

# Создаем папку для видео
mkpath("videos")

println("Создание анимации...")
println("Будет создано 60 кадров")

# Создаем анимацию
abmvideo(
    "videos/simulation.mp4",
    model;
    title = "Daisy World",
    frames = 60,
    plotkwargs...,
)

println("Анимация сохранена: videos/simulation.mp4")
