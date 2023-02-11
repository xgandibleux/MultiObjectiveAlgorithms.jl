# Bi-objective unidimensionnal 01 knapsack problem (biukp)
#
# Adapted from vOptGeneric


# ---- Packages to use
using JuMP
import GLPK
import MultiObjectiveAlgorithms as MOA


# ---- Values of the instance to solve
p1 = [77,94,71,63,96,82,85,75,72,91,99,63,84,87,79,94,90,60,69,62]
p2 = [65,90,90,77,95,84,70,94,66,92,74,97,60,60,65,97,93,60,69,74]
w  = [80,87,68,72,66,77,99,85,70,93,98,72,100,89,67,86,91,79,71,99]
c  = 900
n = length(p1)


# ---- setting the model
biukp = Model()
@variable(biukp, x[1:n], Bin)
@expression(biukp, objective1, sum( p1[j]*x[j] for j=1:n ))
@expression(biukp, objective2, sum( p2[j]*x[j] for j=1:n ))
@objective(biukp, Max, [objective1, objective2])
@constraint(biukp, sum( w[j]*x[j] for j=1:n ) <= c )


# ---- Invoking the algorithm (Epsilon Constraint method) and the IP solver (GLPK) 
set_optimizer(biukp, () -> MOA.Optimizer(GLPK.Optimizer))
set_optimizer_attribute(biukp, MOA.Algorithm(), MOA.EpsilonConstraint())
set_optimizer_attribute(biukp, MOA.ObjectiveAbsoluteTolerance(1), 1) # ugly name for this attribute
optimize!(biukp)


# ---- Querying the results
solution_summary(biukp)
sizeYN = result_count(biukp)
for i in 1:sizeYN
    print(i,": ")
    print("z=[", convert(Int64,value(objective1; result = i))," , ", convert(Int64,value(objective2; result = i)),"] | ")
    print("x=", [convert(Int64,value(x[j]; result = i)) for j in 1:n],"\n")
end


#=
Results:
1: z=[918 , 984] | x=[0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0]
2: z=[924 , 975] | x=[0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0]
3: z=[927 , 972] | x=[0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0]
4: z=[934 , 971] | x=[0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0]
5: z=[935 , 947] | x=[0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0]
6: z=[940 , 943] | x=[0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0]
7: z=[943 , 940] | x=[0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0]
8: z=[948 , 939] | x=[1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0]
9: z=[949 , 915] | x=[1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0]
10: z=[952 , 909] | x=[0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0]
11: z=[955 , 906] | x=[0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0]
=#