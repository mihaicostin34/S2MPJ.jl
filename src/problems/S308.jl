function S308(action::String,args::Union{PBM,Int,Float64,Vector{Int},Vector{Float64}}...)
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 
# 
#    Problem : S308
#    *********
# 
#    Source: problem 308 in
#    K. Schittkowski,
#    " More Test Problems for Nonlinear Programming Codes",
#    Springer Verlag, Berlin, 1987.
# 
#    SIF input: Ph. Toint, April 1991.
# 
#    classification = "C-SUR2-AN-2-0"
# 
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#   Translated to Julia by S2MPJ version 7 X 2024
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    name = "S308"

    if action == "setup"
        pb           = PB(name)
        pbm          = PBM(name)
        nargin       = length(args)
        pbm.call     = getfield( Main, Symbol( name ) )

        #%%%%%%%%%%%%%%%%%%%  PREAMBLE %%%%%%%%%%%%%%%%%%%%
        v_  = Dict{String,Float64}();
        ix_ = Dict{String,Int}();
        ig_ = Dict{String,Int}();
        #%%%%%%%%%%%%%%%%%%%  VARIABLES %%%%%%%%%%%%%%%%%%%%
        pb.xscale = Float64[]
        intvars = Int64[]
        binvars = Int64[]
        iv,ix_,_ = s2mpj_ii("X1",ix_)
        arrset(pb.xnames,iv,"X1")
        iv,ix_,_ = s2mpj_ii("X2",ix_)
        arrset(pb.xnames,iv,"X2")
        #%%%%%%%%%%%%%%%%%%  DATA GROUPS %%%%%%%%%%%%%%%%%%%
        gtype    = String[]
        ig,ig_,_ = s2mpj_ii("O1",ig_)
        arrset(gtype,ig,"<>")
        ig,ig_,_ = s2mpj_ii("O2",ig_)
        arrset(gtype,ig,"<>")
        ig,ig_,_ = s2mpj_ii("O3",ig_)
        arrset(gtype,ig,"<>")
        #%%%%%%%%%%%%%% GLOBAL DIMENSIONS %%%%%%%%%%%%%%%%%
        pb.n   = length(ix_)
        ngrp   = length(ig_)
        pbm.objgrps = collect(1:ngrp)
        pb.m        = 0
        #%%%%%%%%%%%%%%%%%%%  BOUNDS %%%%%%%%%%%%%%%%%%%%%
        pb.xlower = -1*fill(Inf,pb.n)
        pb.xupper =    fill(Inf,pb.n)
        pb.xlower = zeros(Float64,pb.n)
        #%%%%%%%%%%%%%%%%%%% START POINT %%%%%%%%%%%%%%%%%%
        pb.x0 = zeros(Float64,pb.n)
        pb.x0[ix_["X1"]] = Float64(3.0)
        pb.x0[ix_["X2"]] = Float64(0.1)
        #%%%%%%%%%%%%%%%%%%%% ELFTYPE %%%%%%%%%%%%%%%%%%%%%
        iet_  = Dict{String,Int}()
        elftv = Vector{Vector{String}}()
        it,iet_,_ = s2mpj_ii( "eQUAD", iet_)
        loaset(elftv,it,1,"X")
        loaset(elftv,it,2,"Y")
        it,iet_,_ = s2mpj_ii( "eSINE", iet_)
        loaset(elftv,it,1,"X")
        it,iet_,_ = s2mpj_ii( "eCOSN", iet_)
        loaset(elftv,it,1,"X")
        #%%%%%%%%%%%%%%%%%% ELEMENT USES %%%%%%%%%%%%%%%%%%
        ie_      = Dict{String,Int}()
        ielftype = Vector{Int64}()
        ename = "EQ"
        ie,ie_,_  = s2mpj_ii(ename,ie_)
        arrset(pbm.elftype,ie,"eQUAD")
        arrset(ielftype,ie,iet_["eQUAD"])
        vname = "X1"
        iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,nothing)
        posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        loaset(pbm.elvar,ie,posev,iv)
        vname = "X2"
        iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,nothing)
        posev = findfirst(x->x=="Y",elftv[ielftype[ie]])
        loaset(pbm.elvar,ie,posev,iv)
        ename = "ES"
        ie,ie_,_  = s2mpj_ii(ename,ie_)
        arrset(pbm.elftype,ie,"eSINE")
        arrset(ielftype,ie,iet_["eSINE"])
        vname = "X1"
        iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,nothing)
        posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        loaset(pbm.elvar,ie,posev,iv)
        ename = "EC"
        ie,ie_,_  = s2mpj_ii(ename,ie_)
        arrset(pbm.elftype,ie,"eCOSN")
        arrset(ielftype,ie,iet_["eCOSN"])
        vname = "X2"
        iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,nothing)
        posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        loaset(pbm.elvar,ie,posev,iv)
        #%%%%%%%%%%%%%%%%%%%%% GRFTYPE %%%%%%%%%%%%%%%%%%%%
        igt_ = Dict{String,Int}()
        it,igt_,_ = s2mpj_ii("gL2",igt_)
        #%%%%%%%%%%%%%%%%%%% GROUP USES %%%%%%%%%%%%%%%%%%%
        for ig in 1:ngrp
            arrset(pbm.grelt,ig,Int64[])
        end
        nlc = Int64[]
        for ig in 1:ngrp
            arrset(pbm.grftype,ig,"gL2")
        end
        ig = ig_["O1"]
        posel = length(pbm.grelt[ig])+1
        loaset(pbm.grelt,ig,posel,ie_["EQ"])
        loaset(pbm.grelw,ig,posel,1.)
        ig = ig_["O2"]
        posel = length(pbm.grelt[ig])+1
        loaset(pbm.grelt,ig,posel,ie_["ES"])
        loaset(pbm.grelw,ig,posel,1.)
        ig = ig_["O3"]
        posel = length(pbm.grelt[ig])+1
        loaset(pbm.grelt,ig,posel,ie_["EC"])
        loaset(pbm.grelw,ig,posel,1.)
        #%%%%%%%%%%%%%%%%%% OBJECT BOUNDS %%%%%%%%%%%%%%%%%
        pb.objlower = 0.0
