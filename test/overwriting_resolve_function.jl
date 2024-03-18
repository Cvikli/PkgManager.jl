
ERROR: LoadError: ArgumentError: Package  does not have  in its dependencies:
- You may have a partially installed environment. Try `Pkg.instantiate()`
  to ensure all packages in the environment are installed.
- Or, if you have  checked out for development and have
  added  as a dependency but haven't updated your primary
  environment's manifest file, try `Pkg.resolve()`.
- Otherwise you may need to report an issue with 

#%%

using RelevanceStacktrace
#%%

using Base: PkgId
using Base: assert_havelock, root_module_exists
using Base: _require_world_age, require_lock, LoadingCache, LOADING_CACHE, identify_package_env, _track_dependencies, _require_prelocked
using Base: require, _require_prelocked, __require_prelocked
using Base: @logmsg, start_loading, toplevel_load, locate_package, set_pkgorigin_version_path, end_loading, JLOptions, _require_search_from_serialized, PrecompilableError
using Base: _concrete_dependencies, __toplevel__, PKG_PRECOMPILE_HOOK, maybe_cachefile_lock, compilecache
using Base: compilecache_dir, loaded_modules_array, module_build_id, CoreLogging, create_expr_cache


function custom_compilecache(pkg::PkgId, path::String, internal_stderr::IO = stderr, internal_stdout::IO = stdout,
                      keep_loaded_modules::Bool = true)

    @nospecialize internal_stderr internal_stdout
    # decide where to put the resulting cache file
		@show "OWEOWEO"
    cachepath = compilecache_dir(pkg)
		@show "OWEOWEO???"

    # build up the list of modules that we want the precompile process to preserve
    concrete_deps = copy(_concrete_dependencies)
    if keep_loaded_modules
        for mod in loaded_modules_array()
            if !(mod === Main || mod === Core || mod === Base)
                push!(concrete_deps, PkgId(mod) => module_build_id(mod))
            end
        end
    end
    # run the expression and cache the result
    verbosity = isinteractive() ? CoreLogging.Info : CoreLogging.Debug
    @logmsg verbosity "Precompiling $pkg"
		@show "OWEOWdwdwEO???"
    # create a temporary file in `cachepath` directory, write the cache in it,
    # write the checksum, _and then_ atomically move the file to `cachefile`.
    mkpath(cachepath)
    cache_objects = JLOptions().use_pkgimages != 0
    tmppath, tmpio = mktemp(cachepath)
		@show "OWEOWdwdwEO???"

    if cache_objects
        tmppath_o, tmpio_o = mktemp(cachepath)
        tmppath_so, tmpio_so = mktemp(cachepath)
    else
        tmppath_o = nothing
    end
    local p
		@show "OWEOWdwdwEOwfwef???"
    try
			close(tmpio)
			@show "OWEOWdwdwEOwfwef??323?"
        if cache_objects
            close(tmpio_o)
            close(tmpio_so)
        end
				@show pkg 
				@show path 
				@show tmppath, tmppath_o
				@show concrete_deps
        p = create_expr_cache(pkg, path, tmppath, tmppath_o, concrete_deps, internal_stderr, internal_stdout)
				@show "OWEOWdwdwEOwfwef??323?sdsd"
				@show "OWEOWdwdwEOwfwef??323?'''''''''''''"
				@show "OWEOWdwdwEOwfwef??323?'''2''''''''''"
				@show "OWEOWdwdwEOwfwef??323?'''1''''''''''"
				@show "OWEOWdwdwEOwfwef??323?'''54''''''''''"
				@show "OWEOWdwdwEOwfwef??323?''''6'''''''''"
				
				
				@show success(p)
				@show "OWEOWdw'''''"
				@show "OWEOWdwdefe'''''"
				@show "OWEOWdwdwEOwfwef??323?12121''''6'''''''''"
        if success(p)
						@show "OWEOWdwdwEOwfwef??323?sdsf232d"

            if cache_objects
                # Run linker over tmppath_o
                Linking.link_image(tmppath_o, tmppath_so)
            end

            # Read preferences hash back from .ji file (we can't precompute because
            # we don't actually know what the list of compile-time preferences are without compiling)
            prefs_hash = preferences_hash(tmppath)
            cachefile = compilecache_path(pkg, prefs_hash)
            ocachefile = cache_objects ? ocachefile_from_cachefile(cachefile) : nothing

            # append checksum for so to the end of the .ji file:
            crc_so = UInt32(0)
            if cache_objects
                crc_so = open(_crc32c, tmppath_so, "r")
            end
						@show "f33f??323?sdsf232d"

            # append extra crc to the end of the .ji file:
            open(tmppath, "r+") do f
                if iszero(isvalid_cache_header(f))
                    error("Invalid header for $pkg in new cache file $(repr(tmppath)).")
                end
                seekend(f)
                write(f, crc_so)
                seekstart(f)
                write(f, _crc32c(f))
            end

            # inherit permission from the source file (and make them writable)
            chmod(tmppath, filemode(path) & 0o777 | 0o200)

            # prune the directory with cache files
            if pkg.uuid !== nothing
                entrypath, entryfile = cache_file_entry(pkg)
                cachefiles = filter!(x -> startswith(x, entryfile * "_") && endswith(x, ".ji"), readdir(cachepath))
                if length(cachefiles) >= MAX_NUM_PRECOMPILE_FILES[]
                    idx = findmin(mtime.(joinpath.(cachepath, cachefiles)))[2]
                    evicted_cachefile = joinpath(cachepath, cachefiles[idx])
                    @debug "Evicting file from cache" evicted_cachefile
                    rm(evicted_cachefile; force=true)
                    try
                        rm(ocachefile_from_cachefile(evicted_cachefile); force=true)
                        @static if Sys.isapple()
                            rm(ocachefile_from_cachefile(evicted_cachefile) * ".dSYM"; force=true, recursive=true)
                        end
                    catch e
                        e isa IOError || rethrow()
                    end
                end
            end
						@show "OWEOWdwdwEfefefO???---"
						
						@show "OWEOWdwdwEfefefO???++"
            if cache_objects
							@show "23f23DOWEOWdwdwEfefefO???"
							try
								@show "23f23DsfsdOWEOWdwdwEfefefO???"
								rename(tmppath_so, ocachefile::String; force=true)
							catch e
								@show "OWEOWdwdwEfefefO???++"

                    e isa IOError || rethrow()
                    isfile(ocachefile::String) || rethrow()
                    # Windows prevents renaming a file that is in use so if there is a Julia session started
                    # with a package image loaded, we cannot rename that file.
                    # The code belows append a `_i` to the name of the cache file where `i` is the smallest number such that
                    # that cache file does not exist.
                    ocachename, ocacheext = splitext(ocachefile::String)
                    old_cachefiles = Set(readdir(cachepath))
                    num = 1
                    while true
                        ocachefile = ocachename * "_$num" * ocacheext
                        in(basename(ocachefile), old_cachefiles) || break
                        num += 1
                    end
                    # TODO: Risk for a race here if some other process grabs this name before us
                    cachefile = cachefile_from_ocachefile(ocachefile)
                    rename(tmppath_so, ocachefile::String; force=true)
                end
                @static if Sys.isapple()
                    run(`$(Linking.dsymutil()) $ocachefile`, Base.DevNull(), Base.DevNull(), Base.DevNull())
                end
            end
						@show "OWEOWdwdwEfefefO???sdfsd"

            # this is atomic according to POSIX (not Win32):
            rename(tmppath, cachefile; force=true)
            return cachefile, ocachefile
        end
				@show "???????"
				
			finally
				@show "??d33f3?????"
        rm(tmppath, force=true)
        if cache_objects
            rm(tmppath_o::String, force=true)
            rm(tmppath_so, force=true)
        end
    end
    if p.exitcode == 125
        return PrecompilableError()
    else
        error("Failed to precompile $pkg to $(repr(tmppath)).")
    end
