function prob2(data::donnees, O_p::Vector{Int}, R_p::Vector{Int})
    N = data.N 
    R = length(R_p)
    O = length(O_p)
    T = R

    Q = Vector{Int}[]
    for i = 1:N
        q = Int[]
        for o in O_p
            push!(q, data.Q[i][o])
        end
        push!(Q, q)
    end

    S = Vector{Int}[]
    for i = 1:N
        s = Int[]
        for r in R_p
            push!(s, data.S[i][r])
        end
        push!(S, s)
    end

    model = Model(CPLEX.Optimizer)
    set_silent(model)

    @variable(model, a[1:O,1:T,1:N] >= 0)
    @variable(model, b[1:T, 1:R] >= 0, binary=true)
    @variable(model, z[1:O,1:T] >= 0, binary=true)
    @variable(model, u >= 0)

    #Constraint 16
    for t = 1:T
        @constraint(model, c16, u >= sum(z[:,t]))
    end

    #Constraint 17
    for o = 1:O
        for i = 1:N
            @constraint(model, sum(a[o,:,i]) == Q[i][o])
        end
    end

    #Constraint 18
    for t = 1:T
        for i = 1:N
            @constraint(model, sum(a[:,t,i]) <= sum(b[t,:] .* S[i]))
        end
    end

    #Constraint 19 et 20
    for o = 1:O
        M = sum(Q[i][o] for i = 1:N)
        for t = 1:T
            @constraint(model, z[o,t] <= sum(a[o,t:end,:]))
            @constraint(model, M * z[o,t] >= sum(a[o,1:t,:]))
        end
    end

    #Constraint 21
    for r = 1:R 
        @constraint(model, sum(b[:,r]) == 1)
    end

    #Constraint 22
    for t = 1:T 
        @constraint(model, sum(b[t,:]) == 1)
    end

    @objective(model, Min, u)

    optimize!(model)
    obj = value(u)

    
    return value.(z), value.(a), value.(b), obj
end