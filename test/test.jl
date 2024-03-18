using Revise

# todo... run these:
# ] up
# ] registry up

using RelevanceStacktrace
using PkgManager: SOLVE_PKG_DEP 


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
using PkgManager: SOLVE_PKG_DEP 
using PkgManager: all_own_pkg 
SOLVE_PKG_DEP("BinanceAPI")
SOLVE_PKG_DEP("Pythonish")
SOLVE_PKG_DEP("InitLoadableStruct")
SOLVE_PKG_DEP("ExtendableStruct")
SOLVE_PKG_DEP("PersistableStruct")
SOLVE_PKG_DEP("UniversalStruct")
SOLVE_PKG_DEP("Unimplemented")
SOLVE_PKG_DEP("HTTPUtils")
SOLVE_PKG_DEP("Optimizers")
SOLVE_PKG_DEP("HwAllocator")
SOLVE_PKG_DEP("Arithmetics")
SOLVE_PKG_DEP("RefClosures")
SOLVE_PKG_DEP("BinanceAPI")
SOLVE_PKG_DEP("CryptoOHLCV")
SOLVE_PKG_DEP("UnicodePlotsSimple")
SOLVE_PKG_DEP("NamedColors")
SOLVE_PKG_DEP("BinanceAPI")

#%%

using Pkg
Pkg.precompile()

#%%

using PkgDependency
PkgDependency.tree("Startup")
