/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "SpeciesTrappingPhysics.h"
#include "ActionComponent.h"
#include "MooseUtils.h"
#include "FEProblemBase.h"

// Register the actions for the objects actually used
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "init_physics");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "init_component_physics");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "copy_vars_physics");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "check_integrity");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "check_integrity_early_physics");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_variable");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_ic");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_kernel");

InputParameters
SpeciesTrappingPhysics::validParams()
{
  InputParameters params = SpeciesPhysicsBase::validParams();
  params.addClassDescription(
      "Add Physics for the trapping of species on multi-dimensional components.");
  params.addParam<std::vector<VariableName>>(
      "mobile",
      {},
      "The variable(s) representing the mobile concentration(s) of solute species on each "
      "component."
      " If a single vector is specified, the same mobile species are used on each component.");

  params.addParam<bool>("separate_variables_per_component",
                        false,
                        "Whether to create new variables for each trapped species on every "
                        "component, or whether to only create variables.");

  params.addParam<std::vector<Real>>(
      "alpha_t",
      {},
      "The trapping rate coefficient for each component and species. This has units of 1/time "
      "(e.g. no number densities are involved)"
      "If a single vector is specified, the same trapping rate coefficient will be used on every "
      "component");
  params.addParam<std::vector<Real>>(
      "trapping_energy",
      {},
      "The trapping energy in units of Kelvin. If a single vector is specified, "
      "the same trapping energy will be used on every component");
  params.addParam<Real>(
      "N",
      "The atomic number density of the host material for each component, shared for all species.");
  params.addParam<std::vector<FunctionName>>(
      "Ct0", {}, "The fraction of host sites that can contribute to trapping");
  params.addParam<Real>("trap_per_free", "The number of trapped species per free species");
  params.addParam<bool>("different_traps_for_each_species",
                        false,
                        "Wheter the traps are shared by each species or not");
  params.addParam<bool>(
      "automatic_trapping_scaling",
      false,
      "Whether to use dimensionless trapped-species variables (Ĉ_t = C_t / C_t_ref) "
      "with per-species reference concentrations. When true, trap_per_free is not required "
      "and TrappingNodalKernelDimensionless / ReleasingNodalKernelDimensionless are used. "
      "The mobile concentration variable remains in physical units.");

  params.addParam<std::vector<Real>>(
      "alpha_r",
      {},
      "The release rate coefficient. If a single vector is specified, "
      "the same release rate coefficient will be used on every component");
  params.addParam<std::vector<Real>>(
      "detrapping_energy",
      {},
      "The detrapping energy in units of Kelvin. If a single vector is specified, "
      "the same detrapping energy will be used on every component");

  // Parameter groups
  params.addParamNamesToGroup(
      "alpha_t trapping_energy N Ct0 trap_per_free different_traps_for_each_species", "Trapping");
  params.addParamNamesToGroup("alpha_r temperature detrapping_energy", "Releasing");
  params.addParamNamesToGroup("automatic_trapping_scaling", "Scaling");

  return params;
}

