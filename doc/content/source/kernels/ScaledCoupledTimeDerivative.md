# ScaledCoupledTimeDerivative

!syntax description /Kernels/ScaledCoupledTimeDerivative

## Overview

This class inherits from [CoupledTimeDerivative.md] and simply scales the
residual and Jacobian by the user provided `factor`. It is also used for the
dimensionless trapping formulation, where `factor` is set to a concentration
reference ratio. The default value for `factor` is 1.

!syntax parameters /Kernels/ScaledCoupledTimeDerivative

!syntax inputs /Kernels/ScaledCoupledTimeDerivative

!syntax children /Kernels/ScaledCoupledTimeDerivative
