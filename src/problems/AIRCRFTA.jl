function AIRCRFTA(action::String,args::Union{PBM,Int,Float64,Vector{Int},Vector{Float64}}...)
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 
# 
#    Problem : AIRCRFTA
#    *********
# 
#    The aircraft stability problem by Rheinboldt, as a function
#    of the elevator, aileron and rudder deflection controls.
# 
#    Source: Problem 9 in
#    J.J. More',"A collection of nonlinear model problems"
#    Proceedings of the AMS-SIAM Summer Seminar on the Computational
#    Solution of Nonlinear Systems of Equations, Colorado, 1988.
#    Argonne National Laboratory MCS-P60-0289, 1989.
# 
#    SIF input: Ph. Toint, Dec 1989.
# 
#    classification = "C-NOR2-RN-8-5"
# 
#    Values for the controls
#    1) Elevator
# 
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#   Translated to Julia by S2MPJ version 6 X 2024
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    name = "AIRCRFTA"

    if action == "setup"
        pb           = PB(name)
        pbm          = PBM(name)
        nargin       = length(args)
        pbm.call     = getfield( Main, Symbol( name ) )

        #%%%%%%%%%%%%%%%%%%%  PREAMBLE %%%%%%%%%%%%%%%%%%%%
        #  0.002 s
        v_  = Dict{String,Float64}();
        ix_ = Dict{String,Int}();
        ig_ = Dict{String,Int}();
        v_["ELVVAL"] = 0.1
        v_["AILVAL"] = 0.0
        v_["RUDVAL"] = 0.0
        G1 = ["ROLLRATE", "PITCHRAT", "YAWRATE", "SSLIPANG", "AILERON", "RUDDERDF"]
        # eq = [1, "G2", "G3", "G4", "G5"]
        eq = []
        leq = []
        geq = []
        noneq = []
        #%%%%%%%%%%%%%%%%%%%  VARIABLES %%%%%%%%%%%%%%%%%%%%
        # 0.07 s
        pb.xscale = Float64[]
        intvars = Int64[]
        binvars = Int64[]
        iv,ix_,_ = s2mpj_ii("ROLLRATE",ix_)
        arrset(pb.xnames,iv,"ROLLRATE")
        iv,ix_,_ = s2mpj_ii("PITCHRAT",ix_)
        arrset(pb.xnames,iv,"PITCHRAT")
        iv,ix_,_ = s2mpj_ii("YAWRATE",ix_)
        arrset(pb.xnames,iv,"YAWRATE")
        iv,ix_,_ = s2mpj_ii("ATTCKANG",ix_)
        arrset(pb.xnames,iv,"ATTCKANG")
        iv,ix_,_ = s2mpj_ii("SSLIPANG",ix_)
        arrset(pb.xnames,iv,"SSLIPANG")
        iv,ix_,_ = s2mpj_ii("ELEVATOR",ix_)
        arrset(pb.xnames,iv,"ELEVATOR")
        iv,ix_,_ = s2mpj_ii("AILERON",ix_)
        arrset(pb.xnames,iv,"AILERON")
        iv,ix_,_ = s2mpj_ii("RUDDERDF",ix_)
        arrset(pb.xnames,iv,"RUDDERDF")
        #%%%%%%%%%%%%%%%%%%  DATA GROUPS %%%%%%%%%%%%%%%%%%%
        # 0.35 s
        gtype    = String[]
        ig,ig_,_ = s2mpj_ii("G1",ig_)
        push!(eq, 1)
        # arrset(gtype,ig,"==")
        # arrset(pb.cnames,ig,"G1")

        I_m = [1, 1, 1, 1, 1, 1, 
              2, 2, 2, 
              3, 3, 3, 3, 3, 
              4, 4, 4, 
              5, 5, 5
              ]
        J = [1, 2, 3, 5, 7, 8, 
            2, 4, 6, 
            1, 3, 5, 7, 8, 
            2, 4, 6, 
            3, 5, 7
            ]
        V = [Float64(-3.933), Float64(0.107), Float64(0.126), Float64(-9.99), Float64(-45.83), Float64(-7.64), 
              Float64(-0.987), Float64(-22.95), Float64(-28.37),
              Float64(0.002), Float64(-0.235), Float64(5.67), Float64(-0.921), Float64(-6.51), 
              Float64(1.0), Float64(-1.0), Float64(-1.168),
              Float64(-1.0), Float64(-0.196), Float64(-0.0071)
            ]

        pbm.A = sparse(I_m, J, V)
        # iv = ix_["ROLLRATE"]
        # pbm.A[ig,iv] += Float64(-3.933) #asta rupe 
        # iv = ix_["PITCHRAT"]
        # pbm.A[ig,iv] += Float64(0.107)
        # iv = ix_["YAWRATE"]
        # pbm.A[ig,iv] += Float64(0.126)
        # iv = ix_["SSLIPANG"]
        # pbm.A[ig,iv] += Float64(-9.99)
        # iv = ix_["AILERON"]
        # pbm.A[ig,iv] += Float64(-45.83)
        # iv = ix_["RUDDERDF"]
        # pbm.A[ig,iv] += Float64(-7.64)

        ig,ig_,_ = s2mpj_ii("G2",ig_)
        push!(eq, 2)
        # arrset(gtype,ig,"==")
        # arrset(pb.cnames,ig,"G2")
        # iv = ix_["PITCHRAT"]
        # pbm.A[ig,iv] += Float64(-0.987)
        # iv = ix_["ATTCKANG"]
        # pbm.A[ig,iv] += Float64(-22.95)
        # iv = ix_["ELEVATOR"]
        # pbm.A[ig,iv] += Float64(-28.37)

        ig,ig_,_ = s2mpj_ii("G3",ig_)
        push!(eq, 3)
        # arrset(gtype,ig,"==")
        # arrset(pb.cnames,ig,"G3")
        # iv = ix_["ROLLRATE"]
        # pbm.A[ig,iv] += Float64(0.002)
        # iv = ix_["YAWRATE"]
        # pbm.A[ig,iv] += Float64(-0.235)
        # iv = ix_["SSLIPANG"]
        # pbm.A[ig,iv] += Float64(5.67)
        # iv = ix_["AILERON"]
        # pbm.A[ig,iv] += Float64(-0.921)
        # iv = ix_["RUDDERDF"]
        # pbm.A[ig,iv] += Float64(-6.51)

        ig,ig_,_ = s2mpj_ii("G4",ig_)
        push!(eq, 4)
        # arrset(gtype,ig,"==")
        # arrset(pb.cnames,ig,"G4")
        # iv = ix_["PITCHRAT"]
        # pbm.A[ig,iv] += Float64(1.0)
        # iv = ix_["ATTCKANG"]
        # pbm.A[ig,iv] += Float64(-1.0)
        # iv = ix_["ELEVATOR"]
        # pbm.A[ig,iv] += Float64(-1.168)

        ig,ig_,_ = s2mpj_ii("G5",ig_)
        push!(eq, 5)
        # arrset(gtype,ig,"==")
        # arrset(pb.cnames,ig,"G5")
        # iv = ix_["YAWRATE"]
        # pbm.A[ig,iv] += Float64(-1.0)
        # iv = ix_["SSLIPANG"]
        # pbm.A[ig,iv] += Float64(-0.196)
        # iv = ix_["AILERON"]
        # pbm.A[ig,iv] += Float64(-0.0071)

        #%%%%%%%%%%%%%% GLOBAL DIMENSIONS %%%%%%%%%%%%%%%%%
        # 0.15
        pb.n   = length(ix_)
        ngrp   = length(ig_)
        pb.nle = length(leq)
        pb.neq = length(eq)
        pb.nge = length(geq)
        pb.m   = pb.nle+pb.neq+pb.nge
        pbm.congrps = [[leq;eq];geq]
        pb.nob = ngrp-pb.m
        pbm.objgrps = noneq
        #%%%%%%%%%%%%%%%%%%%  BOUNDS %%%%%%%%%%%%%%%%%%%%%
        # 0.06
        # pb.xlower = -1*fill(Inf,pb.n)
        pb.xupper =    fill(Inf,pb.n)
        pb.xlower = zeros(Float64,pb.n)
        pb.xlower[ix_["ELEVATOR"]] = v_["ELVVAL"]
        pb.xupper[ix_["ELEVATOR"]] = v_["ELVVAL"]
        pb.xlower[ix_["AILERON"]] = v_["AILVAL"]
        pb.xupper[ix_["AILERON"]] = v_["AILVAL"]
        pb.xlower[ix_["RUDDERDF"]] = v_["RUDVAL"]
        pb.xupper[ix_["RUDDERDF"]] = v_["RUDVAL"]
        #%%%%%%%%%%%%%%%%%% START POINT %%%%%%%%%%%%%%%%%%
        # 0.07
        pb.x0 = fill(Float64(0.0),pb.n)
        if haskey(ix_,"ELEVATOR")
            pb.x0[ix_["ELEVATOR"]] = Float64(v_["ELVVAL"])
        else
            pb.y0[findfirst(x->x==ig_["ELEVATOR"],pbm.congrps)] = Float64(v_["ELVVAL"])
        end
        if haskey(ix_,"AILERON")
            pb.x0[ix_["AILERON"]] = Float64(v_["AILVAL"])
        else
            pb.y0[findfirst(x->x==ig_["AILERON"],pbm.congrps)] = Float64(v_["AILVAL"])
        end
        if haskey(ix_,"RUDDERDF")
            pb.x0[ix_["RUDDERDF"]] = Float64(v_["RUDVAL"])
        else
            pb.y0[findfirst(x->x==ig_["RUDDERDF"],pbm.congrps)] = Float64(v_["RUDVAL"])
        end
        #%%%%%%%%%%%%%%%%%%%% ELFTYPE %%%%%%%%%%%%%%%%%%%%%
        # 0.04
        iet_  = Dict{String,Int}()
        elftv = Vector{Vector{String}}()
        it,iet_,_ = s2mpj_ii( "en2PR", iet_)
        loaset(elftv,it,1,"X")
        loaset(elftv,it,2,"Y")
        #%%%%%%%%%%%%%%%%%% ELEMENT USES %%%%%%%%%%%%%%%%%%
        # 0.3
        ie_      = Dict{String,Int}()
        ielftype = Vector{Int64}()
        ename = "E1A"
        ie,ie_,newelt = s2mpj_ii(ename,ie_)
        arrset(pbm.elftype,ie,"en2PR")
        arrset(ielftype,ie,iet_["en2PR"])
        vname = "PITCHRAT"
        iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # vname = "YAWRATE"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="Y",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # ename = "E1B"
        # ie,ie_,newelt = s2mpj_ii(ename,ie_)
        # if newelt > 0
        #     arrset(pbm.elftype,ie,"en2PR")
        #     arrset(ielftype,ie,iet_["en2PR"])
        # end
        # vname = "YAWRATE"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # vname = "ATTCKANG"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="Y",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # ename = "E1C"
        # ie,ie_,newelt = s2mpj_ii(ename,ie_)
        # if newelt > 0
        #     arrset(pbm.elftype,ie,"en2PR")
        #     arrset(ielftype,ie,iet_["en2PR"])
        # end
        # vname = "ATTCKANG"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # vname = "SSLIPANG"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="Y",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # ename = "E1D"
        # ie,ie_,newelt = s2mpj_ii(ename,ie_)
        # if newelt > 0
        #     arrset(pbm.elftype,ie,"en2PR")
        #     arrset(ielftype,ie,iet_["en2PR"])
        # end
        # vname = "PITCHRAT"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # vname = "ATTCKANG"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="Y",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # ename = "E2A"
        # ie,ie_,newelt = s2mpj_ii(ename,ie_)
        # if newelt > 0
        #     arrset(pbm.elftype,ie,"en2PR")
        #     arrset(ielftype,ie,iet_["en2PR"])
        # end
        # vname = "ROLLRATE"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # vname = "YAWRATE"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="Y",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # ename = "E2B"
        # ie,ie_,newelt = s2mpj_ii(ename,ie_)
        # if newelt > 0
        #     arrset(pbm.elftype,ie,"en2PR")
        #     arrset(ielftype,ie,iet_["en2PR"])
        # end
        # vname = "ROLLRATE"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # vname = "SSLIPANG"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="Y",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # ename = "E3A"
        # ie,ie_,newelt = s2mpj_ii(ename,ie_)
        # if newelt > 0
        #     arrset(pbm.elftype,ie,"en2PR")
        #     arrset(ielftype,ie,iet_["en2PR"])
        # end
        # vname = "ROLLRATE"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # vname = "PITCHRAT"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="Y",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # ename = "E3B"
        # ie,ie_,newelt = s2mpj_ii(ename,ie_)
        # if newelt > 0
        #     arrset(pbm.elftype,ie,"en2PR")
        #     arrset(ielftype,ie,iet_["en2PR"])
        # end
        # vname = "ROLLRATE"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="X",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        # vname = "ATTCKANG"
        # iv,ix_,pb = s2mpj_nlx(vname,ix_,pb,1,nothing,nothing,Float64(0.0))
        # posev = findfirst(x->x=="Y",elftv[ielftype[ie]])
        # loaset(pbm.elvar,ie,posev,iv)
        #%%%%%%%%%%%%%%%%%%% GROUP USES %%%%%%%%%%%%%%%%%%%
        # 0.12
        # for ig in 1:ngrp
        #     arrset(pbm.grelt,ig,Int64[])
        # end
        # nlc = Int64[]
        # ig = ig_["G1"]
        # posel = length(pbm.grelt[ig])+1
        # loaset(pbm.grelt,ig,posel,ie_["E1A"])
        # arrset(nlc,length(nlc)+1,ig)
        # loaset(pbm.grelw,ig,posel,Float64(-0.727))
        # posel = posel+1
        # loaset(pbm.grelt,ig,posel,ie_["E1B"])
        # loaset(pbm.grelw,ig,posel,Float64(8.39))
        # posel = length(pbm.grelt[ig])+1
        # loaset(pbm.grelt,ig,posel,ie_["E1C"])
        # arrset(nlc,length(nlc)+1,ig)
        # loaset(pbm.grelw,ig,posel,Float64(-684.4))
        # posel = posel+1
        # loaset(pbm.grelt,ig,posel,ie_["E1D"])
        # loaset(pbm.grelw,ig,posel,Float64(63.5))
        # ig = ig_["G2"]
        # posel = length(pbm.grelt[ig])+1
        # loaset(pbm.grelt,ig,posel,ie_["E2A"])
        # arrset(nlc,length(nlc)+1,ig)
        # loaset(pbm.grelw,ig,posel,Float64(0.949))
        # posel = posel+1
        # loaset(pbm.grelt,ig,posel,ie_["E2B"])
        # loaset(pbm.grelw,ig,posel,Float64(0.173))
        # ig = ig_["G3"]
        # posel = length(pbm.grelt[ig])+1
        # loaset(pbm.grelt,ig,posel,ie_["E3A"])
        # arrset(nlc,length(nlc)+1,ig)
        # loaset(pbm.grelw,ig,posel,Float64(-0.716))
        # posel = posel+1
        # loaset(pbm.grelt,ig,posel,ie_["E3B"])
        # loaset(pbm.grelw,ig,posel,Float64(-1.578))
        # posel = length(pbm.grelt[ig])+1
        # loaset(pbm.grelt,ig,posel,ie_["E1D"])
        # arrset(nlc,length(nlc)+1,ig)
        # loaset(pbm.grelw,ig,posel,Float64(1.132))
        # ig = ig_["G4"]
        # posel = length(pbm.grelt[ig])+1
        # loaset(pbm.grelt,ig,posel,ie_["E2B"])
        # arrset(nlc,length(nlc)+1,ig)
        # loaset(pbm.grelw,ig,posel,Float64(-1.0))
        # ig = ig_["G5"]
        # posel = length(pbm.grelt[ig])+1
        # loaset(pbm.grelt,ig,posel,ie_["E3B"])
        # arrset(nlc,length(nlc)+1,ig)
        # loaset(pbm.grelw,ig,posel,1.)
        #%%%%%%%% DEFAULT FOR MISSING SECTION(S) %%%%%%%%%%
        #%%%%%%%%%%%%% FORM clower AND cupper %%%%%%%%%%%%%
        # 0.17
        # pb.clower = -1*fill(Inf,pb.m)
        # pb.cupper =    fill(Inf,pb.m)
        # pb.clower[pb.nle+1:pb.nle+pb.neq] = zeros(Float64,pb.neq)
        # pb.cupper[pb.nle+1:pb.nle+pb.neq] = zeros(Float64,pb.neq)
        # Asave = pbm.A[1:ngrp, 1:pb.n]
        # pbm.A = Asave
        # pbm.H = spzeros(Float64,0,0)
        #%%%%% RETURN VALUES FROM THE SETUP ACTION %%%%%%%%
        # 0.08
        # pb.lincons = findall(x-> x in setdiff( pbm.congrps,nlc),pbm.congrps)
        # pb.pbclass = "C-NOR2-RN-8-5"
        # pbm.objderlvl = 2
        # pb.objderlvl = pbm.objderlvl;
        # pbm.conderlvl = [2]
        # pb.conderlvl  = pbm.conderlvl;
        # return pb, pbm


    #%%%%%%%%%%%%%%% NONLINEAR ELEMENTS %%%%%%%%%%%%%%%

    elseif action == "en2PR"

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
            # before = time()
            res = s2mpj_eval(action,args...)
            # after = time()
            # println(after - before)
            return res
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

