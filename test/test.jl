using Revise

using RelevanceStacktrace
using PkgManager: SOLVE 
using PkgManager: zygoteextensions, refclosures, aritmetics, hwallocator
using PkgManager: losses, optimizers, relevancestacktrace, httputils


# SOLVE(zygoteextensions)
# SOLVE(hwallocator)
SOLVE(refclosures)
SOLVE(aritmetics)
# SOLVE(losses)
# SOLVE(relevancestacktrace)
# SOLVE(optimizers)
# SOLVE(httputils)

#%%

using Pkg
Pkg.precompile()

#%%

using PkgDependency
PkgDependency.tree("Startup")