end


# Returns `nothing` or the new(ish) module
function custom_require(pkg::PkgId, env=nothing)
	@show "CC"

		assert_havelock(require_lock)
		loaded = start_loading(pkg)
		loaded === nothing || return loaded

		last = toplevel_load[]
		try
				toplevel_load[] = false
				# perform the search operation to select the module file require intends to load
				path = locate_package(pkg, env)
				@show "CC???"
				if path === nothing
						throw(ArgumentError("""
								Package $pkg is required but does not seem to be installed:
									- Run `Pkg.instantiate()` to install all recorded dependencies.
								"""))
				end
				@show "CCQQQ???"
				set_pkgorigin_version_path(pkg, path)
				@show "CCQqqQQ???"

				pkg_precompile_attempted = false # being safe to avoid getting stuck in a Pkg.precompile loop

				# attempt to load the module file via the precompile cache locations
				if JLOptions().use_compiled_modules != 0
						@label load_from_cache
						m = _require_search_from_serialized(pkg, path, UInt128(0))
						if m isa Module
								return m
						end
				end
				@show "CCQqQQ???"

				# if the module being required was supposed to have a particular version
				# but it was not handled by the precompile loader, complain
				for (concrete_pkg, concrete_build_id) in _concrete_dependencies
						if pkg == concrete_pkg
								@warn """Module $(pkg.name) with build ID $((UUID(concrete_build_id))) is missing from the cache.
											This may mean $pkg does not support precompilation but is imported by a module that does."""
								if JLOptions().incremental != 0
										# during incremental precompilation, this should be fail-fast
										throw(PrecompilableError())
								end
						end
				end
				@show "CCQQQefe???"

				if JLOptions().use_compiled_modules != 0
						if (0 == ccall(:jl_generating_output, Cint, ())) || (JLOptions().incremental != 0)
								if !pkg_precompile_attempted && isinteractive() && isassigned(PKG_PRECOMPILE_HOOK)
										pkg_precompile_attempted = true
										unlock(require_lock)
										try
												@invokelatest PKG_PRECOMPILE_HOOK[](pkg.name, _from_loading = true)
										finally
												lock(require_lock)
										end
										@goto load_from_cache
								end
								# spawn off a new incremental pre-compile task for recursive `require` calls
								cachefile_or_module = maybe_cachefile_lock(pkg, path) do
										# double-check now that we have lock
										m = _require_search_from_serialized(pkg, path, UInt128(0))
										m isa Module && return m

				@show "CCQQQefe???csdcsdcsd"
				custom_compilecache(pkg, path)
				@show "CCQQQefe??????????"
								end
								cachefile_or_module isa Module && return cachefile_or_module::Module
								cachefile = cachefile_or_module
								if isnothing(cachefile) # maybe_cachefile_lock returns nothing if it had to wait for another process
										@goto load_from_cache # the new cachefile will have the newest mtime so will come first in the search
								elseif isa(cachefile, Exception)
										if precompilableerror(cachefile)
												verbosity = isinteractive() ? CoreLogging.Info : CoreLogging.Debug
												@logmsg verbosity "Skipping precompilation since __precompile__(false). Importing $pkg."
										else
												@warn "The call to compilecache failed to create a usable precompiled cache file for $pkg" exception=m
										end
										# fall-through to loading the file locally if not incremental
								else
										cachefile, ocachefile = cachefile::Tuple{String, Union{Nothing, String}}
										m = _tryrequire_from_serialized(pkg, cachefile, ocachefile)
										if !isa(m, Module)
												@warn "The call to compilecache failed to create a usable precompiled cache file for $pkg" exception=m
										else
												return m
										end
								end
								if JLOptions().incremental != 0
										# during incremental precompilation, this should be fail-fast
										throw(PrecompilableError())
								end
						end
				end

				@show "CCQQQeefwefwefe???"
				# just load the file normally via include
				# for unknown dependencies
				uuid = pkg.uuid
				uuid = (uuid === nothing ? (UInt64(0), UInt64(0)) : convert(NTuple{2, UInt64}, uuid))
				old_uuid = ccall(:jl_module_uuid, NTuple{2, UInt64}, (Any,), __toplevel__)
				if uuid !== old_uuid
						ccall(:jl_set_module_uuid, Cvoid, (Any, NTuple{2, UInt64}), __toplevel__, uuid)
				end
				unlock(require_lock)
				try
						include(__toplevel__, path)
						loaded = get(loaded_modules, pkg, nothing)
				finally
						lock(require_lock)
						if uuid !== old_uuid
								ccall(:jl_set_module_uuid, Cvoid, (Any, NTuple{2, UInt64}), __toplevel__, old_uuid)
						end
				end
		finally
				toplevel_load[] = last
				end_loading(pkg, loaded)
		end
		return loaded
