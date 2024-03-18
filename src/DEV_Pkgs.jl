

all_own_pkg() =	(Pkg.activate(); Dict(pkginfo.name=>Pkg.PackageSpec(path=pkginfo.source) for (uuid, pkginfo) in Pkg.dependencies() if pkginfo.is_tracking_path))


