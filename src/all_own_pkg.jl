
julia_awesome_path="./"

all_own_pkg = Dict{String, PackageSpec}(
	# "Startup"           => (startup             = Pkg.PackageSpec(path=julia_awesome_path * "Startup.jl");),
	"Pythonish"           => (pythonish           = Pkg.PackageSpec(path=julia_awesome_path * "Pythonish.jl");),
	"Losses"              => (losses              = Pkg.PackageSpec(path=julia_awesome_path * "Losses.jl");),
	"HTTPUtils"           => (httputils           = Pkg.PackageSpec(path=julia_awesome_path * "HTTPUtils.jl");),
	"Optimisers"          => (optimisers          = Pkg.PackageSpec(path=julia_awesome_path * "Optimisers.jl");),
	"HwAllocator"         => (hwallocator         = Pkg.PackageSpec(path=julia_awesome_path * "HwAllocator.jl");),
	"NamedColors"         => (namedcolors         = Pkg.PackageSpec(path=julia_awesome_path * "NamedColors.jl");),
	"Aritmetics"          => (aritmetics          = Pkg.PackageSpec(path=julia_awesome_path * "Aritmetics.jl");),
	"ZygoteExtensions"    => (zygoteextensions    = Pkg.PackageSpec(path=julia_awesome_path * "ZygoteExtensions.jl");),
	"LazySortedArray.jl"  => (lazysortedarray     = Pkg.PackageSpec(path=julia_awesome_path * "LazySortedArray.jl.jl");),
	"RelevanceStacktrace" => (relevancestacktrace = Pkg.PackageSpec(path=julia_awesome_path * "RelevanceStacktrace.jl");),
	"RefClosures"         => (refclosures         = Pkg.PackageSpec(path=julia_awesome_path * "RefClosures.jl");),
	"UnicodePlotsSimple"  => (unicodeplotssimple  = Pkg.PackageSpec(path=julia_awesome_path * "UnicodePlotsSimple.jl/");),
	"Boilerplate"         => (boilerplate         = Pkg.PackageSpec(path=julia_awesome_path * "Boilerplate.jl");),
	"AsyncTerminal"       => (asyncterminal       = Pkg.PackageSpec(path=julia_awesome_path * "AsyncTerminal.jl");),
)