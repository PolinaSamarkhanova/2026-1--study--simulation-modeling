```@meta
EditURL = "daisyworld_lit.jl"
```

# Модель Daisyworld

## Описание

Модель демонстрирует гипотезу Геи - способность биоты регулировать
температуру планеты через изменение альбедо поверхности.
Черные маргаритки поглощают больше тепла, белые - отражают.

## Импорт необходимых пакетов

````@example daisyworld_lit
using Agents
using DataFrames
using Plots
using CairoMakie
using StatsBase
using Random
````

## Подключение файла с моделью

Файл `src/daisyworld.jl` содержит определение агентов и функций модели.

````@example daisyworld_lit
include("../src/daisyworld.jl")
````

## Создание модели

Создаем модель с параметрами по умолчанию:
- сетка 30×30
- 20% белых и 20% черных маргариток
- максимальный возраст 25 шагов

````@example daisyworld_lit
model = daisyworld()
````

## Функция цвета маргаритки

Определяем функцию, которая возвращает цвет агента в зависимости от вида.

````@example daisyworld_lit
daisycolor(a::Daisy) = a.breed
````

## Параметры визуализации

Настраиваем внешний вид графика:
- цвет агента зависит от вида
- размер маркеров 20 пикселей
- форма маркера - звезда
- тепловая карта показывает температуру
- диапазон температур от -20 до 60 градусов

````@example daisyworld_lit
plotkwargs = (
    agent_color = daisycolor,
    agent_size = 20,
    agent_marker = '★',
    heatarray = :temperature,
    heatkwargs = (colorrange = (-20, 60),),
)
````

## Визуализация начального состояния

Создаем график для шага 0 (начальное состояние модели).

````@example daisyworld_lit
println("Шаг 0...")
plt1, _ = abmplot(model; plotkwargs...)
save("plots/step0.png", plt1)
println("Сохранено: plots/step0.png")
````

## Визуализация после 5 шагов

Запускаем модель на 5 шагов и сохраняем график.

````@example daisyworld_lit
println("Шаг 5...")
step!(model, 5)
plt2, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
save("plots/step5.png", plt2)
println("Сохранено: plots/step5.png")
````

## Визуализация после 45 шагов

Запускаем модель еще на 40 шагов (всего 45) и сохраняем график.

````@example daisyworld_lit
println("Шаг 45...")
step!(model, 40)
plt3, _ = abmplot(model; heatarray = model.temperature, plotkwargs...)
save("plots/step45.png", plt3)
println("Сохранено: plots/step45.png")
````

## Завершение

Графики сохранены в папку `plots/`.

````@example daisyworld_lit
println("Готово! Графики сохранены в папку plots/")
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

