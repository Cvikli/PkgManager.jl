Base.:*(a::Vector{String}, b::Vector{String}) = vcat(a, b)

twin_ai_path = "../twin-ai"
# Pkg.add(Pkg.PackageSpec(path="$(pwd())/MemoizePro/"))
# dev ../../../repo/julia-awesomeness/HwAllocator/
own_pkgs = ["./HwAllocator.jl/"]
own_pkgs *= ["./Boilerplate.jl/"]
own_pkgs *= ["./Arithmetics.jl/"]
# own_pkgs *= ["./BinanceAPI.jl/"]
own_pkgs *= ["./RelevanceStacktrace.jl/"]
# own_pkgs *= ["./EasyPrms.jl/"]
# own_pkgs *= ["../trader-julias/Crypto/"]
own_pkgs *= [twin_ai_path * "/Storage.jl/"]
# own_pkgs *= [Pkg.PackageSpec(path=twin_ai_path * "/PrecompilePkg/")]
own_pkgs *= [twin_ai_path * "/GraphPipe.jl/"]
own_pkgs *= [twin_ai_path * "/GraphPlt.jl/"]
own_pkgs *= [twin_ai_path * "/Storage.jl/"]
own_pkgs *= [twin_ai_path * "/DataPipe.jl/"]
own_pkgs *= [twin_ai_path * "/DiabTrend.jl/"]
own_pkgs *= [twin_ai_path * "/TransGraphPipe.jl/"]
own_pkgs *= [twin_ai_path * "/Amoeba.jl"]
# own_pkgs *= [Pkg.PackageSpec(path="./EasyGrad.jl/")]

using Pkg
@show pwd()
for pkg_path in own_pkgs
	println(pkg_path)
	Pkg.activate(pkg_path)
	Pkg.update()
end
Pkg.activate()
# Pkg.update(pwd() * "/HwAllocator.jl/")

#%%
# for (package, version) in Pkg.installed() # Pkg.dependencies()
all = []
for (uuid, pkginfo) in Pkg.dependencies()
	package, version, direct_depenency, custom_path = pkginfo.name, pkginfo.version, pkginfo.is_direct_dep, pkginfo.is_tracking_path
	custom_path && push!(all, package)
	custom_path && (println("$package with custompath is left out for safety reason!"); continue)
	!direct_depenency && continue
	# println(package)
end
#%%
a=[pkginfo for (uuid, pkginfo) in Pkg.dependencies() if pkginfo.is_tracking_path][6]
#%%
(a.is_pinned)
#%%
typeof(a)
#%%
a.source
#%%
fieldnames(typeof(a))
#%%
[pkginfo.name for (uuid, pkginfo) in Pkg.dependencies() if pkginfo.is_tracking_path]
#%%
sort(all)
#%%

Pkg.activate()
