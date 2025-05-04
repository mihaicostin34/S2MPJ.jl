module S2MPJ

# Write your package code here.
#
#

using SparseArrays

include("s2mpjlib.jl")

export PBM

include("problems/ACOPP14.jl")
include("problems/DUAL4.jl")
include("problems/VARDIM.jl")
include("problems/ROSENBR.jl")
include("problems/HS100.jl")

export ACOPP14, DUAL4, VARDIM, ROSENBR, HS100

end