SpeciesTrappingPhysics::SpeciesTrappingPhysics(const InputParameters & parameters)
  : SpeciesPhysicsBase(parameters),
    // If specified in the Physics block, all parameters are retrieved here
    _mobile_species_names({getParam<std::vector<VariableName>>("mobile")}),
    _alpha_ts({getParam<std::vector<Real>>("alpha_t")}),
    _trapping_energies({getParam<std::vector<Real>>("trapping_energy")}),
    _Ns(isParamValid("N") ? std::vector<Real>(1, getParam<Real>("N")) : std::vector<Real>()),
    _Ct0s({getParam<std::vector<FunctionName>>("Ct0")}),
    _trap_per_frees(isParamValid("trap_per_free")
                        ? std::vector<Real>(1, getParam<Real>("trap_per_free"))
                        : std::vector<Real>()),
    _alpha_rs({getParam<std::vector<Real>>("alpha_r")}),
    _detrapping_energies({getParam<std::vector<Real>>("detrapping_energy")}),
    _single_variable_set(!getParam<bool>("separate_variables_per_component")),
    _automatic_trapping_scaling(getParam<bool>("automatic_trapping_scaling"))
{
  // We allow overlaps between mobile species names because two trapped species could release to the
  // same mobile species and adding the two time derivative kernels is correct

  // All the other parameters can vary on each component
  if (_single_variable_set)
    checkVectorParamNotEmpty<NonlinearVariableName>("species");

  // Only set the other parameters if setting the species
  checkSecondParamSetOnlyIfFirstOneSet("species", "mobile");
  checkSecondParamSetOnlyIfFirstOneSet("species", "alpha_t");
  checkSecondParamSetOnlyIfFirstOneSet("species", "trapping_energy");
  checkSecondParamSetOnlyIfFirstOneSet("species", "N");
  checkSecondParamSetOnlyIfFirstOneSet("species", "Ct0");
  if (!_automatic_trapping_scaling)
    checkSecondParamSetOnlyIfFirstOneSet("species", "trap_per_free");
  checkSecondParamSetOnlyIfFirstOneSet("species", "alpha_r");
  checkSecondParamSetOnlyIfFirstOneSet("species", "detrapping_energy");

  // Check sizes
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, MooseFunctorName>(
      "species", "species_initial_concentrations", /*ignore_empty_second*/ true);
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, VariableName>("species", "mobile", true);
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>("species", "alpha_t", true);
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>("species", "trapping_energy", true);
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, FunctionName>("species", "Ct0", true);
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>("species", "alpha_r", true);
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>(
      "species", "detrapping_energy", true);
}

Real
SpeciesTrappingPhysics::mobileConcentrationReference(unsigned int /*c_i*/) const
{
  return 1.0;
}

Real
SpeciesTrappingPhysics::trappedConcentrationReference(unsigned int c_i) const
{
  return _automatic_trapping_scaling ? 1.0 / _trap_per_frees[c_i] : 1.0;
}

Real
SpeciesTrappingPhysics::variableScalingFromReference(Real reference) const
{
  return 1.0 / reference;
}

Real
SpeciesTrappingPhysics::siteDensityReference(unsigned int c_i) const
{
  return _automatic_trapping_scaling ? _Ns[c_i] : 1.0;
}

Real
SpeciesTrappingPhysics::timeReference(unsigned int /*c_i*/) const
{
  return 1.0;
}

Real
SpeciesTrappingPhysics::temperatureReference(unsigned int c_i) const
{
  if (!_automatic_trapping_scaling)
    return 1.0;

  const auto & temp = _component_temperatures[c_i];
  return MooseUtils::parsesToReal(temp) ? MooseUtils::convert<Real>(temp) : 1.0;
}

Real
SpeciesTrappingPhysics::autoTrapConcentrationReference(unsigned int c_i, unsigned int s_j) const
{
  const auto & ct0_name = _Ct0s[c_i][s_j];
  Real ct0_value;
  if (MooseUtils::parsesToReal(ct0_name))
    ct0_value = MooseUtils::convert<Real>(ct0_name);
  else
  {
    // Evaluate the function at t=0, origin as a representative near-surface maximum.
    // For functions that peak at the surface (e.g., damage-trap profiles), this is exact.
    ct0_value = getProblem().getFunction(ct0_name).value(0, Point(0, 0, 0));
    if (ct0_value <= 0)
    {
      mooseWarning("SpeciesTrappingPhysics: Ct0 function '",
                   ct0_name,
                   "' evaluated to ",
                   ct0_value,
                   " at (t=0, x=0). Using 1.0 as fallback for trap concentration reference.");
      ct0_value = 1.0;
    }
  }
  const Real reference = _Ns[c_i] * ct0_value;
  if (_verbose)
    mooseInfo("SpeciesTrappingPhysics: auto trap concentration reference for species '",
              _Ct0s[c_i][s_j],
              "': N=",
              _Ns[c_i],
              ", Ct0_representative=",
              ct0_value,
              ", C_t_ref=",
              reference);
  return reference;
}

