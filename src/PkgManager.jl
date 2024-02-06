module PkgManager
using Pkg

reinstall(p::PackageSpec) = (Pkg.resolve(p))
# reinstall(p::PackageSpec) = (Pkg.rm(p.name); Pkg.develop(p))

include("DEV_Pkgs.jl")

const SKIP_MODULE = ["Base"]

get_pkg_name(pkg) = return pkg.name !== nothing ? pkg.name : split(replace(pkg.path[end] == '/' ? pkg.path[1:end-1] : pkg.path,".jl" => ""),"/")[end]
get_pkg_root(pattern, str) = match(pattern, str)  

SOLVE_PKG_DEP(pkg, all_own_pkg=all_own_pkg) = begin 
	this_pkg_name = get_pkg_name(pkg)
	public_packages = Set{String}()
	own_packages = Set{PackageSpec}()
	files = readdir(pkg.path * "/src")
	for file in files
		fpath = (pkg.path * "/src/" * file)

		open(fpath) do f
			for l in eachline(f)
				for pattern in [r"^using ([^:\.\n]*)", r"^import ([^:\.\n]*)"]
					m = get_pkg_root(pattern, l)
					if m === nothing
						# println()
					else
						for pkg_na in split(m[1], ",")
							pkg_name = strip(pkg_na)
							pkg_name in SKIP_MODULE && continue
							pkg_name == this_pkg_name && @warn "$pkg_name is referencing to your own pkg! USE \".\" (dot fpr reference)"
							if pkg_name in keys(all_own_pkg)
								push!(own_packages, all_own_pkg[pkg_name])
							else
								!(pkg_name in [""]) && push!(public_packages, pkg_name)
							end
						end
					end
				end
			end
		end
	end
	println(files)
	println(collect(public_packages))
	println(String[collect(get_pkg_name.(own_packages))...])

	Pkg.activate(pkg.path)
	# Pkg.upgrade_manifest()
	length(own_packages) > 0 && Pkg.develop(collect(own_packages))
	length(public_packages) > 0 && Pkg.add(collect(public_packages))
	Pkg.resolve()
	Pkg.instantiate()
	# Pkg.precompile()
	Pkg.activate()
	Pkg.resolve()
	Pkg.instantiate()
end

SHOW_UNUSED(all_own_pkg=all_own_pkg) = begin
	this_pkg_name = get_pkg_name(pkg)
	public_packages = Set{String}()
	own_packages = Set{PackageSpec}()
	files = readdir(pkg.path * "/src")
	for file in files
		fpath = (pkg.path * "/src/" * file)

		open(fpath) do f
			for l in eachline(f)
				for pattern in [r"^using ([^:\.\n]*)", r"^import ([^:\.\n]*)"]
					m = get_pkg_root(pattern, l)
					if m === nothing
						# println()
					else
						for pkg_na in split(m[1], ",")
							pkg_name = strip(pkg_na)
							pkg_name in SKIP_MODULE && continue
							pkg_name == this_pkg_name && @warn "$pkg_name is referencing to your own pkg! USE \".\" (dot fpr reference)"
							if pkg_name in keys(all_own_pkg)
								push!(own_packages, all_own_pkg[pkg_name])
							else
								!(pkg_name in [""]) && push!(public_packages, pkg_name)
							end
						end
					end
				end
			end
		end
	end
	println(files)
end

# Pkg.activate(zygoteextensions.path)
# Pkg.develop([boilerplate])
# Pkg.add(["InteractiveUtils","Distributed","Flux" ,"ToggleableAsserts"])
# # Pkg.update()
# # Pkg.gc()
# Pkg.resolve()


end # module PkgManager