end

function custom__require_prelocked(uuidkey::PkgId, env=nothing)
	@show "QQQ"
	
	assert_havelock(require_lock)
	@show "QQQ+"
	if !root_module_exists(uuidkey)
		@show "QQQ+fef"
		newm = custom_require(uuidkey, env)
		@show "QQQ+fef?????"
		if newm === nothing
			error("package `$(uuidkey.name)` did not define the expected \
			module `$(uuidkey.name)`, check for typos in package module name")
		end
		insert_extension_triggers(uuidkey)
		# After successfully loading, notify downstream consumers
		run_package_callbacks(uuidkey)
	else
		@show "QQQ+élefe"
		m = get(loaded_modules, uuidkey, nothing)
		@show "QQQ+élefesdfds"
			if m !== nothing
					explicit_loaded_modules[uuidkey] = m
					run_package_callbacks(uuidkey)
			end
			newm = root_module(uuidkey)
	end
	return newm
end

function Base._require_prelocked(uuidkey::PkgId, env=nothing)
	@show "FEFE???"
	if _require_world_age[] != typemax(UInt)
		@show "FEFE???+"
		@invokelatest custom__require_prelocked(uuidkey, env)
	else
		@show "FEFE???-"
		Base.invoke_in_world(_require_world_age[], custom__require_prelocked, uuidkey, env)
	end
