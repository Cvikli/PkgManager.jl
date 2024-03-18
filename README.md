# PkgManager.jl
Simple but ultimate PKG managment util to simplify everything to the basic

Have you developed a package and run into an issue like in the "Error" section below?... You do the same steps to resolve. Let's do it automatically with a script. :D

I am aware this is a very slim solution that isn't enough comprehensive (sort of experimental), but it works 99% of the times in my case.

```julia
] dev ./  # press TAB! So it will list the directories...
dev ./..navigatethere../PkgManager
```

Let's say we have [`BinanceAPI.jl`](https://github.com/Cvikli/BinanceAPI.jl) for development pkg (`] dev ./repo.../BinanceAPI.jl`).

In test.jl
```
using PkgManager: SOLVE_PKG
SOLVE_PKG("BinanceAPI")      # due to it is resolved it won't do anything of course. 
```

This can RESOLVE the issues with your package AUTOMATICALLY.
1. It searches all the package you are using in your module and essentially we just resolve it! ;)
	- We locate every pkg that is for development and every else that is for public. 
2. We also this pkg is able to find unnecessary/unused dependency in your Project.toml and remove it. 


# TODO
- if there is no error, then the command shouldn't run.
- ultimately this "solve" command could run automatically when the error arise by the compiler and ask "resolve? (y/n)". Sadly it isn't enough to overload a function in the Julia Base as there is a "new process" started when the pkg loads... or something very complex thing is happening in the behind.
- This package should resolve everything that is resolveable. (And everything should be resolveable we just have to implement the possible options that the developer has, so he can pick the most fitting one. We already has advices what to run... but we could run these automatically basically. Also if we are aware of the problem we could understand the case by checking different package dependencies and registry and resolve it as it is required.) 
- if a pkg has problem and is being resolved... it will also gives errors for the child pkg... or something like this

# Error
The error this package is intended to solve automatically:
```
ERROR: LoadError: ArgumentError: Package BinanceAPI does not have RateLimiter in its dependencies:
- You may have a partially installed environment. Try `Pkg.instantiate()`
  to ensure all packages in the environment are installed.
- Or, if you have BinanceAPI checked out for development and have
  added RateLimiter as a dependency but haven't updated your primary
  environment's manifest file, try `Pkg.resolve()`.
- Otherwise you may need to report an issue with BinanceAPI
```

# Cases (JUST guesses for myself)

I feel there are cases, when a package installed in a local `activate`-d environment and then this package cannot resolve the problem. In  this case we have to activate the local environment and delete the pkg from there and install in the "global" env and then rerun the things. This should be also automatized if the case is real. 

I don't know if this is a case, but if there is a pkg struct or functionname that has the same name as a pkg but in a module so it is "hidden" from outside. And if the thing is loaded then... idk... somehow these can cause problem or idk if loaded from another pkg directly... Not sure if this is really a possible case where this pkg didn't work.. ... These things why this is not comprehensive, because I am not fully aware what can cause the problem in each case! This pkg manager should cover EVERY single case just like a "tree" for each problem so it could resolve it automatically the cases that is just trivial.  

