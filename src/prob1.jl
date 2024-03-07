function init_prob1(data::donnees)
    model = Model(CPLEX.Optimizer)

    N = data.N 
    R = data.R
    O = data.O
    P = data.P

    @variable(model, x[1:P,1:O] >= 0, binary=true)
    @variable(model, y[1:P,1:R] >= 0, binary=true)

    #Constraint 1
    for r = 1:R
        @constraint(model, sum(y[:,r]) <= 1)
    end

    #Constraint 2
    for o in data.SO
        @constraint(model, sum(x[:,o]) <= 1)
    end

    #Constraint 3
    for o in data.FO
        @constraint(model, sum(x[:,o]) == 1)
    end

    #Constraint 4
    for p = 1:P
        @constraint(model, sum(x[p,:]) <= data.Capa[p])
    end

    #Constraint 5
    for i = 1:N
        for p = 1:P
            @constraint(model, sum(data.Q[i,:] .* x[p,:]) <= sum(data.S[i,:] .* y[p,:]))
        end
    end
    
    return model, x, y
end

include("objectives.jl")