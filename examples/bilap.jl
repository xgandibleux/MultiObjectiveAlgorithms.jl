# Bi-objective linear assignment problem (model)
#
# Example 9.38 (from Ulungu and Teghem, 1994), page 255 of
# Multicriteria Optimization (2nd edt), M. Ehrgott, Springer 2005.
#
# Adapted from vOptGeneric


# ---- Packages to use
using JuMP
import GLPK
import MultiObjectiveAlgorithms as MOA


# ---- Values of the instance to solve
C1 = [  5  1  4  7 ;  # coefficients's vector of the objective 1
        6  2  2  6 ;
        2  8  4  4 ;
        3  5  7  1   ]

C2 = [  3  6  4  2 ;  # coefficients's vector of the objective 2
        1  3  8  3 ;
        5  2  2  3 ;
        4  2  3  5   ]

n  = size(C2,1)       # number of lines/columns


# ---- setting the model
model = Model()
@variable(model, x[1:n,1:n], Bin )
@expression(model, objective1, sum( C1[i,j]*x[i,j] for i=1:n,j=1:n ))
@expression(model, objective2, sum( C2[i,j]*x[i,j] for i=1:n,j=1:n ))
@objective(model, Min, [objective1, objective2])
@constraint(model , cols[i=1:n], sum(x[i,j] for j=1:n) == 1 )
@constraint(model , rows[j=1:n], sum(x[i,j] for i=1:n) == 1 )


# ---- Invoking the algorithm (Epsilon Constraint method) and the IP solver (GLPK) 
set_optimizer(model, () -> MOA.Optimizer(GLPK.Optimizer))
set_optimizer_attribute(model, MOA.Algorithm(), MOA.EpsilonConstraint())
set_optimizer_attribute(model, MOA.ObjectiveAbsoluteTolerance(1), 1) # ugly name for this attribute
optimize!(model)


# ---- Querying the results
solution_summary(model)
sizeYN = result_count(model)
for i in 1:sizeYN
    print(i,": ")
    print("z=[", convert(Int64,value(objective1; result = i))," , ", convert(Int64,value(objective2; result = i)),"] | ")
    print("x=", [convert(Int64,value(x[l,c]; result = i)) for l in 1:n, c in 1:n],"\n")
end


#=
Results:
1: z=[6 , 24] | x=[0 1 0 0; 0 0 1 0; 1 0 0 0; 0 0 0 1]
2: z=[9 , 17] | x=[0 0 1 0; 0 1 0 0; 1 0 0 0; 0 0 0 1]
3: z=[12 , 13] | x=[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]
4: z=[16 , 11] | x=[0 0 0 1; 0 1 0 0; 0 0 1 0; 1 0 0 0]
5: z=[19 , 10] | x=[0 0 1 0; 1 0 0 0; 0 0 0 1; 0 1 0 0]
6: z=[22 , 7] | x=[0 0 0 1; 1 0 0 0; 0 0 1 0; 0 1 0 0]
=#