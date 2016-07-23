local format = {}

local format.round(f,p)
  if p == nil then
    if     f < 1     then p = 2
    elseif f < 10    then p = 2
    elseif f < 100   then p = 1
    elseif f < 10000 then p = 1
    else   p = 0
    end
  end
  if p > 0 then
    return(math.floor(f*10^p+0.5)/10^p)
  else
    return(math.floor(f+0.5))
  end
end

local format.formatNumber(n)
  if     n < 10^3  then n = format.round(n)
  elseif n < 10^6  then n = format.round(n/10^3) .."k" 
  elseif n < 10^9  then n = format.round(n/10^6) .."M"
  elseif n < 10^12 then n = format.round(n/10^9) .."B"
  else                  n = format.round(n/10^12).."T"
  end
  return n
end

return format
