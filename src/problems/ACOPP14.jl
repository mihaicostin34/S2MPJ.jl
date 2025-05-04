# include("../s2mpjlib.jl")

function ACOPP14(action::String,args::Union{PBM,Int,Float64,Vector{Int},Vector{Float64}}...)
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 
# 
#    Problem : ACOPP14
#    *********
# 
#    An AC Optimal Power Flow (OPF) problem for the IEEE 14 Bus
#    Power Systems Test Case from the archive:
#      http://www.ee.washington.edu/research/pstca/
# 
#    Polar formulation due to 
#     Anya Castillo, Johns Hopkins University, anya.castillo@jhu.edu
# 
#    variables: 
#      A - voltage amplitude
#      M (= |V|) - voltage modulus
#      P - real power component
#      Q - imaginary (reactive) power component
# 
#    constants  
#      PD, QD - constant loads (= withdrawl of power from the network)
#      Pmin, Pmax - real power limits
#      Qmin, Qmax - imaginary realtive) power limits
#      Mmin, Mmax - voltage modulus limits
#      Amin, Amax - voltage phase aplitude limits
#      Smax - thermal limits
# 
#    objective function:
#    ------------------
#      sum_{i in nodes} f_i(P_i) = a_i P_i^2 + b_i P_i
# 
#    real power flow constraints:
#    ---------------------------
#      R_i * ( G * R - B * I ) + I_i * ( G * I + B * R ) 
#        - P_i + PD_i = 0 for all nodes i
#      M_i * sum_{j in nodes} M_j * ( G_ij cos A_ij  + B_ij sin A_ij ) 
#        - P_i + PD_i = 0 for all nodes i
#      where A_ij = A_i - A_j
# 
#    reactive power flow constraints:
#    -------------------------------
#      I_i * ( G * R - B * I ) - R_i * ( G * I + B * R ) 
#        - Q_i + QD_i = 0 for all nodes i
#      M_i * sum_{j in nodes} M_j * ( G_ij sin A_ij  - B_ij cos A_ij ) 
#        - Q_i + QD_i = 0 for all nodes i
# 
#    line thermal limit constraints:
#    ------------------------------
#      f_i(A,M) <= Smax_i and  t_i(A,M) <= Smax_i for all lines i
# 
#      here if we write v = M * ( cos A + i sin A ) = v^R + i V^I,
#        f_i = ( v_j(i) . ( Yf * v )_i ) * conj( v_j(i) . ( Yf * v )_i )
#        t_i = ( v_j(i) . ( Yt * v )_i ) * conj( v_j(i) . ( Yt * v )_i )
#      where the nodes j(i) and 
#        Yf = Yf^R + i Yf^I and Yt = Yt^R + i Yt^I are given
#      This leads to
#         f_i = ( R_j . Yf^R R - R_j . Yf^I I + I_j . Yf^R I + I_j . Yf^I R )^2 +
#               ( I_j . Yf^R R - I_j . Yf^I I - R_j . Yf^R I - R_j . Yf^I R )^2
#       and
#         t_i = ( R_j . Yt^R R - R_j . Yt^I I + I_j . Yt^R I + I_j . Yt^I R )^2 +
#               ( I_j . Yt^R R - I_j . Yt^I I - R_j . Yt^R I - R_j . Yt^I R )^2
# 
#      if Yt^R R = sum_k Yt_k^R R_k (etc), we have
# 
#         f_i = ( sum_k [ R_j . Yf^R_k R_k - R_j . Yf^I_k I_k + 
#                         I_j . Yf^R_k I_k + I_j . Yf^I_k R_k ] )^2 +
#               ( sum_k [ I_j . Yf^R_k R_k - I_j . Yf^I_k I_k - 
#                         R_j . Yf^R_k I_k - R_j . Yf^I_k R_k ] )^2
#             =  sum_k [          ( Yf^R_k^2 + Yf^I_k^2 ) R_j^2 R_k^2
#                               + ( Yf^R_k^2 + Yf^I_k^2 ) I_j^2 I_k^2
#                               + ( Yf^R_k^2 + Yf^I_k^2 ) R_j^2 I_k^2
#                               + ( Yf^R_k^2 + Yf^I_k^2 ) I_j^2 R_k^2 ] +
#               sum_k sum_l>k [   2 ( Yf^R_k Yf^R_l + Yf^I_k Yf^I_l ) 
#                                     R_j^2 R_k R_l 
#                               + 2 ( Yf^R_k Yf^R_l + Yf^I_k Yf^I_l ) 
#                                     R_j^2 I_k I_l 
#                               + 2 ( Yf^R_k Yf^R_l + Yf^I_k Yf^I_l ) 
#                                     I_j^2 R_k R_l 
#                               + 2 ( Yf^R_k Yf^R_l + Yf^I_k Yf^I_l ) 
#                                     I_j^2 I_k I_l 
#                               + 2 ( Yf^R_k Yf^I_l - Yf^I_k Yf^R_l )
#                                     R_j^2 I_k R_l 
#                               - 2 ( Yf^R_k Yf^I_l - Yf^I_k Yf^R_l )
#                                     R_j^2 R_k I_l 
#                               + 2 ( Yf^R_k Yf^I_l - Yf^I_k Yf^R_l )
#                                     I_j^2 I_k R_l 
#                               - 2 ( Yf^R_k Yf^I_l - Yf^I_k Yf^R_l )
#                                     I_j^2 R_k I_l                   ]
#             = sum_k                ( Yf^R_k^2 + Yf^I_k^2 ) M_j^2 M_k^2 +
#               sum_k sum_l>k [    2 ( Yf^R_k Yf^R_l + Yf^I_k Yf^I_l ) 
#                                     M_j^2 M_k M_l cos ( A_k - A_l )
#                               +  2 ( Yf^R_k Yf^I_l - Yf^I_k Yf^R_l ) 
#                                     M_j^2 M_k M_l sin ( A_k - A_l ) ]
# 
#      and similarly for t_i
# 
#  [ ** NOT USED **
#    maximum phase-amplitude difference constraints:
#      Amin_ij <= A_i - A_j <= Amax_ij  for all interconnets i and j ] 
# 
#    node voltage modulus limits:
#    ----------------------------
#      Mmin_i <= M_i <= Mmax_i  for all nodes i
# 
#    generator real power limits:
#    ---------------------------
#      Pmin_i <= P_i <= Pmax_i  for all nodes i
# 
#    generator reactive power limits:
#    -------------------------------
#      Qmin_i <= Q_i <= Qmax_i  for all nodes i
# 
#    SIF input: Nick Gould, August 2011
# 
#    classification = "C-QOR2-AY-38-68"
# 
#    number of nodes
# 
# 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#   Translated to Julia by S2MPJ version 6 X 2024
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    name = "ACOPP14"

    if action == "setup"
        pb = PB(name)
        pbm = PBM(name)
        pbm.call = getfield(Main, Symbol(name))

        v_ = Dict("NODES" => 14, "LIMITS" => 5, "LINES" => 20, "1" => 1.0)
        ix_, ig_ = Dict{String,Int}(), Dict{String,Int}()

        # Define variables A and M for each node
        for i in 1:v_["NODES"]
            for prefix in ["A", "M"]
                varname = prefix * string(i)
                iv, ix_, _ = s2mpj_ii(varname, ix_)
                arrset(pb.xnames, iv, varname)
            end
        end

        # Define variables P and Q for each generator
        for i in 1:v_["LIMITS"]
            for prefix in ["P", "Q"]
                varname = prefix * string(i)
                iv, ix_, _ = s2mpj_ii(varname, ix_)
                arrset(pb.xnames, iv, varname)
            end
        end

        # Objective group
        gtype = String[]
        ig, ig_, _ = s2mpj_ii("OBJ", ig_)
        arrset(gtype, ig, "<>")
        for (k, coeff) in Dict("P1"=>2000.0, "P2"=>2000.0, "P3"=>4000.0, "P4"=>4000.0, "P5"=>4000.0)
            pbm.A[ig, ix_[k]] += coeff
        end

        # Real and imaginary power flow constraints for each node
        for i in 1:v_["NODES"]
            for prefix in ["RP", "IP"]
                cname = prefix * string(i)
                ig, ig_, _ = s2mpj_ii(cname, ig_)
                arrset(gtype, ig, "==")
                arrset(pb.cnames, ig, cname)
            end
        end

        # Specific RP/IP constraints for each generator node
        for (i, pidx) in enumerate(["P1", "P2", "P3", "P4", "P5"])
            ig, ig_, _ = s2mpj_ii("RP" * string(i * 2 - 1), ig_)
            arrset(gtype, ig, "==")
            arrset(pb.cnames, ig, "RP" * string(i * 2 - 1))
            pbm.A[ig, ix_[pidx]] += -1.0

            ig, ig_, _ = s2mpj_ii("IP" * string(i * 2 - 1), ig_)
            arrset(gtype, ig, "==")
            arrset(pb.cnames, ig, "IP" * string(i * 2 - 1))
            pbm.A[ig, ix_["Q$i"]] += -1.0
        end

        # Flow constraints
        for prefix in ["FN", "TN"]
            for i in 1:v_["LINES"]
                cname = prefix * string(i)
                ig, ig_, _ = s2mpj_ii(cname, ig_)
                arrset(gtype, ig, "<=")
                arrset(pb.cnames, ig, cname)
            end
        end

        # Global constraint classification
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

        # Constants for power flow constraints and limits
        pbm.gconst = zeros(Float64, ngrp)
        for (k, v) in Dict(
            "RP2"=>-0.217, "RP3"=>-0.942, "RP4"=>-0.478, "RP5"=>-0.076, "RP6"=>-0.112,
            "RP9"=>-0.295, "RP10"=>-0.09, "RP11"=>-0.035, "RP12"=>-0.061,
            "RP13"=>-0.135, "RP14"=>-0.149,
            "IP2"=>-0.127, "IP3"=>-0.19, "IP4"=>0.039, "IP5"=>-0.016, "IP6"=>-0.075,
            "IP9"=>-0.166, "IP10"=>-0.058, "IP11"=>-0.018, "IP12"=>-0.016,
            "IP13"=>-0.058, "IP14"=>-0.05
        ) pbm.gconst[ig_[k]] = v end

        for prefix in ["FN", "TN"], i in 1:v_["LINES"]
            pbm.gconst[ig_["$prefix$i"]] = 9801.0
        end

        # Variable bounds
        pb.xlower = fill(-1e30, pb.n)
        pb.xupper = fill(1e30, pb.n)
        for i in 1:v_["NODES"]
            pb.xlower[ix_["M$i"]] = 0.94
            pb.xupper[ix_["M$i"]] = 1.06
        end
        bounds_dict = Dict(
            "P1"=>(0.0,3.324), "P2"=>(0.0,1.4), "P3"=>(0.0,1.0), "P4"=>(0.0,1.0), "P5"=>(0.0,1.0),
            "Q1"=>(0.0,0.1), "Q2"=>(-0.4,0.5), "Q3"=>(0.0,0.4), "Q4"=>(-0.06,0.24), "Q5"=>(-0.06,0.24)
        )
        for (k, (lo, hi)) in bounds_dict
            pb.xlower[ix_[k]] = lo
            pb.xupper[ix_[k]] = hi
        end

        # Initial guess
        pb.x0 = fill(0.0, pb.n)
        start_vals = Dict(
            "M1"=>1.06, "M2"=>1.045, "M3"=>1.01, "M4"=>1.019, "M5"=>1.02,
            "M6"=>1.07, "M7"=>1.062, "M8"=>1.09, "M9"=>1.056, "M10"=>1.051,
            "M11"=>1.057, "M12"=>1.055, "M13"=>1.05, "M14"=>1.036,
            "A2"=>-0.0869, "A3"=>-0.222, "A4"=>-0.1803, "A5"=>-0.1532,
            "A6"=>-0.2482, "A7"=>-0.2334, "A8"=>-0.2332, "A9"=>-0.2608,
            "A10"=>-0.2635, "A11"=>-0.2581, "A12"=>-0.263, "A13"=>-0.2646, "A14"=>-0.28,
            "P1"=>2.324, "P2"=>0.4, "Q1"=>-0.169, "Q2"=>0.424,
            "Q3"=>0.234, "Q4"=>0.122, "Q5"=>0.174
        )
        for (k, v) in start_vals
            pb.x0[ix_[k]] = v
        end

        # Quadratic terms in objective
        for (k, hval) in Dict("P1"=>860.586, "P2"=>5000.0, "P3"=>200.0, "P4"=>200.0, "P5"=>200.0)
            ix = ix_[k]; pbm.H[ix, ix] += hval
        end

        return pb, pbm


    #%%%%%%%%%%%%%%% NONLINEAR ELEMENTS %%%%%%%%%%%%%%%

    elseif action == "eP2"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        f_   = EV_[1]^2
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 2.0e+0*EV_[1]
            if nargout>2
                H_ = zeros(Float64,1,1)
                H_[1,1] = 2.0e+0
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eP4"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        f_   = EV_[1]^4
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 4.0e+0*EV_[1]^3
            if nargout>2
                H_ = zeros(Float64,1,1)
                H_[1,1] = 12.0e+0*EV_[1]^2
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eP11"

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
                H_[1,2] = 1.0e+0
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

    elseif action == "eP31"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        f_   = EV_[2]*(EV_[1]^3)
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 3.0e+0*EV_[2]*EV_[1]^2
            g_[2] = EV_[1]^3
            if nargout>2
                H_ = zeros(Float64,2,2)
                H_[1,1] = 6.0e+0*EV_[2]*EV_[1]
                H_[1,2] = 3.0e+0*EV_[1]^2
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

    elseif action == "eP22"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        f_   = (EV_[1]*EV_[2])^2
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 2.0e+0*EV_[1]*EV_[2]^2
            g_[2] = 2.0e+0*EV_[2]*EV_[1]^2
            if nargout>2
                H_ = zeros(Float64,2,2)
                H_[1,1] = 2.0e+0*EV_[2]^2
                H_[1,2] = 4.0e+0*EV_[1]*EV_[2]
                H_[2,1] = H_[1,2]
                H_[2,2] = 2.0e+0*EV_[1]^2
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eP211"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        f_   = (EV_[3]*EV_[2])*(EV_[1]^2)
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 2.0e+0*EV_[3]*EV_[2]*EV_[1]
            g_[2] = EV_[3]*EV_[1]^2
            g_[3] = EV_[2]*EV_[1]^2
            if nargout>2
                H_ = zeros(Float64,3,3)
                H_[1,1] = 2.0e+0*EV_[3]*EV_[2]
                H_[1,2] = 2.0e+0*EV_[3]*EV_[1]
                H_[2,1] = H_[1,2]
                H_[1,3] = 2.0e+0*EV_[2]*EV_[1]
                H_[3,1] = H_[1,3]
                H_[2,3] = EV_[1]^2
                H_[3,2] = H_[2,3]
                H_[3,3] = 0.0e+0
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eSIN11"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        U_ = zeros(Float64,3,4)
        IV_ =  zeros(Float64,3)
        U_[1,1] = U_[1,1]+1
        U_[2,2] = U_[2,2]+1
        U_[3,3] = U_[3,3]+1
        U_[3,4] = U_[3,4]-1
        IV_[1] = dot(U_[1,:],EV_)
        IV_[2] = dot(U_[2,:],EV_)
        IV_[3] = dot(U_[3,:],EV_)
        SINA = sin(IV_[3])
        COSA = cos(IV_[3])
        f_   = SINA*IV_[1]*IV_[2]
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = SINA*IV_[2]
            g_[2] = SINA*IV_[1]
            g_[3] = COSA*IV_[1]*IV_[2]
            g_ =  U_'*g_
            if nargout>2
                H_ = zeros(Float64,3,3)
                H_[1,2] = SINA
                H_[2,1] = H_[1,2]
                H_[3,1] = COSA*IV_[2]
                H_[1,3] = H_[3,1]
                H_[3,2] = COSA*IV_[1]
                H_[2,3] = H_[3,2]
                H_[3,3] = -SINA*IV_[1]*IV_[2]
                H_ = U_'*H_*U_
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eCOS11"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        U_ = zeros(Float64,3,4)
        IV_ =  zeros(Float64,3)
        U_[1,1] = U_[1,1]+1
        U_[2,2] = U_[2,2]+1
        U_[3,3] = U_[3,3]+1
        U_[3,4] = U_[3,4]-1
        IV_[1] = dot(U_[1,:],EV_)
        IV_[2] = dot(U_[2,:],EV_)
        IV_[3] = dot(U_[3,:],EV_)
        SINA = sin(IV_[3])
        COSA = cos(IV_[3])
        f_   = COSA*IV_[1]*IV_[2]
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = COSA*IV_[2]
            g_[2] = COSA*IV_[1]
            g_[3] = -SINA*IV_[1]*IV_[2]
            g_ =  U_'*g_
            if nargout>2
                H_ = zeros(Float64,3,3)
                H_[1,2] = COSA
                H_[2,1] = H_[1,2]
                H_[3,1] = -SINA*IV_[2]
                H_[1,3] = H_[3,1]
                H_[3,2] = -SINA*IV_[1]
                H_[2,3] = H_[3,2]
                H_[3,3] = -COSA*IV_[1]*IV_[2]
                H_ = U_'*H_*U_
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eSIN211"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        U_ = zeros(Float64,4,5)
        IV_ =  zeros(Float64,4)
        U_[1,1] = U_[1,1]+1
        U_[2,2] = U_[2,2]+1
        U_[3,3] = U_[3,3]+1
        U_[4,4] = U_[4,4]+1
        U_[4,5] = U_[4,5]-1
        IV_[1] = dot(U_[1,:],EV_)
        IV_[2] = dot(U_[2,:],EV_)
        IV_[3] = dot(U_[3,:],EV_)
        IV_[4] = dot(U_[4,:],EV_)
        SINA = sin(IV_[4])
        COSA = cos(IV_[4])
        f_   = (SINA*IV_[3]*IV_[2])*(IV_[1]^2)
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 2.0e+0*SINA*IV_[3]*IV_[2]*IV_[1]
            g_[2] = SINA*IV_[3]*IV_[1]^2
            g_[3] = SINA*IV_[2]*IV_[1]^2
            g_[4] = (COSA*IV_[3]*IV_[2])*(IV_[1]^2)
            g_ =  U_'*g_
            if nargout>2
                H_ = zeros(Float64,4,4)
                H_[1,1] = 2.0e+0*SINA*IV_[3]*IV_[2]
                H_[1,2] = 2.0e+0*SINA*IV_[3]*IV_[1]
                H_[2,1] = H_[1,2]
                H_[1,3] = 2.0e+0*SINA*IV_[2]*IV_[1]
                H_[3,1] = H_[1,3]
                H_[2,3] = SINA*IV_[1]^2
                H_[3,2] = H_[2,3]
                H_[3,3] = 0.0e+0
                H_[4,1] = 2.0e+0*COSA*IV_[3]*IV_[2]*IV_[1]
                H_[1,4] = H_[4,1]
                H_[4,2] = (COSA*IV_[3])*(IV_[1]^2)
                H_[2,4] = H_[4,2]
                H_[4,3] = (COSA*IV_[2])*(IV_[1]^2)
                H_[3,4] = H_[4,3]
                H_[4,4] = (-SINA*IV_[3]*IV_[2])*(IV_[1]^2)
                H_ = U_'*H_*U_
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eCOS211"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        U_ = zeros(Float64,4,5)
        IV_ =  zeros(Float64,4)
        U_[1,1] = U_[1,1]+1
        U_[2,2] = U_[2,2]+1
        U_[3,3] = U_[3,3]+1
        U_[4,4] = U_[4,4]+1
        U_[4,5] = U_[4,5]-1
        IV_[1] = dot(U_[1,:],EV_)
        IV_[2] = dot(U_[2,:],EV_)
        IV_[3] = dot(U_[3,:],EV_)
        IV_[4] = dot(U_[4,:],EV_)
        SINA = sin(IV_[4])
        COSA = cos(IV_[4])
        f_   = (COSA*IV_[3]*IV_[2])*(IV_[1]^2)
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 2.0e+0*COSA*IV_[3]*IV_[2]*IV_[1]
            g_[2] = COSA*IV_[3]*IV_[1]^2
            g_[3] = COSA*IV_[2]*IV_[1]^2
            g_[4] = (-SINA*IV_[3]*IV_[2])*(IV_[1]^2)
            g_ =  U_'*g_
            if nargout>2
                H_ = zeros(Float64,4,4)
                H_[1,1] = 2.0e+0*COSA*IV_[3]*IV_[2]
                H_[1,2] = 2.0e+0*COSA*IV_[3]*IV_[1]
                H_[2,1] = H_[1,2]
                H_[1,3] = 2.0e+0*COSA*IV_[2]*IV_[1]
                H_[3,1] = H_[1,3]
                H_[2,3] = COSA*IV_[1]^2
                H_[3,2] = H_[2,3]
                H_[3,3] = 0.0e+0
                H_[4,1] = -2.0e+0*SINA*IV_[3]*IV_[2]*IV_[1]
                H_[1,4] = H_[4,1]
                H_[4,2] = (-SINA*IV_[3])*(IV_[1]^2)
                H_[2,4] = H_[4,2]
                H_[4,3] = (-SINA*IV_[2])*(IV_[1]^2)
                H_[3,4] = H_[4,3]
                H_[4,4] = (-COSA*IV_[3]*IV_[2])*(IV_[1]^2)
                H_ = U_'*H_*U_
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eSIN31"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        U_ = zeros(Float64,3,4)
        IV_ =  zeros(Float64,3)
        U_[1,1] = U_[1,1]+1
        U_[2,2] = U_[2,2]+1
        U_[3,3] = U_[3,3]+1
        U_[3,4] = U_[3,4]-1
        IV_[1] = dot(U_[1,:],EV_)
        IV_[2] = dot(U_[2,:],EV_)
        IV_[3] = dot(U_[3,:],EV_)
        SINA = sin(IV_[3])
        COSA = cos(IV_[3])
        f_   = SINA*IV_[2]*(IV_[1]^3)
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 3.0e+0*SINA*IV_[2]*IV_[1]^2
            g_[2] = SINA*IV_[1]^3
            g_[3] = COSA*IV_[2]*(IV_[1]^3)
            g_ =  U_'*g_
            if nargout>2
                H_ = zeros(Float64,3,3)
                H_[1,1] = 6.0e+0*SINA*IV_[2]*IV_[1]
                H_[1,2] = 3.0e+0*SINA*IV_[1]^2
                H_[2,1] = H_[1,2]
                H_[3,1] = 3.0e+0*COSA*IV_[2]*(IV_[1]^2)
                H_[1,3] = H_[3,1]
                H_[3,2] = COSA*(IV_[1]^3)
                H_[2,3] = H_[3,2]
                H_[3,3] = -SINA*IV_[2]*(IV_[1]^3)
                H_ = U_'*H_*U_
            end
        end
        if nargout == 1
            return f_
        elseif nargout == 2
            return f_,g_
        elseif nargout == 3
            return f_,g_,H_
        end

    elseif action == "eCOS31"

        EV_     = args[1]
        iel_    = args[2]
        nargout = args[3]
        pbm     = args[4]
        U_ = zeros(Float64,3,4)
        IV_ =  zeros(Float64,3)
        U_[1,1] = U_[1,1]+1
        U_[2,2] = U_[2,2]+1
        U_[3,3] = U_[3,3]+1
        U_[3,4] = U_[3,4]-1
        IV_[1] = dot(U_[1,:],EV_)
        IV_[2] = dot(U_[2,:],EV_)
        IV_[3] = dot(U_[3,:],EV_)
        SINA = sin(IV_[3])
        COSA = cos(IV_[3])
        f_   = COSA*IV_[2]*(IV_[1]^3)
        if nargout>1
            dim = try length(IV_) catch; length(EV_) end
            g_  = zeros(Float64,dim)
            g_[1] = 3.0e+0*COSA*IV_[2]*IV_[1]^2
            g_[2] = COSA*IV_[1]^3
            g_[3] = -SINA*IV_[2]*(IV_[1]^3)
            g_ =  U_'*g_
            if nargout>2
                H_ = zeros(Float64,3,3)
                H_[1,1] = 6.0e+0*COSA*IV_[2]*IV_[1]
                H_[1,2] = 3.0e+0*COSA*IV_[1]^2
                H_[2,1] = H_[1,2]
                H_[3,1] = -3.0e+0*SINA*IV_[2]*(IV_[1]^2)
                H_[1,3] = H_[3,1]
                H_[3,2] = -SINA*(IV_[1]^3)
                H_[2,3] = H_[3,2]
                H_[3,3] = -COSA*IV_[2]*(IV_[1]^3)
                H_ = U_'*H_*U_
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

