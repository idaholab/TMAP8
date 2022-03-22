# val-1a

# Depleting Source Problem

## Test Description

This validation problem is taken from [!cite](longhurst1992verification). The model consists of an enclosure containing a finite concentration of atoms which are allowed to diffuse into a SiC layer over time. No solubility or trapping effects are included. The fractional release from the outside of the shell in a depleting source model in a slab geometry is given by:

\begin{equation}
    FR = 1.0 - \sum_{n=1}^{\infty} \frac{2\ L sec \ \alpha_{n} - \exp\left(\frac{-\alpha_{n}^2 D T}{l^{2}}\right)}{L(L+1) + \alpha_n^{2}}
\end{equation}

where

\begin{equation}
    L = \frac{lA}{V \phi}
\end{equation}

\begin{equation}
    \phi = \frac{source \ concentration}{layer \ concentration}
\end{equation}

where the layer concentration is that at the interface with the source ($\phi$ is constant in time),

    $A$ = surface area

    $V$ = source volume

    $l$ = layer thickness

and the $\alpha_n$ are the roots of

\begin{equation}
    \alpha_n = \frac{L}{tan \ \alpha_n}
\end{equation}

## Results


[val-1a_comparison] shows the comparison of the TMAP8 calculation and the analytical solution. There is good agreement between the two plots.


!media figures/val-1a_comparison.png
    style=width:50%;margin-bottom:2%
    id=val-1a_comparison
    caption=Comparison of TMAP8 calculation with the analytical solution

!bibtex bibliography
