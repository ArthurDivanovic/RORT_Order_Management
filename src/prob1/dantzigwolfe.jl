function simple_decomposition(data::donnees, time_limit=nothing)
    X = Matrix{Int}[]
    Y = Matrix{Int}[]

    delta1 = -1
    delta2 = -1

    x, y = first_solution(data)
    push!(X, x)
    push!(Y, y)

    lambda1 = 1
    lambda2 = 1

    resolution_time = 0.0
    LB = nothing
    UB = nothing

    while (delta1 < -1e-6 || delta2 < -1e-6) && (isnothing(time_limit) || time_limit > resolution_time)

        start_time = time()

        lambda1, lambda2, eta, alpha, UB = master_problem(data, X, Y)

        x, y, delta1, delta2 = subproblems(data, eta, alpha)

        LB = delta1 + delta2 + sum(eta)

        if delta1 < -1e-6
            push!(X, x)
        end

        if delta2 < -1e-6
            push!(Y, y)
        end
        
        resolution_time += time() - start_time
    end
    
    nb_col = length(X) + length(Y)

    S = length(data.SO)

    x_opt = sum(value.(lambda1) .* X, dims=1)[1]
    y_opt = sum(value.(lambda2) .* Y, dims=1)[1]

    obj = (S+1) * sum(y_opt) - sum(sum(x_opt[p,o] for p = 1:P) for o in SO)
    return x_opt, y_opt, obj, nb_col, LB
end


function first_solution(data::donnees)

    model, x, y = init_prob1(data)
    set_silent(model)

    @objective(model, Min, 0)

    optimize!(model)

    return value.(x), value.(y)
end 


function master_problem(data::donnees, X::Vector{Matrix{Int}}, Y::Vector{Matrix{Int}})

    N = data.N 
    R = data.R
    O = data.O
    P = data.P

    K = length(X)
    L = length(Y)

    model = Model(CPLEX.Optimizer)
    set_silent(model)

    @variable(model, lambda1[1:K] >= 0)
    @variable(model, lambda2[1:L] >= 0)

    #Constraint 5
    @constraint(model, a[p=1:P,i=1:N], sum(lambda2[l] * sum(data.S[i][r] * Y[l][p,r] for r = 1:R) for l = 1:L) - sum(lambda1[k] * sum(data.Q[i][o] * X[k][p,o] for o = 1:O) for k = 1:K) >= 0)
    

    #Convexity constraints
    @constraint(model, e1, sum(lambda1[k] for k = 1:K) == 1)
    @constraint(model, e2, sum(lambda2[l] for l = 1:L) == 1)


    S = length(data.SO) 
    # @objective(model, Min, (S+1) * sum(lambda2[l] * sum(Y[l]) for l = 1:L) - sum(lambda1[k] * sum(X[k]) for k = 1:K))
    @objective(model, Min, (S+1) * sum(lambda2[l] * sum(Y[l]) for l = 1:L) - sum(lambda1[k] * sum(sum(X[k][p,o] for p = 1:P) for o in data.SO) for k = 1:K))
    
    optimize!(model)
    UB = JuMP.objective_value(model)
    
    alpha = dual.(a)
    eta = dual.([e1,e2])
          
    return lambda1, lambda2, eta, alpha, UB

end

function subproblems(data::donnees, eta::Vector{Float64}, alpha::Matrix{Float64})

    N = data.N 
    R = data.R
    O = data.O
    P = data.P

    ### First SubProblem
    model1 = Model(CPLEX.Optimizer)
    set_silent(model1)

    @variable(model1, x[1:P,1:O] >= 0, binary=true)

    #Constraint 2
    for o in data.SO
        @constraint(model1, sum(x[:,o]) <= 1)
    end

    #Constraint 3
    for o in data.FO
        @constraint(model1, sum(x[:,o]) == 1)
    end

    #Constraint 4
    for p = 1:P
        @constraint(model1, sum(x[p,:]) <= data.Capa[p])
    end

    # @objective(model1, Min, -sum(x) - eta[1] + sum(sum(x[p,o] * sum(alpha[p,i] * data.Q[i][o] for i = 1:N) for p = 1:P) for o = 1:O))
    @objective(model1, Min, -sum(sum(x[p,o] for p = 1:P) for o in data.SO) - eta[1] + sum(sum(x[p,o] * sum(alpha[p,i] * data.Q[i][o] for i = 1:N) for p = 1:P) for o = 1:O))

    optimize!(model1)
    delta1 = JuMP.objective_value(model1)

    ### Second SubProblem
    model2 = Model(CPLEX.Optimizer)
    set_silent(model2)

    @variable(model2, y[1:P,1:R] >= 0, binary=true)
    
    #Constraint 1
    for r = 1:R
        @constraint(model2, sum(y[:,r]) <= 1)
    end

    S = length(data.SO)
    @objective(model2, Min, (S+1) * sum(y) - eta[2] - sum(sum(y[p,r] * sum(alpha[p,i] * data.S[i][r] for i = 1:N) for p = 1:P) for r = 1:R))
    
    optimize!(model2)
    delta2 = JuMP.objective_value(model2)

    # println("LB  : ", delta1 + sum(eta) + delta2)

    x = value.(x)
    y = value.(y)

    return  x, y, delta1, delta2
end