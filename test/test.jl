using Revise

# todo... run these:
# ] up
# ] registry up

using RelevanceStacktrace
using PkgManager: SOLVE_PKG_DEP 
using PkgManager: zygoteextensions, refclosures, aritmetics, hwallocator
using PkgManager: losses, optimizers, relevancestacktrace, httputils
using PkgManager: boilerplate, binanceapi, cryptoohlcv

# SOLVE_PKG_DEP(zygoteextensions)
# SOLVE_PKG_DEP(hwallocator)
# SOLVE_PKG_DEP(refclosures)
# SOLVE_PKG_DEP(aritmetics)
# SOLVE_PKG_DEP(boilerplate)
SOLVE_PKG_DEP(binanceapi)
SOLVE_PKG_DEP(cryptoohlcv)
# SOLVE_PKG_DEP(losses)
# SOLVE_PKG_DEP(relevancestacktrace)
# SOLVE_PKG_DEP(optimizers)
# SOLVE_PKG_DEP(httputils)

#%%

using Pkg
Pkg.precompile()

#%%

using PkgDependency
PkgDependency.tree("Startup")
