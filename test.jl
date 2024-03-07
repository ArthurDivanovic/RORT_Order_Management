include("src/main.jl")

filepath = "data/Data_test_N5_R4_O3_RS2.txt"
data = parseInstance(filepath)

#Minimize rack number
model = rack_number(data)

#Maximize 
#model = 
 
optimize!(model)

# feasibleSolutionFound = primal_status(model) == MOI.FEASIBLE_POINT
# isOptimal = termination_status(model) == MOI.OPTIMAL

# if feasibleSolutionFound && isOptimal
    obj_opt = JuMP.objective_value(model)
    println("Objective value : ", obj_opt)
# end