#    Solution
# LO SOLTN               0.773199
        #%%%%%%%% DEFAULT FOR MISSING SECTION(S) %%%%%%%%%%
        pbm.A = spzeros(Float64,0,0)
        pbm.H = spzeros(Float64,0,0)
        #%%%%% RETURN VALUES FROM THE SETUP ACTION %%%%%%%%
        pb.pbclass = "C-SUR2-AN-2-0"
        pbm.objderlvl = 2
        pb.objderlvl = pbm.objderlvl;
        return pb, pbm

# **********************
#  SET UP THE FUNCTION *
#  AND RANGE ROUTINES  *
# **********************

    #%%%%%%%%%%%%%%% NONLINEAR ELEMENTS %%%%%%%%%%%%%%%

    elseif action == "eQUAD"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        f_   = EV_[1]*EV_[1]+EV_[1]*EV_[2]+EV_[2]*EV_[2]
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 2.0*EV_[1]+EV_[2]
            g_[2] = 2.0*EV_[2]+EV_[1]
            if nargout>2
                H_ = zeros(Float64,2,2)
                H_[1,1] = 2.0
                H_[1,2] = 1.0
                H_[2,1] = H_[1,2]
                H_[2,2] = 2.0
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eSINE"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        SINX = sin(EV_[1])
        f_   = SINX
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = cos(EV_[1])
            if nargout>2
                H_ = zeros(Float64,1,1)
                H_[1,1] = -SINX
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eCOSN"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        COSX = cos(EV_[1])
        f_   = COSX
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = -sin(EV_[1])
            if nargout>2
                H_ = zeros(Float64,1,1)
                H_[1,1] = -COSX
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    #%%%%%%%%%%%%%%%%% NONLINEAR GROUPS  %%%%%%%%%%%%%%%

    elseif action == "gL2"

        GVAR_   = args[1]
        igr_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        f_= GVAR_*GVAR_
        if nargout>1
            g_ = GVAR_+GVAR_
            if nargout>2
                H_ = zeros(Float64,1,1)
                H_ = 2.0
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
