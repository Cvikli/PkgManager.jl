
using Pkg

include("PC_config.jl")
reinstall(p::PackageSpec) = (Pkg.resolve(p))
# reinstall(p::PackageSpec) = (Pkg.rm(p.name); Pkg.develop(p))
storage = Pkg.PackageSpec(path="$(twin_ai_path)/Storage.jl")
datapipe = Pkg.PackageSpec(path="$(twin_ai_path)/DataPipe.jl")
graphpipe = Pkg.PackageSpec(path="$(twin_ai_path)/GraphPipe.jl")
transgraphpipe = Pkg.PackageSpec(path="$(twin_ai_path)/TransGraphPipe.jl")
graphplt = Pkg.PackageSpec(path="$(twin_ai_path)/GraphPlt.jl")
amoeba = Pkg.PackageSpec(path="$(twin_ai_path)/Amoeba.jl", name="Amoeba")
DiabTrend = Pkg.PackageSpec(path="$(twin_ai_path)/DiabTrend.jl", name="DiabTrend")

crypto = Pkg.PackageSpec(path="../trader-julias/Crypto/")

boilerplate = Pkg.PackageSpec(path="../julia-awesomeness/Boilerplate.jl")
hwallocator = Pkg.PackageSpec(path="../julia-awesomeness/HwAllocator.jl")
namedcolors = Pkg.PackageSpec(path="../julia-awesomeness/NamedColors.jl")
startup = Pkg.PackageSpec(path="../julia-awesomeness/Startup.jl", name="Startup")
zygoteextensions = Pkg.PackageSpec(path="../julia-awesomeness/ZygoteExtensions.jl")
sparsearrayvectors = Pkg.PackageSpec(path="../julia-awesomeness/SparseArrayVectors.jl", name="SparseArrayVectors")
easyprms = Pkg.PackageSpec(path="../julia-awesomeness/EasyPrms.jl")
relevancestacktrace = Pkg.PackageSpec(path="../julia-awesomeness/RelevanceStacktrace.jl")
unicodeplotssimple = Pkg.PackageSpec(path="../julia-awesomeness/UnicodePlotsSimple.jl/")

#%%
Pkg.activate(startup.path)
Pkg.update()
Pkg.add(["EllipsisNotation", "Distributed", "Revise", "Printf", "Plots", "JLD2", "FileIO", "CUDA"])
Pkg.develop([boilerplate, zygoteextensions, graphpipe, transgraphpipe, amoeba, graphplt, namedcolors])
Pkg.gc()
Pkg.resolve()
Pkg.activate()
#%%
Pkg.activate(zygoteextensions.path)
Pkg.develop([boilerplate])
Pkg.add(["InteractiveUtils","Distributed","Flux", "ToggleableAsserts"])
Pkg.update()
Pkg.gc()
Pkg.resolve()
#%%
using SparseArrayVectors
# dump(sparsearrayvectors)
#%%
Pkg.activate(sparsearrayvectors.path)
Pkg.update()
Pkg.develop([boilerplate, zygoteextensions])
Pkg.gc()
Pkg.activate()
reinstall(sparsearrayvectors)
#%%
#%%
sparsearrayvectors.path
# Pkg.resolve()
#%%
Pkg.activate(easyprms.path)
Pkg.update()
Pkg.develop([hwallocator, boilerplate, zygoteextensions])
Pkg.gc()
Pkg.resolve()
#%%
# Pkg.add("Zygote")
Pkg.activate(amoeba.path)
Pkg.develop([easyprms, sparsearrayvectors, unicodeplotssimple, zygoteextensions, transgraphpipe, storage])
Pkg.add(["EllipsisNotation","Formatting", "LinearAlgebra", "Distributed","Flux"])
Pkg.resolve()
# reinstall(amoeba)
#%%
Pkg.activate(DiabTrend.path)
Pkg.develop([zygoteextensions, graphpipe, boilerplate, unicodeplotssimple, hwallocator, storage])
Pkg.resolve()
#%%

Pkg.activate()
Pkg.resolve()

#%%
# Pkg.activate(storage.path)
# Pkg.add("JSON3")
Pkg.activate()
Pkg.develop([boilerplate, hwallocator, namedcolors, relevancestacktrace, unicodeplotssimple])
Pkg.develop([storage, datapipe, graphpipe, transgraphpipe, graphplt, amoeba, DiabTrend])
Pkg.develop([zygoteextensions])
#%%
Pkg.develop([crypto])


Pkg.activate(datapipe.path)
Pkg.develop([boilerplate, storage])
Pkg.update()
# Pkg.resolve()
#%%
Pkg.activate(graphpipe.path)
Pkg.develop([boilerplate, storage, hwallocator, unicodeplotssimple])
Pkg.resolve()

#%%
Pkg.activate(transgraphpipe.path)
Pkg.develop([boilerplate, storage, graphpipe])
Pkg.update()
# Pkg.resolve()
#%%
Pkg.activate(graphplt.path)
# Pkg.develop([namedcolors])
Pkg.develop([boilerplate, storage, unicodeplotssimple, graphpipe, transgraphpipe])
Pkg.update()
# Pkg.resolve()
#%%
Pkg.activate(amoeba.path)
Pkg.add(["ColorSchemes", "Plots"])
Pkg.develop([boilerplate, hwallocator, unicodeplotssimple, graphpipe, transgraphpipe])
Pkg.update()
Pkg.resolve()

# Pkg.build()
#%%
Pkg.activate(); Pkg.instantiate()
Pkg.Registry.update(); 
Pkg.update()
Pkg.resolve()


#%%
using Pkg

Pkg.activate(storage.path)
Pkg.add("JSON3")

#%%
# Pkg.activate(graphplt.path)
# Pkg.rm("HwAllocator")

