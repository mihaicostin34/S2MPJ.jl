# include("../s2mpjlib.jl")
function DUAL4(action::String,args::Union{PBM,Int,Float64,Vector{Int},Vector{Float64}}...)
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 
# 
#    Problem : DUAL4
#    *********
# 
#    A dual quadratic program from Antonio Frangioni (frangio@DI.UniPi.IT)
# 
#    This is the dual of PRIMAL4.SIF
# 
#    SIF input: Irv Lustig and Nick Gould, June 1996.
# 
#    classification = "C-QLR2-MN-75-1"
# 
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#   Translated to Julia by S2MPJ version 7 X 2024
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    name = "DUAL4"

    if action == "setup"
        pb = PB(name)
        pbm = PBM(name)
        pbm.call = getfield(Main, Symbol(name))

        v_ = Dict("1" => 1.0, "N" => 75.0)
        ix_, ig_ = Dict{String, Int}(), Dict{String, Int}()

        # Define constraints
        gtype = String[]
        for cname in ["obj", "c1"]
            ig, ig_, _ = s2mpj_ii(cname, ig_)
            arrset(gtype, ig, cname == "obj" ? "<>" : "==")
            if cname == "c1"
                arrset(pb.cnames, ig, cname)
            end
        end

        # Define 75 variables and their coefficients in A matrix
        coeffs = [
            0.8319712885, 0.7821556737, 0.908518889, 0.6793105389, 0.9658310595,
            0.7599026152, 0.8289833552, 0.8071922589, 0.9124971902, 0.7156897824,
            0.5496187235, 0.4416244614, 0.625595376, 0.6522613484, 0.6601885356,
            0.6003936017, 0.5492949347, 0.6169163494, 0.5737799455, 0.6291793074,
            0.5772455997, 0.5197049398, 0.3952746984, 0.3978900962, 0.2972799584,
            0.2430443545, 0.0, 0.741134637, 0.741134637, 0.741134637, 0.741134637,
            0.741134637, 0.741134637, 0.741134637, 0.741134637, 0.741134637, 0.741134637,
            0.741134637, 0.741134637, 0.741134637, 0.741134637, 0.741134637, 0.741134637,
            0.741134637, 0.741134637, 0.741134637, 0.741134637, 0.741134637, 0.741134637,
            0.741134637, 0.741134637, 0.741134637, 0.741134637, 0.741134637, 0.8156168486,
            0.9105826764, 0.9580740343, 0.8382776584, 1.0064412818, 0.9145463921,
            0.8907644242, 0.935632465, 1.0469476122, 0.9938330321, 1.0440301864,
            0.7781038922, 0.9503832429, 0.9333077316, 0.967093053, 1.0500250368,
            0.8160575462, 1.0364734174, 1.0782957195, 0.8724013895, 0.0
        ]

        for i in 1:75
            varname = "x$i"
            iv, ix_, _ = s2mpj_ii(varname, ix_)
            arrset(pb.xnames, iv, varname)
            pbm.A[ig_["c1"], iv] += 1.0
            if coeffs[i] != 0.0
                pbm.A[ig_["obj"], iv] += coeffs[i]
            end
        end

        # Problem dimensions and classification
        pb.n = length(ix_)
        ngrp = length(ig_)
        legrps = findall(x -> x == "<=", gtype)
        eqgrps = findall(x -> x == "==", gtype)
        gegrps = findall(x -> x == ">=", gtype)
        pb.nle, pb.neq, pb.nge = length(legrps), length(eqgrps), length(gegrps)
        pb.m = pb.nle + pb.neq + pb.nge
        pbm.congrps = [[legrps; eqgrps]; gegrps]
        pb.nob = ngrp - pb.m
        pbm.objgrps = findall(x -> x == "<>", gtype)

        # Constants and bounds
        pbm.gconst = zeros(Float64, ngrp)
        pbm.gconst[ig_["c1"]] = 1.0
        pb.xlower = zeros(Float64, pb.n)
        pb.xupper = fill(1.0, pb.n)

        return pb, pbm

# **********************
#  SET UP THE FUNCTION *
#  AND RANGE ROUTINES  *
# **********************

    #%%%%%%%%%%%%%%% NONLINEAR ELEMENTS %%%%%%%%%%%%%%%

    elseif action == "eDIAG"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        f_   = 0.5*EV_[1]*EV_[1]
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = EV_[1]
            if nargout>2
                H_ = zeros(Float64,1,1)
                H_[1,1] = 1.0
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eOFFDIAG"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        f_   = EV_[1]*EV_[2]
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = EV_[2]
            g_[2] = EV_[1]
            if nargout>2
                H_ = zeros(Float64,2,2)
                H_[1,2] = 1.0
                H_[2,1] = H_[1,2]
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    #%%%%%%%%%%%%%%% THE MAIN ACTIONS %%%%%%%%%%%%%%%

    elseif action in  ["fx","fgx","fgHx","cx","cJx","cJHx","cIx","cIJx","cIJHx","cIJxv","fHxv",
                       "cJxv","cJtxv","cIJtxv","Lxy","Lgxy","LgHxy","LIxy","LIgxy","LIgHxy",
                       "LHxyv","LIHxyv"]

        pbm = args[1]
        if pbm.name == name
            pbm.has_globs = [0,0]
            return s2mpj_eval(action,args...)
        else
            println("ERROR: please run "*name*" with action = setup")
            return ntuple(i->undef,args[end])
        end

    else
        println("ERROR: action "*action*" unavailable for problem "*name*".jl")
        return ntuple(i->undef,args[end])
    end

end

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

