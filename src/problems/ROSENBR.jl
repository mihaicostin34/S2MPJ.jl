function ROSENBR(action::String, args::Union{PBM, Int, Float64, Vector{Int}, Vector{Float64}}...)
    name = "ROSENBR"

    if action == "setup"
        pb = PB(name)
        pbm = PBM(name)
        pbm.call = getfield(Main, Symbol(name))

        v_ = Dict{String, Float64}()
        ix_ = Dict{String, Int}()
        ig_ = Dict{String, Int}()

        pb.xscale = Float64[]
        intvars = Int64[]
        binvars = Int64[]

        for i in 1:2
            varname = "X" * string(i)
            iv, ix_, _ = s2mpj_ii(varname, ix_)
            arrset(pb.xnames, iv, varname)
        end

        gtype = String[]
        group_defs = [("G1", "X2", 0.01), ("G2", "X1", nothing)]
        for (gname, vname, scale) in group_defs
            ig, ig_, _ = s2mpj_ii(gname, ig_)
            arrset(gtype, ig, "<>")
            iv = ix_[vname]
            pbm.A[ig, iv] += Float64(1.0)
            if scale !== nothing
                arrset(pbm.gscale, ig, Float64(scale))
            end
        end

        pb.n = length(ix_)
        ngrp = length(ig_)
        pbm.objgrps = collect(1:ngrp)
        pb.m = 0

        pbm.gconst = zeros(Float64, ngrp)
        pbm.gconst[ig_["G2"]] = Float64(1.0)

        pb.xlower = zeros(Float64, pb.n)
        pb.xupper = fill(Inf, pb.n)

        pb.x0 = zeros(Float64, pb.n)
        pb.x0[ix_["X1"]] = Float64(-1.2)
        pb.x0[ix_["X2"]] = Float64(1.0)

        iet_ = Dict{String, Int}()
        elftv = Vector{Vector{String}}()
        it, iet_, _ = s2mpj_ii("eSQ", iet_)
        loaset(elftv, it, 1, "V1")

        ie_ = Dict{String, Int}()
        ielftype = Vector{Int64}()
        ie, ie_, _ = s2mpj_ii("E1", ie_)
        arrset(pbm.elftype, ie, "eSQ")
        arrset(ielftype, ie, iet_["eSQ"])
        vname = "X1"
        iv, ix_, pb = s2mpj_nlx(vname, ix_, pb, 1, nothing, nothing, nothing)
        posev = findfirst(x -> x == "V1", elftv[ielftype[ie]])
        loaset(pbm.elvar, ie, posev, iv)

        igt_ = Dict{String, Int}()
        it, igt_, _ = s2mpj_ii("gL2", igt_)

        for ig in 1:ngrp
            arrset(pbm.grelt, ig, Int64[])
            arrset(pbm.grftype, ig, "gL2")
        end

        ig = ig_["G1"]
        posel = length(pbm.grelt[ig]) + 1
        loaset(pbm.grelt, ig, posel, ie_["E1"])
        loaset(pbm.grelw, ig, posel, Float64(-1.0))

        pb.objlower = 0.0

        Asave = pbm.A[1:ngrp, 1:pb.n]
        pbm.A = Asave
        pbm.H = spzeros(Float64, 0, 0)

        pb.pbclass = "C-SUR2-AN-2-0"
        pbm.objderlvl = 2
        pb.objderlvl = pbm.objderlvl
        return pb, pbm

    elseif action == "eSQ"
        EV_ = args[1]
        iel_ = args[2]
        nargout = args[3]
        pbm = args[4]
        f_ = EV_[1] * EV_[1]
        if nargout > 1
            dim = try length(IV_) catch; length(EV_) end
            g_ = zeros(Float64, dim)
            g_[1] = 2.0 * EV_[1]
            if nargout > 2
                H_ = zeros(Float64, 1, 1)
                H_[1, 1] = 2.0
            end
        end
        return nargout == 1 ? f_ : nargout == 2 ? (f_, g_) : (f_, g_, H_)

    elseif action == "gL2"
        GVAR_ = args[1]
        igr_ = args[2]
        nargout = args[3]
        pbm = args[4]
        f_ = GVAR_ * GVAR_
        if nargout > 1
            g_ = 2.0 * GVAR_
            if nargout > 2
                H_ = 2.0
            end
        end
        return nargout == 1 ? f_ : nargout == 2 ? (f_, g_) : (f_, g_, H_)

    elseif action in ["fx", "fgx", "fgHx", "cx", "cJx", "cJHx", "cIx", "cIJx", "cIJHx", "cIJxv", "fHxv",
                      "cJxv", "cJtxv", "cIJtxv", "Lxy", "Lgxy", "LgHxy", "LIxy", "LIgxy", "LIgHxy",
                      "LHxyv", "LIHxyv"]
        pbm = args[1]
        if pbm.name == name
            pbm.has_globs = [0, 0]
            return s2mpj_eval(action, args...)
        else
            println("ERROR: please run " * name * " with action = setup")
            return ntuple(i -> undef, args[end])
        end
    else
        println("ERROR: action " * action * " unavailable for problem " * name * ".jl")
        return ntuple(i -> undef, args[end])
    end
end
