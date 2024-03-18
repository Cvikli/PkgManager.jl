using Revise

# todo... run these:
# ] up
# ] registry up

#%%
using RelevanceStacktrace
using PkgManager: SOLVE_PKG 
SOLVE_PKG("BinanceAPI")
SOLVE_PKG("Pythonish")
SOLVE_PKG("InitLoadableStruct")
SOLVE_PKG("ExtendableStruct")
SOLVE_PKG("PersistableStruct")
SOLVE_PKG("UniversalStruct")
SOLVE_PKG("Unimplemented")
SOLVE_PKG("MyPKG")
SOLVE_PKG("Utils")
SOLVE_PKG("TestPKG")
SOLVE_PKG("MemoizeTyped")
SOLVE_PKG("Losses")
SOLVE_PKG("HTTPUtils")
SOLVE_PKG("Optimizers")
SOLVE_PKG("HwAllocator")
SOLVE_PKG("Arithmetics")
SOLVE_PKG("AsyncTerminal")
SOLVE_PKG("BinanceAPI")
SOLVE_PKG("UnicodePlotsSimple")
SOLVE_PKG("Boilerplate")
SOLVE_PKG("NamedColors")
#%%
using PkgManager: all_own_pkg 
all_own_pkg()
#%%
using PkgManager: SOLVE_dependency_issue 
SOLVE_dependency_issue("BinanceAPI")
#%%
using PkgManager: CLEAN_Project_toml
CLEAN_Project_toml("BinanceAPI")
#%%


#%%
using PkgManager: mypkg, testpkg




#%%

using Pkg
Pkg.precompile()

#%%

using PkgDependency
PkgDependency.tree("Startup")

#%%


using Pkg

Pkg.status()

#%%
