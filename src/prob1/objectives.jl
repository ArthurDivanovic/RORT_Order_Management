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
    model, x, y = init_prob1(data)

    S = length(data.SO)

    @objective(model, Min, (S+1) * sum(y) - sum(x))
    return model
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
