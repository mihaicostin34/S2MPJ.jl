function BRATU3D(action::String,args::Union{PBM,Int,Float64,Vector{Int},Vector{Float64}}...)
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 
# 
#    Problem : BRATU3D
#    *********
# 
#    The 3D Bratu problem on the unit cube, using finite differences,
# 
#    Source: Problem 3 in
#    J.J. More',
#    "A collection of nonlinear model problems"
#    Proceedings of the AMS-SIAM Summer seminar on the Computational
#    Solution of Nonlinear Systems of Equations, Colorado, 1988.
#    Argonne National Laboratory MCS-P60-0289, 1989.
# 
#    SIF input: Ph. Toint, Dec 1989.
# 
#    classification = "C-NOR2-MN-V-V"
# 
#    P is the number of points in one side of the unit cube
#    The number of variables is equal to P**3
# 
#       Alternative values for the SIF file parameters:
# IE P                   3              $-PARAMETER  n = 27   original value
# IE P                   5              $-PARAMETER  n = 125
# IE P                   8              $-PARAMETER  n = 512
# IE P                   10             $-PARAMETER  n = 1000
# IE P                   17             $-PARAMETER  n = 4913
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#   Translated to Julia by S2MPJ version 7 X 2024
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    name = "BRATU3D"

    if action == "setup"
        pb           = PB(name)
        pbm          = PBM(name)
        nargin       = length(args)
        pbm.call     = getfield( Main, Symbol( name ) )

        #%%%%%%%%%%%%%%%%%%%  PREAMBLE %%%%%%%%%%%%%%%%%%%%
        v_  = Dict{String,Float64}();
        ix_ = Dict{String,Int}();
        ig_ = Dict{String,Int}();
        if nargin<1
            v_["P"] = Int64(3);  #  SIF file default value
        else
            v_["P"] = Int64(args[1]);
        end
        if nargin<2
            v_["LAMBDA"] = Float64(6.80812);  #  SIF file default value
        else
            v_["LAMBDA"] = Float64(args[2]);
        end
        v_["1"] = 1
        v_["2"] = 2
        v_["1.0"] = 1.0
        v_["P-1"] = -1+v_["P"]
        v_["RP-1"] = Float64(v_["P-1"])
        v_["H"] = v_["1.0"]/v_["RP-1"]
        v_["H2"] = v_["H"]*v_["H"]
        v_["C"] = v_["H2"]*v_["LAMBDA"]
        v_["-C"] = -1.0*v_["C"]
        #%%%%%%%%%%%%%%%%%%%  VARIABLES %%%%%%%%%%%%%%%%%%%%
        pb.xscale = Float64[]
        intvars = Int64[]
        binvars = Int64[]
        for J = Int64(v_["1"]):Int64(v_["P"])
            for I = Int64(v_["1"]):Int64(v_["P"])
                for K = Int64(v_["1"]):Int64(v_["P"])
                    iv,ix_,_ = s2mpj_ii("U"*string(I)*","*string(J)*","*string(K),ix_)
                    arrset(pb.xnames,iv,"U"*string(I)*","*string(J)*","*string(K))
                end
            end
        end
        #%%%%%%%%%%%%%%%%%%  DATA GROUPS %%%%%%%%%%%%%%%%%%%
        gtype    = String[]
        for I = Int64(v_["2"]):Int64(v_["P-1"])
            v_["R"] = 1+I
            v_["S"] = -1+I
            for J = Int64(v_["2"]):Int64(v_["P-1"])
                v_["V"] = 1+J
                v_["W"] = -1+J
                for K = Int64(v_["2"]):Int64(v_["P-1"])
                    v_["Y"] = 1+K
                    v_["Z"] = -1+K
                    ig,ig_,_ = s2mpj_ii("G"*string(I)*","*string(J)*","*string(K),ig_)
                    arrset(gtype,ig,"==")
                    arrset(pb.cnames,ig,"G"*string(I)*","*string(J)*","*string(K))
                    iv = ix_["U"*string(I)*","*string(J)*","*string(K)]
                    pbm.A[ig,iv] += Float64(6.0)
                    iv = ix_["U"*string(Int64(v_["R"]))*","*string(J)*","*string(K)]
                    pbm.A[ig,iv] += Float64(-1.0)
                    iv = ix_["U"*string(Int64(v_["S"]))*","*string(J)*","*string(K)]
                    pbm.A[ig,iv] += Float64(-1.0)
                    iv = ix_["U"*string(I)*","*string(Int64(v_["V"]))*","*string(K)]
                    pbm.A[ig,iv] += Float64(-1.0)
                    iv = ix_["U"*string(I)*","*string(Int64(v_["W"]))*","*string(K)]
                    pbm.A[ig,iv] += Float64(-1.0)
                    iv = ix_["U"*string(I)*","*string(J)*","*string(Int64(v_["Y"]))]
                    pbm.A[ig,iv] += Float64(-1.0)
                    iv = ix_["U"*string(I)*","*string(J)*","*string(Int64(v_["Z"]))]
                    pbm.A[ig,iv] += Float64(-1.0)
                end
            end
        end
        #%%%%%%%%%%%%%% GLOBAL DIMENSIONS %%%%%%%%%%%%%%%%%
        pb.n   = length(ix_)
        ngrp   = length(ig_)
        legrps = findall(x->x=="<=",gtype)
        eqgrps = findall(x->x=="==",gtype)
        gegrps = findall(x->x==">=",gtype)
        pb.nle = length(legrps)
        pb.neq = length(eqgrps)
        pb.nge = length(gegrps)
        pb.m   = pb.nle+pb.neq+pb.nge
        pbm.congrps = [[legrps;eqgrps];gegrps]
        pb.nob = ngrp-pb.m
        pbm.objgrps = findall(x->x=="<>",gtype)
        #%%%%%%%%%%%%%%%%%%%  BOUNDS %%%%%%%%%%%%%%%%%%%%%
        pb.xlower = -1*fill(Inf,pb.n)
        pb.xupper =    fill(Inf,pb.n)
        pb.xlower = zeros(Float64,pb.n)
        for J = Int64(v_["1"]):Int64(v_["P"])
            for K = Int64(v_["1"]):Int64(v_["P"])
                pb.xlower[ix_["U"*string(Int64(v_["1"]))*","*string(J)*","*string(K)]] = 0.0
                pb.xupper[ix_["U"*string(Int64(v_["1"]))*","*string(J)*","*string(K)]] = 0.0
                pb.xlower[ix_["U"*string(Int64(v_["P"]))*","*string(J)*","*string(K)]] = 0.0
                pb.xupper[ix_["U"*string(Int64(v_["P"]))*","*string(J)*","*string(K)]] = 0.0
            end
        end
        for I = Int64(v_["2"]):Int64(v_["P-1"])
            for K = Int64(v_["1"]):Int64(v_["P"])
                pb.xlower[ix_["U"*string(I)*","*string(Int64(v_["P"]))*","*string(K)]] = 0.0
                pb.xupper[ix_["U"*string(I)*","*string(Int64(v_["P"]))*","*string(K)]] = 0.0
                pb.xlower[ix_["U"*string(I)*","*string(Int64(v_["1"]))*","*string(K)]] = 0.0
                pb.xupper[ix_["U"*string(I)*","*string(Int64(v_["1"]))*","*string(K)]] = 0.0
            end
        end
        for I = Int64(v_["2"]):Int64(v_["P-1"])
            for J = Int64(v_["2"]):Int64(v_["P-1"])
                pb.xlower[ix_["U"*string(I)*","*string(J)*","*string(Int64(v_["1"]))]] = 0.0
                pb.xupper[ix_["U"*string(I)*","*string(J)*","*string(Int64(v_["1"]))]] = 0.0
                pb.xlower[ix_["U"*string(I)*","*string(J)*","*string(Int64(v_["P"]))]] = 0.0
                pb.xupper[ix_["U"*string(I)*","*string(J)*","*string(Int64(v_["P"]))]] = 0.0
            end
        end
        #%%%%%%%%%%%%%%%%%% START POINT %%%%%%%%%%%%%%%%%%
        pb.x0 = fill(Float64(0.0),pb.n)
        #%%%%%%%%%%%%%%%%%%%% ELFTYPE %%%%%%%%%%%%%%%%%%%%%
        iet_  = Dict{String,Int}()
        elftv = Vector{Vector{String}}()
        it,iet_,_ = s2mpj_ii( "eEXP", iet_)
        loaset(elftv,it,1,"U")
        #%%%%%%%%%%%%%%%%%% ELEMENT USES %%%%%%%%%%%%%%%%%%
        ie_      = Dict{String,Int}()
        ielftype = Vector{Int64}()
        for I = Int64(v_["2"]):Int64(v_["P-1"])
            for J = Int64(v_["2"]):Int64(v_["P-1"])
                for K = Int64(v_["2"]):Int64(v_["P-1"])
                    ename = "A"*string(I)*","*string(J)*","*string(K)
                    ie,ie_,newelt = s2mpj_ii(ename,ie_)
                    if newelt > 0
                        arrset(pbm.elftype,ie,"eEXP")
                        arrset(ielftype,ie,iet_["eEXP"])
                    end
                    vname = "U"*string(I)*","*string(J)*","*string(K)
                    iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
                    posev = findfirst(x->x=="U",elftv[ielftype[ie]])
                    loaset(pbm.elvar,ie,posev,iv)
                end
            end
        end
        #%%%%%%%%%%%%%%%%%%% GROUP USES %%%%%%%%%%%%%%%%%%%
        for ig in 1:ngrp
            arrset(pbm.grelt,ig,Int64[])
        end
        nlc = Int64[]
        for I = Int64(v_["2"]):Int64(v_["P-1"])
            for J = Int64(v_["2"]):Int64(v_["P-1"])
                for K = Int64(v_["2"]):Int64(v_["P-1"])
                    ig = ig_["G"*string(I)*","*string(J)*","*string(K)]
                    posel = length(pbm.grelt[ig])+1
                    loaset(pbm.grelt,ig,posel,ie_["A"*string(I)*","*string(J)*","*string(K)])
                    arrset(nlc,length(nlc)+1,ig)
                    loaset(pbm.grelw,ig,posel,Float64(v_["-C"]))
                end
            end
        end
        #%%%%%%%%%%%%%%%%%% OBJECT BOUNDS %%%%%%%%%%%%%%%%%
        pb.objlower = 0.0
