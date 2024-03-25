include("src/main.jl")

# INPUT 

####################################################
P = 2
Cp = 12
F = 6 #FO length


N = 10
R = 10
O = 10
RS = 7

# begin_path = "data/instance_"
begin_path = "data/Data_test_"


time_limit = 180
####################################################


filepath = begin_path * "N$(N)_R$(R)_O$(O)_RS$(RS).txt"

println("\nDécomposition de Dantzig-Wolfe simple du Problème 1 : \n")
println("Instance : ",filepath)
println()

Capa = Cp * ones(Int, P)
FO = collect(1:F)
SO = collect(F+1:O)
S = length(data.SO) 

data = parseInstance(filepath, P, Capa, FO, SO)

start_time = time()

LB, obj, nb_col, X, Y, LBs, UBs = simple_decomposition(data, time_limit)

end_time = time() - start_time


println("Lower Bound : ", LB)
println("Objective Master Problem: ", obj)
println("Time : ", end_time)
println("Column number : ", nb_col)

# println()
# println("UBs = $UBs")
# println("LBs = $LBs")
# println("filename = \"$(split(filepath, "/")[2])\"")

lambda1, lambda2, eta, alpha, UB, v = master_problem(data, X, Y, true)
x = sum(value.(lambda1) .* X, dims=1)[1]
y = sum(value.(lambda2) .* Y, dims=1)[1]


obj01 = (S+1) * sum(y) - sum(sum(x[p,o] for p = 1:data.P) for o in data.SO)


println("\n\nConstruction d'une solution faisable : \n")
println("Objective O-1 : ", obj01)
println("Nb command FO : ", F)
println("Nb command SO : ", sum(x) - F)
println("Viols : ", v)
println("Nb racks : ", sum(y))

