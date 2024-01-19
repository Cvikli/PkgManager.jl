using Revise

using PkgResolver: SOLVE 
using PkgResolver: zygoteextensions, refclosures, aritmetics, hwallocator
using PkgResolver: losses, optimisers, relevancestacktrace, httputils


SOLVE(zygoteextensions)
SOLVE(hwallocator)
SOLVE(refclosures)
SOLVE(aritmetics)
SOLVE(losses)
SOLVE(relevancestacktrace)
SOLVE(optimisers)
SOLVE(httputils)


#%%

using Pkg
Pkg.precompile()

#%%

using PkgDependency
PkgDependency.tree("Startup")
