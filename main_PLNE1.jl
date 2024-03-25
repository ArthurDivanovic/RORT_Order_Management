include("src/main.jl")

# INPUT 

####################################################
P = 2
Cp = 12
F = 3 #FO length


N = 7
R = 5
O = 5
RS = 7

# begin_path = "data/instance_"
begin_path = "data/Data_test_"


time_limit = 180
####################################################


filepath = begin_path * "N$(N)_R$(R)_O$(O)_RS$(RS).txt"

println("\nRésolution PLNE classique du Problème 1 (objectif lexicographique) : \n")
println("Instance : ", filepath)
println()

Capa = Cp * ones(Int, P)
FO = collect(1:F)
SO = collect(F+1:O)

data = parseInstance(filepath, P, Capa, FO, SO)

S = length(data.SO) 

model, x, y = lexicographic(data)

if !isnothing(time_limit)
    set_time_limit_sec(model, time_limit)
end

start_time = time()

optimize!(model)

end_time = time() - start_time

feasibleSolutionFound = primal_status(model) == MOI.FEASIBLE_POINT
isOptimal = termination_status(model) == MOI.OPTIMAL

obj_opt = nothing
if feasibleSolutionFound && isOptimal
    obj_opt = JuMP.objective_value(model)
end

x = value.(x)
y = value.(y)

println("Objective value : ", obj_opt)
println("Lower Bound : ", JuMP.objective_bound(model))
println("Time : ", end_time)

println("Nb command FO : ", F)
println("Nb command SO : ", sum(x) - F)

println("Nb racks : ", sum(y))