end
function custom__require(into::Module, mod::Symbol)
	@show "HEYYY!!!!!"
	@lock require_lock begin
	LOADING_CACHE[] = LoadingCache()
	try
			uuidkey_env = identify_package_env(into, String(mod))
			# Core.println("require($(PkgId(into)), $mod) -> $uuidkey_env")
			@show "OKKKK?"
			@show uuidkey_env
			if uuidkey_env === nothing
				@show "HEYYY????SDFSsdfsd?"
				@show "???FEFEFE????SDFSsdfsd?"
					where = PkgId(into)
					@show "----HEYYY????SDFS?"
					if where.uuid === nothing
						@show "+++++++++sdfsdfsdHEYYY???"
						hint, dots = begin
									if isdefined(into, mod) && getfield(into, mod) isa Module
											true, "."
									elseif isdefined(parentmodule(into), mod) && getfield(parentmodule(into), mod) isa Module
											true, ".."
									else
											false, ""
									end
							end
							hint_message = hint ? ", maybe you meant `import/using $(dots)$(mod)`" : ""
							install_message = if mod != :Pkg
									start_sentence = hint ? "Otherwise, run" : "Run"
									"\n- $start_sentence `import Pkg; Pkg.add($(repr(String(mod))))` to install the $mod package."
							else  # for some reason Pkg itself isn't availability so do not tell them to use Pkg to install it.
									""
							end
							@show "||||||sdfsdfsdHEYYY???"

							throw(ArgumentError("Package $mod not found in current path$hint_message.$install_message"))
					else
							@show "||||||HEYYY???"
							manifest_warnings = collect_manifest_warnings()
							throw(ArgumentError("""
							Package $(where.name) does not have $mod in its dependencies:
							$manifest_warnings- You may have a partially installed environment. Try `Pkg.instantiate()`
								to ensure all packages in the environment are installed.
							- Or, if you have $(where.name) checked out for development and have
								added $mod as a dependency but haven't updated your primary
								environment's manifest file, try `Pkg.resolve()`.
							- Otherwise you may need to report an issue with $(where.name)"""))
							@show "HEYYY"
							@show "HEYYY"
							@show "HEYYY"
					end
			end
			@show "NOTT OK???----- $uuidkey_env"
			uuidkey, env = uuidkey_env
			@show "NOTT OK????SDFSsdfsdsdfsdsdfds?"
			
			if _track_dependencies[]
				@show "QQQfdssdfsdf?"
				path = binpack(uuidkey)
				push!(_require_dependencies, (into, path, UInt64(0), UInt32(0), 0.0))
			end
			@show "HEYYYsdfdssdfsdsdsdf?"
			return _require_prelocked(uuidkey, env)
		finally
			@show "HEYYY????SDFSsdfsdsdfsdsdfdssdfsdsdsdsdfsdff?"
			LOADING_CACHE[] = nothing
	end
	end
end

function Base.require(into::Module, mod::Symbol)
	@show "SUCCCSSEESE"
	if _require_world_age[] != typemax(UInt)
		@show "SUCCCSSEESE?"
		@invokelatest custom__require(into, mod)
	else
		@show "SUCCCSSEESE++?"
		Base.invoke_in_world(_require_world_age[], custom__require, into, mod)
	end
end

@show "ok overwrite this!!"

using BinanceAPI
#%%



