function VARDIM(action::String, args::Union{PBM, Int, Float64, Vector{Int}, Vector{Float64}}...)
    name = "VARDIM"

    if action == "setup"
        pb = PB(name)
        pbm = PBM(name)
        pbm.call = getfield(Main, Symbol(name))

        v_ = Dict{String, Float64}()
        ix_ = Dict{String, Int}()
        ig_ = Dict{String, Int}()

        v_["N"] = length(args) < 1 ? 10 : Int64(args[1])
        v_["N+2"] = v_["N"] + 2
        v_["N+1"] = v_["N"] + 1
        v_["1"] = 1
        v_["RN"] = Float64(v_["N"])
        v_["RN+1"] = Float64(v_["N+1"])
        v_["T"] = v_["RN"] * v_["RN+1"]
        v_["SUMJ"] = 0.5 * v_["T"]
        v_["1OVERN"] = 1.0 / v_["RN"]

        pb.xscale = Float64[]
        intvars = Int64[]
        binvars = Int64[]

        for i in 1:v_["N"]
            varname = "X" * string(i)
            iv, ix_, _ = s2mpj_ii(varname, ix_)
            arrset(pb.xnames, iv, varname)
        end

        gtype = String[]
        for i in 1:v_["N"]
            gname = "G" * string(i)
            ig, ig_, _ = s2mpj_ii(gname, ig_)
            arrset(gtype, ig, "<>")
            iv = ix_["X" * string(i)]
            pbm.A[ig, iv] += 1.0
        end

        for i in 1:v_["N"]
            real_i = Float64(i)
            for j in [v_["N+1"], v_["N+2"]]
                gname = "G" * string(j)
                ig, ig_, _ = s2mpj_ii(gname, ig_)
                arrset(gtype, ig, "<>")
                iv = ix_["X" * string(i)]
                pbm.A[ig, iv] += real_i
            end
        end

        pb.n = length(ix_)
        ngrp = length(ig_)
        pbm.objgrps = collect(1:ngrp)
        pb.m = 0

        pbm.gconst = zeros(Float64, ngrp)
        for i in 1:v_["N"]
            pbm.gconst[ig_["G" * string(i)]] = 1.0
        end
        pbm.gconst[ig_["G" * string(v_["N+1"])] ] = v_["SUMJ"]
        pbm.gconst[ig_["G" * string(v_["N+2"])] ] = v_["SUMJ"]

        pb.xlower = zeros(Float64, pb.n)
        pb.xupper = fill(Inf, pb.n)

        pb.x0 = zeros(Float64, pb.n)
        for i in 1:v_["N"]
            i_over_n = Float64(i) * v_["1OVERN"]
            pb.x0[ix_["X" * string(i)]] = 1.0 - i_over_n
        end

        igt_ = Dict{String, Int}()
        for tag in ["gL2", "gL4"]
            it, igt_, _ = s2mpj_ii(tag, igt_)
        end

        for ig in 1:ngrp
            arrset(pbm.grelt, ig, Int64[])
        end
        for i in 1:v_["N+1"]
            ig = ig_["G" * string(i)]
            arrset(pbm.grftype, ig, "gL2")
        end
        arrset(pbm.grftype, ig_["G" * string(v_["N+2"])], "gL4")

        pb.objlower = 0.0

        Asave = pbm.A[1:ngrp, 1:pb.n]
        pbm.A = Asave
        pbm.H = spzeros(Float64, 0, 0)

        pb.pbclass = "C-OUR2-AN-V-0"
        pbm.objderlvl = 2
        pb.objderlvl = pbm.objderlvl

        return pb, pbm

    elseif action == "gL2"
        GVAR_, igr_, nargout, pbm = args
        f_ = GVAR_ * GVAR_
        g_ = nargout > 1 ? 2.0 * GVAR_ : nothing
        H_ = nargout > 2 ? 2.0 : nothing
        return nargout == 1 ? f_ : nargout == 2 ? (f_, g_) : (f_, g_, H_)

    elseif action == "gL4"
        GVAR_, igr_, nargout, pbm = args
        f_ = GVAR_^4
        g_ = nargout > 1 ? 4.0 * GVAR_^3 : nothing
        H_ = nargout > 2 ? 12.0 * GVAR_^2 : nothing
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
