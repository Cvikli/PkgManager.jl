module PkgManager
using Pkg
using TOML
using DataStructures

const SKIP_MODULES = ["","Base"]

all_own_pkg() =	(Pkg.activate(); Dict(pkginfo.name=>Pkg.PackageSpec(path=pkginfo.source) for (uuid, pkginfo) in Pkg.dependencies() if pkginfo.is_tracking_path))

get_pkg_name(pkg) = return pkg.name !== nothing ? pkg.name : split(replace(pkg.path[end] == '/' ? pkg.path[1:end-1] : pkg.path,".jl" => ""),"/")[end]
get_pkg_root(pattern, str) = match(pattern, str)  

search_modules(pkg, pkg_name) = begin
	all_modules = Set{String}()
	pkg_dir = pkg.path * "/src/"
	files = readdir(pkg_dir)
	println(files)

	for file in files

		open(pkg_dir * file) do f
			for l in eachline(f)
				for pattern in [r"^using ([^:\.\n]*)", r"^import ([^:\.\n]*)"]
					m = get_pkg_root(pattern, l)
					if !(m === nothing)
						reg_group_1 = m[1]
						for pkg_nam in split(reg_group_1, ",") # We handle "using... [with multiple module]"!
							pkg_name_clean = strip(pkg_nam)
							pkg_name_clean in SKIP_MODULES && continue
							pkg_name_clean == pkg_name && @warn "$pkg_name_clean is referencing to your own pkg! USE \".\" (dot reference)"
							push!(all_modules, pkg_name_clean)
						end
					end
				end
			end
		end
	end
	all_modules
end

SOLVE_PKG(pkg_name, own_pkgs=all_own_pkg()) = begin 
	@assert pkg_name in keys(own_pkgs) "$pkg_name is not a development pkg as far as we see. Dev pkgs are $(keys(own_pkgs)). That's what you want to resolve when you develop your own pkg."
	found_modules = search_modules(own_pkgs[pkg_name], pkg_name)
	CLEAN_Project_toml(pkg_name, own_pkgs, found_modules)
	SOLVE_dependency_issue(pkg_name, own_pkgs, found_modules)
end
SOLVE_dependency_issue(pkg_name, own_pkgs=all_own_pkg(), found_modules=Set{String}()) = begin 
	@assert pkg_name in keys(own_pkgs) "$pkg_name is not a development pkg as far as we see. Dev pkgs are $(keys(own_pkgs)). That's what you want to resolve when you develop your own pkg."
	pkg=own_pkgs[pkg_name]

	found_modules = isempty(found_modules) ? search_modules(pkg, pkg_name) : found_modules

	public_packages = [pk for pk in found_modules if !(pk in keys(own_pkgs))]
	own_packages    = [own_pkgs[pk] for pk in found_modules if pk in keys(own_pkgs)]

	println(public_packages)
	println(get_pkg_name.(own_packages))

	Pkg.activate(pkg.path)
	# Pkg.upgrade_manifest()
	length(own_packages) > 0 && Pkg.develop(own_packages)
	length(public_packages) > 0 && Pkg.add(public_packages)
	Pkg.resolve()
	Pkg.instantiate()
	# Pkg.precompile()
	Pkg.activate()
	Pkg.resolve()
	Pkg.instantiate()
end

CLEAN_Project_toml(pkg_name, own_pkgs=all_own_pkg(), found_modules=Set{String}()) = begin 
	@assert pkg_name in keys(own_pkgs) "$pkg_name is not a development pkg as far as we see. Dev pkgs are $(keys(own_pkgs)). That's what you want to resolve when you develop your own pkg."
	pkg=own_pkgs[pkg_name]

	Project_toml=TOML.parsefile(pkg.path *"/"* "Project.toml")
	!("deps" in keys(Project_toml)) && return

	found_modules = isempty(found_modules) ? search_modules(pkg, pkg_name) : found_modules

	removable_pkgs =  String[pk for (pk,uuid) in Project_toml["deps"] if !(pk in found_modules)]
	!(isempty(removable_pkgs)) && println("$(pkg_name)/Project.toml unused pkgs are being removed: $removable_pkgs") 
	active_pkgs = OrderedDict{String, Any}(pk=> uuid for (pk,uuid) in Project_toml["deps"] if pk in found_modules)
	Project_toml["deps"] = sort(active_pkgs)
	# display(data["deps"])
	fio = open(pkg.path *"/"* "Project.toml", "w")
	TOML.print(fio, Project_toml, sorted=false)
	close(fio)
end

# SHOW_UNUSED(own_pkgs=all_own_pkg()) = begin
# 	this_pkg_name = get_pkg_name(pkg)
# 	public_packages = Set{String}()
# 	own_packages = Set{PackageSpec}()
# 	files = readdir(pkg.path * "/src")
# 	for file in files
# 		fpath = (pkg.path * "/src/" * file)

# 		open(fpath) do f
# 			for l in eachline(f)
# 				for pattern in [r"^using ([^:\.\n]*)", r"^import ([^:\.\n]*)"]
# 					m = get_pkg_root(pattern, l)
# 					if m === nothing
# 						# println()
# 					else
# 						for pkg_na in split(m[1], ",")
# 							pkg_name = strip(pkg_na)
# 							pkg_name in SKIP_MODULE && continue
# 							pkg_name == this_pkg_name && @warn "$pkg_name is referencing to your own pkg! USE \".\" (dot fpr reference)"
# 							if pkg_name in keys(own_pkgs)
# 								push!(own_packages, own_pkgs[pkg_name])
# 							else
# 								!(pkg_name in [""]) && push!(public_packages, pkg_name)
# 							end
# 						end
# 					end
# 				end
# 			end
# 		end
# 	end
# 	println(files)
# end

# Pkg.activate(zygoteextensions.path)
# Pkg.develop([boilerplate])
# Pkg.add(["InteractiveUtils","Distributed","Flux" ,"ToggleableAsserts"])
# # Pkg.update()
# # Pkg.gc()
# Pkg.resolve()


end # module PkgManager