void
SpeciesTrappingPhysics::addComponent(const ActionComponent & component)
{
  for (const auto & block : component.blocks())
    _blocks.push_back(block);
  _components.push_back(component.name());

  // Index of the component in all the component-indexed vectors
  const auto comp_index = _components.size() - 1;

  // Process each of the component's parameters, adding defaults to avoid breaking the double-vector
  // indexing when acceptable
  // These parameters are known to be defined for a Structure1D, so we retrieve them from the
  // component's parameters. If they are not defined on the Physics or the component, we error
  processComponentParameters<std::vector<NonlinearVariableName>>(
      "species", component.name(), comp_index, _species, "species", false, {});
  processComponentParameters<std::vector<Real>>("species_scaling_factors",
                                                component.name(),
                                                comp_index,
                                                _scaling_factors,
                                                "species_scaling_factors",
                                                true,
                                                std::vector<Real>(_species[comp_index].size(), 1));
  processComponentParameters<std::vector<MooseFunctorName>>("species_initial_concentrations",
                                                            component.name(),
                                                            comp_index,
                                                            _initial_conditions,
                                                            "species_initial_concentrations",
                                                            false,
                                                            {});
  processComponentParameters<MooseFunctorName>("temperature",
                                               component.name(),
                                               comp_index,
                                               _component_temperatures,
                                               "temperature",
                                               false,
                                               "");

  // Special case: mobile. There are no 'mobile' parameters on components at this time. So mobile is
  // shared between components and species. This call will simply use the parameter set on the
  // SpeciesTrappingPhysics to fill '_mobile_species_name'
  processComponentParameters<std::vector<VariableName>>("mobile",
                                                        component.name(),
                                                        comp_index,
                                                        _mobile_species_names,
                                                        "mobile (not defined at this time)",
                                                        true,
                                                        _mobile_species_names[0]);

  // These parameters should be defined as material properties by the user on the Component
  // or on the Physics.
  // We only support Real numbers for now as the consuming kernels only support Real
  processComponentMatprop<std::vector<Real>>(
      "alpha_t", component, comp_index, _species.back(), _alpha_ts);
  processComponentMatprop<std::vector<Real>>(
      "trapping_energy", component, comp_index, _species.back(), _trapping_energies);
  processComponentMatprop<Real>("N", component, comp_index, _species.back(), _Ns);
  processComponentMatprop<std::vector<FunctionName>>(
      "Ct0", component, comp_index, _species.back(), _Ct0s);
  processComponentMatprop<Real>(
      "trap_per_free", component, comp_index, _species.back(), _trap_per_frees);
  processComponentMatprop<std::vector<Real>>(
      "alpha_r", component, comp_index, _species.back(), _alpha_rs);
  processComponentMatprop<std::vector<Real>>(
      "detrapping_energy", component, comp_index, _species.back(), _detrapping_energies);
}

VariableName
SpeciesTrappingPhysics::getSpeciesVariableName(unsigned int c_i, unsigned int s_j) const
{
  mooseAssert(c_i < _species.size(), "component index higher than number of components");
  mooseAssert(s_j < _species[c_i].size(), "species index higher than number of species");
  if (_single_variable_set)
    return _species[0][s_j];
  else
    // Add the component name if defining variables on a per-component basis
    return _species[c_i][s_j] + "_" + _components[c_i];
}

