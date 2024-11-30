module S2MPJ

# Write your package code here.
#
#

using SparseArrays

export greet
include("functions.jl")

include("s2mpjlib.jl")

export PBM

include("problems/ACOPP14.jl")
include("problems/ACOPP30.jl")
include("problems/DUAL1.jl")
include("problems/DMN15102.jl")
include("problems/DMN15102LS.jl")
include("problems/DMN15103.jl")
include("problems/DMN15103LS.jl")
include("problems/TRO3X3.jl")
include("problems/TRO4X4.jl")
include("problems/TRO6X2.jl")

export ACOPP14, ACOPP30, DUAL1, DMN15102, DMN15102LS, DMN15103, DMN15103LS, TRO3X3, TRO4X4, TRO6X2

end