#    Solution
        #%%%%%%%% DEFAULT FOR MISSING SECTION(S) %%%%%%%%%%
        #%%%%%%%%%%%%% FORM clower AND cupper %%%%%%%%%%%%%
        pb.clower = -1*fill(Inf,pb.m)
        pb.cupper =    fill(Inf,pb.m)
        pb.clower[pb.nle+1:pb.nle+pb.neq] = zeros(Float64,pb.neq)
        pb.cupper[pb.nle+1:pb.nle+pb.neq] = zeros(Float64,pb.neq)
        Asave = pbm.A[1:ngrp, 1:pb.n]
        pbm.A = Asave
        pbm.H = spzeros(Float64,0,0)
        #%%%%% RETURN VALUES FROM THE SETUP ACTION %%%%%%%%
        pb.lincons = findall(x-> x in setdiff( pbm.congrps,nlc),pbm.congrps)
        pb.pbclass = "C-NOR2-MN-V-V"
        pbm.objderlvl = 2
        pb.objderlvl = pbm.objderlvl;
        pbm.conderlvl = [2]
        pb.conderlvl  = pbm.conderlvl;
        return pb, pbm

# **********************
#  SET UP THE FUNCTION *
#  AND RANGE ROUTINES  *
# **********************

    #%%%%%%%%%%%%%%% NONLINEAR ELEMENTS %%%%%%%%%%%%%%%

    elseif action == "eEXP"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        EXPU = exp(EV_[1])
        f_   = EXPU
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = EXPU
            if nargout>2
                H_ = zeros(Float64,1,1)
                H_[1,1] = EXPU
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