void
SpeciesTrappingPhysics::addSolverVariables()
{
  const std::string variable_type = "MooseVariable";
  InputParameters params = getFactory().getValidParams(variable_type);
  params.set<MooseEnum>("family") = "LAGRANGE";
  params.set<MooseEnum>("order") = FIRST;

  // Allow using blocks even with the loops on components
  if (_components.empty())
  {
    if (_single_variable_set)
    {
      _components.push_back("");
      if (_species[0].empty())
        paramError("species", "Should not be empty if not using Components");
      if (_scaling_factors[0].empty())
        _scaling_factors[0] = std::vector<Real>(_species.size(), 1);
      if (_mobile_species_names[0].empty())
        paramError("mobile", "Should not be empty if not using Components");
      if (_alpha_ts[0].empty())
        paramError("alpha_t", "Should not be empty if not using Components");
      if (_trapping_energies[0].empty())
        paramError("trapping_energy", "Should not be empty if not using Components");
      if (_Ns.empty())
        paramError("N", "Should not be empty if not using Components");
      if (_Ct0s[0].empty())
        paramError("Ct0", "Should not be empty if not using Components");
      if (!_automatic_trapping_scaling && _trap_per_frees.empty())
        paramError("trap_per_free", "Should not be empty if not using Components");
      if (_alpha_rs[0].empty())
        paramError("alpha_r", "Should not be empty if not using Components");
      if (_component_temperatures[0].empty())
        paramError("temperature", "Should not be empty if not using Components");
      if (_detrapping_energies[0].empty())
        paramError("detrapping_energy", "Should not be empty if not using Components");
    }
    else
      paramError("separate_variables_per_component",
                 "Physics is not defined on any Component, this parameter should be set to false");
  }

  // Check component-indexed parameters
  checkSizeComponentSpeciesIndexedVectorOfVector(_scaling_factors, "species_scaling_factors", true);

  for (const auto c_i : index_range(_components))
  {
    // Use the whole phyiscs block restriction if using the same species variable everywhere
    if (_single_variable_set)
      assignBlocks(params, _blocks);
    else
      assignBlocks(params, getActionComponent(_components[c_i]).blocks());

    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);
      Real scaling = (_scaling_factors.size() > 1)
                         ? _scaling_factors[c_i][s_j]
                         : ((_scaling_factors.size() == 1) ? _scaling_factors[0][s_j] : 1);
      // For dimensionless variables the stored value is already O(1), so no additional
      // variable scaling is applied. The old trap_per_free-based scaling is only used
      // on the legacy (non-dimensionless) path.
      if (_automatic_trapping_scaling)
      {
        // dimensionless variable: scaling = 1 by design
      }
      else if (isParamValid("trap_per_free"))
        scaling *= variableScalingFromReference(trappedConcentrationReference(c_i));
      if (scaling != 1 || !_single_variable_set)
        params.set<std::vector<Real>>("scaling") = {scaling};
      params.set<SolverSystemName>("solver_sys") = getSolverSystem(species_name);
      getProblem().addVariable(variable_type, species_name, params);

      // Keep track of variables
      saveSolverVariableName(species_name);
    }
    if (_single_variable_set)
      break;
  }
}

void
SpeciesTrappingPhysics::addInitialConditions()
{
  const std::string ic_type = "FunctorIC";
  InputParameters params = getFactory().getValidParams(ic_type);

  // Check component-indexed parameters
  if (_components.size())
    checkSizeComponentSpeciesIndexedVectorOfVector(
        _initial_conditions, "species_initial_concentrations", true);

  for (const auto c_i : index_range(_components))
  {
    // Use the whole phyiscs block restriction if using the same species variable everywhere
    if (_single_variable_set)
      if (isParamSetByUser("species_initial_concentrations"))
        assignBlocks(params, _blocks);
      else
        break;
    else
      assignBlocks(params, getActionComponent(_components[c_i]).blocks());

    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);
      params.set<VariableName>("variable") = species_name;
      params.set<MooseFunctorName>("functor") =
          ((_initial_conditions.size() > 1)
               ? _initial_conditions[c_i][s_j]
               : ((_initial_conditions.size() == 1) ? _initial_conditions[0][s_j] : "0"));
      getProblem().addInitialCondition(
          ic_type, "IC_" + species_name + "_" + Moose::stringify(_blocks), params);
    }
    if (_single_variable_set)
      break;
  }
}

