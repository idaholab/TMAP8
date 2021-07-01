# PressureReleaseFluxIntegral

!syntax description /UserObjects/PressureReleaseFluxIntegral

## Overview

This object computes the amount of pressure of a specie released into an
enclosure from a neighboring structure. The units corresponding to the `return`
of `PressureReleaseFluxIntegral::computeQpResidual()` should be pressure. Let's
verify this. `_diffusion_coef` has units of length^2/time; `_grad_u` has units
of #/length^4; `_normals` is unitless; `_area` has units of length^2; `_volume`
has units of length^3; `_concentration_to_pressure_conversion_factor` has units
of pressure/(#/length^3); `_dt` has units of time. Applying units to the code

```language=c++
Real
PressureReleaseFluxIntegral::computeQpIntegral()
{
  return -_diffusion_coef[_qp] * _grad_u[_qp] * _normals[_qp] * _area / _volume *
         _concentration_to_pressure_conversion_factor * _dt;
}
```

gives us

length^2/time * #/length^4 * length^2 / length^3 * pressure/(#/length^3) * time
->  pressure which is exactly what we want.

!syntax parameters /UserObjects/PressureReleaseFluxIntegral

!syntax inputs /UserObjects/PressureReleaseFluxIntegral

!syntax children /UserObjects/PressureReleaseFluxIntegral
