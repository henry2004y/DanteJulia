# Time stepping

function init_timestep(param::Param)
   nI, nJ, nK = param.nI, param.nJ, param.nK
   time_G = Array{Float64,3}(undef, nI, nJ, nK)
end

function calc_timestep!(param::Param, speedFlux::SpeedFlux, time_G)

   CFL = param.CFL
   CellSize_D = param.CellSize_D
   Cmax_XF = speedFlux.Cmax_XF
   Cmax_YF = speedFlux.Cmax_YF
   Cmax_ZF = speedFlux.Cmax_ZF

   nI, nJ, nK = param.nI, param.nJ, param.nK

   time_G .= 0.0
   if nI > 1
      @inbounds for k=1:nK, j=1:nJ, i=1:nI
         time_G[i,j,k] += CFL / max(Cmax_XF[i+1,j,k], Cmax_XF[i,j,k]) * CellSize_D[1]
      end
   end

   if nJ > 1
      @inbounds for k=1:nK, j=1:nJ, i=1:nI
         time_G[i,j,k] += CFL / max(Cmax_YF[i,j+1,k], Cmax_YF[i,j,k]) * CellSize_D[2]
      end
   end

   if nK > 1
      @inbounds for k=1:nK, j=1:nJ, i=1:nI
         time_G[i,j,k] += CFL / max(Cmax_ZF[i,j,k+1], Cmax_ZF[i,j,k]) * CellSize_D[3]
      end
   end

   dt = param.TimeAccurate ? minimum(time_G) : 0.0

   return dt
end