void
SpeciesTrappingPhysics::addFEKernels()
{
  // Check component-indexed parameters
  checkSizeComponentSpeciesIndexedVectorOfVector(_alpha_ts, "alpha_t", false);
  checkSizeComponentSpeciesIndexedVectorOfVector(_trapping_energies, "trapping_energy", false);
  checkSizeComponentSpeciesIndexedVectorOfVector(_Ct0s, "Ct0", false);
  checkSizeComponentIndexedVector(_Ns, "N", false);
  if (!_automatic_trapping_scaling)
    checkSizeComponentIndexedVector(_trap_per_frees, "trap_per_free", false);
  checkSizeComponentSpeciesIndexedVectorOfVector(_alpha_rs, "alpha_r", false);
  checkSizeComponentSpeciesIndexedVectorOfVector(_detrapping_energies, "detrapping_energy", false);
  checkSizeComponentIndexedVector(_component_temperatures, "temperature", false);
  checkSizeComponentSpeciesIndexedVectorOfVector(_mobile_species_names, "mobile", false);

  for (const auto c_i : index_range(_components))
  {
    // Use the whole phyiscs block restriction if using the same species variable everywhere
    const auto blocks =
        _single_variable_set ? _blocks : getActionComponent(_components[c_i]).blocks();

    // Create the kernel for each species
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);
      const auto mobile_species_name = _mobile_species_names[c_i][s_j];


      // Time derivative — plain TimeDerivativeNodalKernel suffices for both paths:
      // • dimensionless path: variable IS Ĉ_t (O(1)), so dĈ_t/dt is correct as-is
      // • physical path: variable IS C_t, no per-row scaling is applied here
      if (isTransient())
      {
        const std::string kernel_type = "TimeDerivativeNodalKernel";
        InputParameters params = getFactory().getValidParams(kernel_type);
        params.set<NonlinearVariableName>("variable") = species_name;
        assignBlocks(params, blocks);
        getProblem().addNodalKernel(kernel_type, prefix() + species_name + "_time", params);
      }

      // Helper lambda: set temperature coupling (shared by trapping and releasing kernels)
      auto setTemperature = [&](InputParameters & p)
      {
        mooseAssert(c_i < _component_temperatures.size(), "Should not happen");
        if (MooseUtils::parsesToReal(_component_temperatures[c_i]))
        {
          std::istringstream ss(_component_temperatures[c_i]);
          Real value;
          ss >> value;
          p.defaultCoupledValue("temperature", value, 0);
          p.set<std::vector<VariableName>>("temperature") = {};
        }
        else if (getProblem().hasVariable(_component_temperatures[c_i]))
          p.set<std::vector<VariableName>>("temperature") = {_component_temperatures[c_i]};
        else
          paramError("temperature", "Should be a constant or the name of a variable");
      };

      // Trapping term
      {
        const std::string kernel_type = _automatic_trapping_scaling
                                            ? "TrappingNodalKernelDimensionless"
                                            : "TrappingNodalKernel";
        auto params = _factory.getValidParams(kernel_type);
        assignBlocks(params, blocks);
        params.set<NonlinearVariableName>("variable") = species_name;
        params.set<std::vector<VariableName>>("mobile_concentration") = {mobile_species_name};
        setTemperature(params);
        params.set<Real>("alpha_t") = _alpha_ts[c_i][s_j];
        params.set<Real>("trapping_energy") = _trapping_energies[c_i][s_j];
        params.set<Real>("N") = _Ns[c_i];
        params.set<FunctionName>("Ct0") = _Ct0s[c_i][s_j];

        if (_automatic_trapping_scaling)
        {
          // Dimensionless path: auto-compute C_t_ref = N * Ct0_representative; no trap_per_free
          params.set<Real>("trap_concentration_reference") =
              autoTrapConcentrationReference(c_i, s_j);
        }
        else
        {
          // Physical path: existing TMAPScaling parameters
          params.set<Real>("trap_per_free") = _trap_per_frees[c_i];
          params.set<Real>("trap_concentration_reference") = trappedConcentrationReference(c_i);
          params.set<Real>("mobile_concentration_reference") = mobileConcentrationReference(c_i);
          params.set<Real>("site_density_reference") = siteDensityReference(c_i);
          params.set<Real>("time_reference") = timeReference(c_i);
          params.set<Real>("temperature_reference") = temperatureReference(c_i);
        }

        // Add the other species as occupying traps.
        // For the dimensionless path, other trapped concentrations are expected to be in
        // PHYSICAL units; since SpeciesTrappingPhysics creates all trapped variables as
        // dimensionless, the cross-coupling is skipped here (different_traps_for_each_species
        // semantics are always applied for the dimensionless path).
        if (!_automatic_trapping_scaling)
        {
          std::vector<VariableName> copy_species;
          for (const auto & sp_name : _species[c_i])
            if (sp_name != species_name)
              copy_species.push_back(sp_name);
          if (copy_species.size() && !getParam<bool>("different_traps_for_each_species"))
            params.set<std::vector<VariableName>>("other_trapped_concentration_variables") =
                copy_species;
        }

        getProblem().addNodalKernel(kernel_type, prefix() + species_name + "_enc_trapping", params);
      }

      // Release term
      {
        const std::string kernel_type = _automatic_trapping_scaling
                                            ? "ReleasingNodalKernelDimensionless"
                                            : "ReleasingNodalKernel";
        auto params = _factory.getValidParams(kernel_type);
        assignBlocks(params, blocks);
        params.set<NonlinearVariableName>("variable") = species_name;
        params.set<Real>("alpha_r") = _alpha_rs[c_i][s_j];
        params.set<Real>("detrapping_energy") = _detrapping_energies[c_i][s_j];
        setTemperature(params);

        if (!_automatic_trapping_scaling)
        {
          // Physical path: existing TMAPScaling parameters
          params.set<Real>("trap_concentration_reference") = trappedConcentrationReference(c_i);
          params.set<Real>("mobile_concentration_reference") = mobileConcentrationReference(c_i);
          params.set<Real>("site_density_reference") = siteDensityReference(c_i);
          params.set<Real>("time_reference") = timeReference(c_i);
          params.set<Real>("temperature_reference") = temperatureReference(c_i);
        }

        getProblem().addNodalKernel(kernel_type, prefix() + species_name + "_enc_release", params);
      }

      // Coupling of dC_t_i/dt into the mobile species conservation equation.
      // For the dimensionless path: the variable stores Ĉ_t_i = C_t_i / C_t_ref_i, so
      //   d(C_t_i)/dt = C_t_ref_i · d(Ĉ_t_i)/dt.
      // ScaledCoupledTimeDerivative with factor=C_t_ref_i and trivial (identity) equation
      // scaling (primary_concentration_reference=1, time_reference=1) correctly adds
      //   C_t_ref_i · d(Ĉ_t_i)/dt  to the mobile equation.
      {
        const std::string kernel_type = "ScaledCoupledTimeDerivative";
        auto params = _factory.getValidParams(kernel_type);
        assignBlocks(params, blocks);
        params.set<NonlinearVariableName>("variable") = mobile_species_name;
        params.set<std::vector<VariableName>>("v") = {species_name};
        if (_automatic_trapping_scaling)
        {
          // factor = C_t_ref_i converts dimensionless dĈ_t_i/dt back to physical dC_t_i/dt
          params.set<Real>("factor") = autoTrapConcentrationReference(c_i, s_j);
          // Trivial scaling: residualReference = 1/1 = 1 (identity)
          params.set<Real>("primary_concentration_reference") = 1.0;
          params.set<Real>("coupled_concentration_reference") = 1.0;
          params.set<Real>("time_reference") = 1.0;
        }
        else
        {
          params.set<Real>("factor") = _trap_per_frees[c_i];
          params.set<Real>("primary_concentration_reference") = mobileConcentrationReference(c_i);
          params.set<Real>("coupled_concentration_reference") = trappedConcentrationReference(c_i);
          params.set<Real>("time_reference") = timeReference(c_i);
        }

        getProblem().addKernel(
            kernel_type, prefix() + mobile_species_name + "_from_" + species_name, params);
      }
    }
    if (_single_variable_set)
      break;
  }
}
