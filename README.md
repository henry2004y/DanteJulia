# DanteJulia
Finite volume MHD simulation with structured mesh. This is rewritten from the Matlab version, with improved performance and capabilities.

One issue I encountered is using @view for face values. This greatly slows down the flux calculations because of heap allocated memories. As suggested by Roger on Julia's Chinese forum, one workaround is to use the unsafeArrays.jl package to allocate @view memory on the stack. This is worth trying because for the current implementation, LState_XV and RState_XV are just shifts of the original array State_GV. Ideally there is no need to copy the data: using pointers/views should be enough.

Let me create a simple scenario to deal with the problem and find out a solution. The package UNsafeArray.jl is worth trying.

My test shows that using SubArrays inside for loops is close to the performance of regular arrays. The slowdown is possibly caused by discontinous indexing of the SubArrays. That being said, if it is regularly strided, it should be equivalent to the regular arrays.

I made an experimental choice of adding a SubArray type of FaceState besides the copied array type. Although this would cause type instability for returning union type for calc_face_value, this has been greatly optimized since Julia 0.7 (https://julialang.org/blog/2018/08/union-splitting). The view type is only used for 1st order schemes, while others used the original arrays. (The reason is obvious when you look at the algorithms.)

Further improvements may be possible for 1D and 2D to reduce unnecessary calculations.
For example, in the flux calculations Flux_YV and Flux_ZV are not needed for 1D problems.
However, considering that this code is mainly developed for 3D, the current style may be fine.

If there are small arrays inside functions, consider using static arrays.

@fastmath is another thing worth trying.

Do I need a general divergence calculation function? Or it can be specialized to my grid size?

- [ ] Convert into a package
- [ ] GPU support
- [ ] 2D/3D tests
