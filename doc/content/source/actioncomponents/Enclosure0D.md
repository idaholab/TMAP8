# Enclosure0D

!syntax description /ActionComponents/Enclosure0D

This 0D [ActionComponent.md] represents an enclosure. An enclosure in TMAP8
is a point-volume in which a species can concentrate, dissolve, or be released.

## Interaction with common TMAP8 Physics

The [!param](/ActionComponents/Enclosure0D/physics) parameter of an `EnclosureD` can be used
to define the [Physics](syntax/Physics/index.md) that should be active on the structure.
See more details on the [ComponentPhysicsInterface.md] page.

### Material properties

To vary the material properties used in each `Physics`, one can set the [!param](/ActionComponents/Structure1D/property_names) and [!param](/ActionComponents/Structure1D/property_values) parameters in the `Enclosure0D`.
See more details on the [ComponentMaterialPropertyInterface.md] page.

For a [PointDissolution.md] `Physics` to be used you can define on
the `Enclosure0D`:

- the equilibrium constant material property, to be used in the [!param](/Physics/PointDissolution/equilibrium_constants) parameter

!syntax parameters /ActionComponents/Enclosure0D

!syntax inputs /ActionComponents/Enclosure0D

!syntax children /ActionComponents/Enclosure0D
