include("src/main.jl")

# INPUT 

####################################################
P = 2
Cp = 12
F = 2 #FO length


N = 5
R = 4
O = 3
RS = 2

# begin_path = "data/instance_"
begin_path = "data/Data_test_"


time_limit = 300
####################################################

filepath = begin_path * "N$(N)_R$(R)_O$(O)_RS$(RS).txt"

println("\nRésolution PLNE classique du Problème 2 : \n")
println("Instance : ", filepath)
println()

Capa = Cp * ones(Int, P)
FO = collect(1:F)
SO = collect(F+1:O)

data = parseInstance(filepath, P, Capa, FO, SO)

S = length(data.SO) 

R_p = collect(1:data.R)
O_p = collect(1:data.O)


start_time = time()

d, f, a, b, obj, LB = prob2(data, O_p, R_p, time_limit)

end_time = time() - start_time

println("Objective value : ", obj)
println("Lower Bound : ", LB)
println("Time : ", end_time)

print("Rack order : ")
for t = 1:R
    for r = 1:R
        if b[t,r] > 1e-6
            print(r)
        end
    end
    if t < R
        print(" -> ")
    end
end