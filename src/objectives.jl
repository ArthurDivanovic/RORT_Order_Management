function rack_number(data::donnees)
    model, x, y = init_prob1(data)

    @objective(model, Min, sum(y))
    return model
end

function command_number(data::donnees)
    model, x, y = init_prob1(data)

    @objective(model, Max, sum(x))
    return model
end

function linear_combination(data::donnees, alpha::Float64)
    model, x, y = init_prob1(data)

    @objective(model, Max, alpha * sum(y) - (1-alpha) * sum(x))
    return model
end

function lexicographic(data::donnees)
    #First optimization
    model1, x, y = init_prob1(data)

    @objective(model, Min, sum(y))

    optimize!(model1)

    feasibleSolutionFound = primal_status(model1) == MOI.FEASIBLE_POINT
    isOptimal = termination_status(model1) == MOI.OPTIMAL

    if feasibleSolutionFound && isOptimal
        S_opt = JuMP.objective_value(model1)
    end


    #Second optimization
    model2, x, y = init_prob1(data)

    #Constraint 6
    @constraint(model2, sum(y) >= S_opt)

    @objective(model, Max, sum(x))

    return model2
end

function equal_workload(data::donnees)
    model, x, y = init_prob1(data)

    P = data.P

    @variable(model, m)
    @variable(model, z[1:P])

    #Constraint 7 
    @constraint(model, m == 1/P * sum(x))

    #Constraint 8 and 9
    for p = 1:P
        @constraint(model, z[p] >= sum(x) - m)
        @constraint(model, z[p] >= m- sum(x))
    end

    @objective(model, Min, sum(z))
    
    return model
end
