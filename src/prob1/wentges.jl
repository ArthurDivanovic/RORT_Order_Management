function simple_decomposition_wentges(data::donnees, wentges_coeff::Float64, time_limit=nothing)
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

    LBs = Float64[]
    UBs = Float64[]

    tetha = nothing
    alpha_hat = nothing

    while (delta1 < -1e-6 || delta2 < -1e-6) && (isnothing(time_limit) || time_limit > resolution_time)

        start_time = time()

        lambda1, lambda2, eta, alpha, UB = master_problem(data, X, Y)

        #First iteration
        if isnothing(tetha)
            alpha_sep = alpha
            eta_sep = eta

        #Other iterations
        else
            alpha_sep = (1-wentges_coeff) * alpha .+ wentges_coeff * alpha_hat
            eta_sep = (1-wentges_coeff) * eta .+ wentges_coeff * [tetha, tetha]
        end

        x, y, delta1, delta2 = subproblems(data, eta_sep, alpha_sep)

        if delta1 < -1e-6 
            push!(X, x)
        else
            x, delta1 = subproblem1(data, eta, alpha)
            if delta1 < -1e-6 
                push!(X, x)
            end
        end

        if delta2 < -1e-6
            push!(Y, y)
        else
            y, delta2 = subproblem2(data, eta, alpha)
            if delta2 < -1e-6 
                push!(Y, y)
            end
        end

        LB = delta1 + delta2 + sum(eta)

        if isnothing(tetha)
            tetha = LB
            alpha_hat = alpha_sep
        end
        
        if delta1 >= -1e-6 && delta2 >= -1e-6
            tetha = LB
            alpha_hat = alpha_sep
        end

        
        resolution_time += time() - start_time

        push!(LBs, LB)
        push!(UBs, UB)
    end

    if resolution_time > time_limit
        X = X[1:length(lambda1)]
        Y = Y[1:length(lambda2)]
    end
    
    nb_col = length(X) + length(Y)

    S = length(data.SO)

    x_opt = sum(value.(lambda1) .* X, dims=1)[1]
    y_opt = sum(value.(lambda2) .* Y, dims=1)[1]

    obj = (S+1) * sum(y_opt) - sum(sum(x_opt[p,o] for p = 1:P) for o in SO)
    return LB, obj, nb_col, X, Y, LBs, UBs
end

