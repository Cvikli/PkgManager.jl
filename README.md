# PkgManager.jl
Simple but ultimate PKG managment util to simplify everything to the basic

Have you developed a package and run into an issue like in the "Error" section below?... You do the same steps to resolve. Let's do it automatically with a script. :D

I am aware this is a very slim solution that isn't enough comprehensive and sort of exerimental, but it works 99% of my case.

```julia
] dev ./  # press TAB! So it will list the directories...
dev ./..navigatethere../PkgManager
```
Specify the DEV_Pkgs.jl! (TODO: generate this list automatically somehow. The pkg manager knows about this perfectly I believe!)

test.jl
```
using PkgManager: binanceapi
SOLVE_PKG_DEP(binanceapi)        # due to it is resolved it doesn't solve anything.
```

This can RESOLVE the issues with your package AUTOMATICALLY.
1. It searches all the package you are using in your module and essentially we just resolve it! ;)
	- You have to configure "your packages" so we don't want to update those from the registry. (TODO this could be somehow automatically guessed from the system, also somehow we could ignore the errors from here and do without the pkgs... or something)
2. We update your dependencies. (Not fully useable yet.)


# TODO
- as described above, we could find out what is local package and what is not. 
- if there is no error, then the command shouldn't run.
- ultimately this "solve" command could run automatically when the error arise by the compiler and ask "resolve? (y/n)"
- This package should resolve everything that is resolveable. (And everything should be resolveable we just have to implement the possible options that the developer has, so he can pick the most fitting one. We already has advices what to run... but we could run these automatically basically. Also if we are aware of the problem we could understand the case by checking different package dependencies and registry and resolve it as it is required.) 

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

I feel there are cases, when a package installed in a local `activate`-d environment and then this package cannot resolve the problem. In  this case we have to activate the local environment and delete the pkg from then and install in the "global" env and then rerun the things. This should be also automatized if the case is real. 

I don't know if this is a case, but if there is a pkg struct or functionname that has the same name as a pkg but in a module so it is "hidden" from outside. And if the thing is loaded then... idk... somehow these can cause problem or idk if loaded from another pkg directly... Not sure if this is really a possible case where this pkg didn't work.. ... These things why this is not comprehensive, because I am not fully aware what can cause the problem in each case! This pkg manager should cover EVERY single case just like a "tree" for each problem so it could resolve it automatically the cases that is just trivial.  

