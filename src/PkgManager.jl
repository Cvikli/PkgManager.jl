module PkgManager
using Pkg
using TOML
using DataStructures
using Glob

export SOLVE_PKG
const SKIP_MODULES = ["","Base"]

get_all_pkgs() =	(Pkg.activate(); Dict(pkginfo.name=>pkginfo for (uuid, pkginfo) in Pkg.dependencies()))

get_pkg_name(pkg) = return pkg.name !== nothing ? pkg.name : split(replace(pkg.path[end] == '/' ? pkg.path[1:end-1] : pkg.path,".jl" => ""),"/")[end]

function walk_packages(pkg::Pkg.API.PackageInfo)
	skip_modules = Set([SKIP_MODULES..., String(pkg.name)])
	found_packages =  Set{String}()
	dir, entry_file = pkg.source * "/src", pkg.name * ".jl"
	walk_packages!(found_packages, dir, entry_file, skip_modules)
end
# mutating the `found_packages` vector
function walk_packages!(found_packages, dir, fpath, skip_modules, )
	open(dir *"/"* fpath) do f
		for l in eachline(f)
			for pattern in [r"^include\([\"']([^:\"'\n]+)[\"']\)",
											r"^includet\([\"']([^:\"'\n]+)[\"']\)"]
				m = match(pattern, l)
				if m !== nothing
					# getting the new path relative to the current dir/file
					new_dir, filename = dirname(dir *"/"* m[1]), basename(m[1])
					walk_packages!(found_packages, new_dir, filename, skip_modules, )	
				end
			end
			for pattern in [r"^using ([^:\.\n]*)", r"^import ([^:\.\n]*)"] # TODO could be done with Meta.parse
				m = match(pattern, l)
				if m !== nothing
					for pkg_na in split(m[1], ",")
						pkg_name = strip(pkg_na)
						pkg_name in skip_modules && continue
						# pkg_name == this_pkg_name && @warn "$pkg_name is referencing to your own pkg! USE \".\" (dot fpr reference)"
						push!(found_packages, pkg_name)
					end
				end
			end
		end
	end
	found_packages
end

function SOLVE_PKG(pkg_name, all_pkgs=get_all_pkgs())
	!(pkg_name in keys(all_pkgs)) && (@warn("We don't know about $pkg_name."); return)
	@assert all_pkgs[pkg_name].is_tracking_path "$pkg_name is not a development pkg as far as we see. Dev pkgs are $(map(o->o.name, filter(o->o.is_tracking_path, collect(values(all_pkgs))))). That's what you want to resolve when you develop your own pkg."
	pkg = all_pkgs[pkg_name]
	skip_modules = Set([SKIP_MODULES..., String(pkg_name)])
	dir, entry_file = pkg.source * "/src", pkg_name * ".jl"
	found_packages = walk_packages!(Set{String}(), dir, entry_file, skip_modules, )

	CLEAN_Project_toml(pkg_name, all_pkgs, found_packages)
	SOLVE_dependency_issue(pkg_name, all_pkgs, found_packages)
end
function SOLVE_dependency_issue(pkg_name, all_pkgs=get_all_pkgs(), found_packages=Set{String}()) 
	!(pkg_name in keys(all_pkgs)) && (@warn("We don't know about $pkg_name."); return)
	@assert all_pkgs[pkg_name].is_tracking_path "$pkg_name is not a development pkg as far as we see. Dev pkgs are $(map(o->o.name, filter(o->o.is_tracking_path, collect(values(all_pkgs))))). That's what you want to resolve when you develop your own pkg."
	pkg = all_pkgs[pkg_name]

	found_packages = isempty(found_packages) ? walk_packages(pkg) : found_packages

	Pkg.activate(pkg.source)
	# Pkg.upgrade_manifest()
	found_packages_pkginfo = [all_pkgs[name] for name in found_packages]
	registry_packages = [PackageSpec(name=pkginfo.name) for pkginfo in found_packages_pkginfo if pkginfo.is_tracking_registry]
	repo_packages = [PackageSpec(url=pkginfo.git_source) for pkginfo in found_packages_pkginfo if pkginfo.is_tracking_repo]
	dev_packages = [PackageSpec(path=pkginfo.source) for pkginfo in found_packages_pkginfo if pkginfo.is_tracking_path]
	println("Registry packages found: ", [p.name for p in registry_packages])
	println("Dev packages found: ", [pkginfo.name for pkginfo in found_packages_pkginfo if pkginfo.is_tracking_path])
	if length(repo_packages) > 0
		@warn "Still repo packages can cause issues. TODO experiment with the cases when it really causes issues. Usually git clone and Pkg.develop(PKG) solves the issues."
		println("Repo packages found: ", [pkginfo.name for pkginfo in found_packages_pkginfo if pkginfo.is_tracking_repo])
	end
	length(repo_packages) > 0 && Pkg.add(repo_packages)
	length(dev_packages) > 0 && Pkg.develop(dev_packages)
	length(registry_packages) > 0 && Pkg.add(registry_packages)
	Pkg.resolve()
	Pkg.instantiate()
	# Pkg.precompile()
	Pkg.activate()
	Pkg.resolve()
	Pkg.instantiate()
end

function CLEAN_Project_toml(pkg_name, all_pkgs=get_all_pkgs(), found_modules=Set{String}()) 
	@assert all_pkgs[pkg_name].is_tracking_path "$pkg_name is not a development pkg as far as we see. Dev pkgs are $(map(o->o.name, filter(o->o.is_tracking_path, collect(values(all_pkgs))))). That's what you want to resolve when you develop your own pkg."
	pkg=all_pkgs[pkg_name]

	Project_toml=TOML.parsefile(pkg.source *"/"* "Project.toml")
	!("deps" in keys(Project_toml)) && return

	found_modules = isempty(found_modules) ? walk_packages(pkg) : found_modules

	removable_pkgs =  String[pk for (pk,uuid) in Project_toml["deps"] if !(pk in found_modules)]
	!(isempty(removable_pkgs)) && println("$(pkg_name)/Project.toml unused pkgs are being removed: $removable_pkgs") 
	active_pkgs = OrderedDict{String, Any}(pk=> uuid for (pk,uuid) in Project_toml["deps"] if pk in found_modules)
	Project_toml["deps"] = sort(active_pkgs)
	# display(data["deps"])
	fio = open(pkg.source * "/" * "Project.toml", "w")
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
# 					m = match(pattern, l)
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
