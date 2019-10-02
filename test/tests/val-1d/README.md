# Trapping test

The trapping test features some oscillations in the solution for whatever
reason. In order for the oscillations to not take over the simulation, it seems
that the ratio of the **inverse of the Fourier number** must be kept
sufficiently high, e.g. `h^2 / (D * dt)`. Included in this directory are three
`png` files that show the permeation for different `h` and `dt` values. They are
summarized below:

- `nx-80.png`: `nx = 80` and `dt = .0625`
- `nx-40.png`: `nx = 40` and `dt = .25`
- `nx-20.png`: `nx = 20` and `dt = 1`

The oscillations in the permeation graph go away with increasing fineness in the
mesh and in `dt`.
