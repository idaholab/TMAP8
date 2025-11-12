# Ensuring Clear and Consistent Verification and Validation in TMAP8

“Verification” is the process of determining that a computational model accurately represents the underlying mathematical model and its solution. “Validation” is the process of determining the degree to which a model is an accurate representation of the real world from the perspective of the intended uses of the model – requiring comparison against experimental data. These definitions follow standard engineering terminology [!cite](schwer2007_ver_val_definitions). To guarantee that all verification and validation (V&V) cases in TMAP8 are directly available to users, transparent in their execution, and maintain a consistent format, we have established these standardization guidelines. It is important to note that all V&V cases also serve as MOOSE tests, although sometimes with simplified meshes and larger time steps. These requirements apply to these critical aspects of the V&V/test system:

## Input files

1. +Comprehensive Comments+: Include clear comments within the input file explaining its purpose and any specific requirements for running it successfully. For an example, see [/ver-1a.i].
2. +Constants declaration+: Define all constant values used in the input file at the start of the input file, with self documenting variable names wherever possible. For an example, see [/ver-1a.i].
3. +Documented Units+: Ensure all values within the input file have their units clearly documented using the units functionality in [input file syntax](https://mooseframework.inl.gov/application_usage/input_syntax.html). Use the same functionality for unit conversions. Additional details on the units system can be found in the [MOOSE units](https://mooseframework.inl.gov/source/utils/Units.html) documentation. As a rule, use the easiest-to-read units or the units found in the original reference, if relevant, and convert them to the required units for the numerical solve. For an example, see [/ver-1a.i].
4. +Outputs+: By default, all outputs required for V&V should be enabled. These can be selectively disabled within the test specification for each specific test as needed (see the [MOOSE documentation on the Output System](https://mooseframework.inl.gov/syntax/Outputs/index.html)).
5. +Streamlined Input Files+: Whenever possible, leverage [command-line arguments (CLI)](https://mooseframework.inl.gov/moose/application_usage/command_line_usage.html) to manage input files with minor variations instead of creating duplicate files. For an example, see [/ver-1a/tests].

## Python scripts

1. +Analytical Solution+: The Python script for verification cases should directly calculate the original analytical solution, not rely on pre-tabulated CSV data.
2. +Validation data+: The experimental data used for validation cases should be in a CSV file in the gold folder, and properly referenced in the Python script.
3. +Quantified Comparisons+: When performing a comparison of a TMAP8 result against an analytical equation or experimental data, a Root Mean Square Percentage Error (RMSPE) or other relevant quantitative metric should be calculated. This error metric should be clearly displayed next to the plot line in the comparison plot figures.
4. +Unit Clarity+: Utilize comments within the script to specify the units for all values employed in the analytical solution.
5. +Standardized Constants+: Whenever possible, employ values from [PhysicalConstants](source/utils/TMAP8Constants.md).
6. +Gold File V&V+: The Python scripts should run on the gold files associated with the V&V case. This enables building on-the-fly documentation with the latest simulation results.
7. +Visualization Consistency+: In V&V plots, consistently use solid lines to represent TMAP8 results and dashed lines for analytical solutions. Points should only be used when the focus is on specific data points (e.g., validation or benchmarking).
8. +Write Pythonic code+: When writing Python scripts, aim to follow the [PEP8](https://peps.python.org/pep-0008/) style guide. A key principle is to use existing Python functionality whenever possible instead of writing your own code to do the same thing.

For an example of a python script respecting these guidelines, see [/ver-1a/comparison_ver-1a.py].

## Tests

1. +Comprehensive Testing+: Every input file for V&V should have corresponding [EXODIFF](https://mooseframework.inl.gov/moose/python/testers/Exodiff.html) and [CSVDIFF](https://mooseframework.inl.gov/moose/python/testers/CSVDiff_tester.html) tests to ensure accuracy. EXODIFF tests are not required if the simulation is 0D (single element), and the [PostProcessors](https://mooseframework.inl.gov/moose/syntax/Postprocessors/index.html) to the CSVDIFF already test all the important variables.
2. +Test specification+: Test requirements should detail what the particular test is checking, as well as mention the general physics the tested input file is modeling.
3. +Heavy tests+: TMAP8 tests are expected to run on one processor in around 2 seconds or less. If a V&V case tests requires a simulation with a longer wall time, the test should be declared as a heavy test by adding the ```heavy = true``` to the test specification. Moreover, the test specification should mention that a finer mesh and/or small time step size is being used for V&V.
4. +Script testing+: The Python scripts used for V&V should themselves be subjected to testing to guarantee their reliability.

For an example of test specification file respecting these guidelines, see [/ver-1a/tests].

## Documentation

1. +Content+: The document should (a) describe the case, (b) detail how it is  modeled, (c) provide the necessary model parameter values, (d) present the results of the TMAP8 simulation, (e) contain an active link to the input file and the test specification.
2. +Automated Figure Generation+: Figures used in the V&V process should be automatically generated during the build phase by executing the dedicated plotting Python script. This enables building on-the-fly documentation with the latest simulation results.
3. +Analytical Equations+: Ensure the equations documented exactly match those used within the Python script. Always cite the original sources for the equations (not a V&V report) to maintain proper attribution.
4. +Validation data+: Provide the reference for the original experimental source of the data used in validation cases.
5. +Detailed Derivations+: If any quantity conversions are performed within the documentation, provide clear derivations to illustrate the conversion process. Show any derivations that are performed for converting quantities in the documentation.
6. +Schematic Representation+: Whenever helpful, include schematic figures that visually represent what the specific V&V case is modeling to enhance understanding.
7. +V&V vs Test+: If a coarser meshed simulation was used in the tests compared to what is used in the actual V&V, add a note at the end of the documentation page that mentions this and why it was done.

For an example of a documentation page respecting these guidelines, see [ver-1a](ver-1a.md).

!bibtex bibliography
