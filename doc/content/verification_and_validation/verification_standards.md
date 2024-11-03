# Ensuring Clear and Consistent Verification in TMAP8

To guarantee that all verification cases in TMAP8 are readily grasped, transparent in their execution, and maintain a consistent format, we've established these standardization guidelines. It's important to note that all verification cases also serve as MOOSE tests, although sometimes with simplified meshes and larger timesteps. These requirements apply to four critical aspects of the verification/test system:

## Input files

1. +Comprehensive Comments+: Include clear comments within the input file explaining its purpose and any specific requirements for running it successfully.
2. +Constants declaration+: Define all constant values used in the input file at the start of the input file, with self documenting variable names wherever possible.
3. +Documented Units+: Ensure all values within the input file have their units clearly documented using the units functionality in [input file syntax](https://mooseframework.inl.gov/application_usage/input_syntax.html). Use the same functionality for unit conversions. Additional details on the units system can be found in the [MOOSE units](https://mooseframework.inl.gov/source/utils/Units.html) documentation. As a rule, use the easiest-to-read units and convert them to the required units for the numerical solve.
4. +Outputs+: By default, all outputs required for verification should be enabled. These can be selectively disabled within the test specification for each specific test as needed.
5. +Streamlined Input Files+: Whenever possible, leverage [command-line arguments (CLI)](https://mooseframework.inl.gov/moose/application_usage/command_line_usage.html) to manage input files with minor variations instead of creating duplicate files.

## Python scripts

1. +Analytical Solution+: The Python script for verification should directly calculate the original analytical solution, not rely on pre-tabulated CSV data.
2. +Quantified Comparisons+: When performing a comparison of a TMAP8 result against an analytical equation or experimental data, a Root Mean Square Percentage Error (RMSPE) or other relevant quantitative metric should be calculated. This error metric should be clearly displayed next to the plot line in the comparison plot figures.
3. +Unit Clarity+: Utilize comments within the script to specify the units for all values employed in the analytical solution.
4. +Standardized Constants+: Whenever possible, employ values from [PhysicalConstants](source/utils/PhysicalConstants.md).
5. +Gold File Verification+: The Python scripts should run on the gold files associated with the verification case.
6. +Visualization Consistency+: In verification plots, consistently use solid lines to represent TMAP8 results and dashed lines for analytical solutions. Points should only be used when the focus is on specific data points (e.g., validation or benchmarking).
7. +Write Pythonic code+: When writing Python scripts, aim to follow the [PEP8](https://peps.python.org/pep-0008/) style guide. A key principle is to use existing Python functionality whenever possible instead of writing your own code to do the same thing.

## Tests

1. +Comprehensive Testing+: Every input file for verification should have corresponding [EXODIFF](https://mooseframework.inl.gov/moose/python/testers/Exodiff.html) and [CSVDIFF](https://mooseframework.inl.gov/moose/python/testers/CSVDiff_tester.html) tests to ensure accuracy. EXODIFF tests are not required if the simulation is 0D (single element), and the [PostProcessors](https://mooseframework.inl.gov/moose/syntax/Postprocessors/index.html) to the CSVDIFF already test all the important variables.
2. +Test specification+: Test requirements should detail what the particular test is checking, as well as mention the general physics the tested input file is modeling.
3. +Heavy tests+: If a heavy test is used for verification, the test specification should mention that a finer mesh and/or small time step size is being used for verification. A test can be declared to be a heavy test by adding the ```heavy = true``` to the test specification.
4. +Script Verification+: The Python scripts used for verification should themselves be subjected to testing to guarantee their reliability.

## Documentation

1. +Automated Figure Generation+: Figures used in the verification process should be automatically generated during the build phase by executing the dedicated plotting Python script.
2. +Analytical Equations+: Ensure the equations documented exactly match those used within the Python script. Always cite the original sources for the equations (not a verification report) to maintain proper attribution.
3. +Detailed Derivations+: If any quantity conversions are performed within the documentation, provide clear derivations to illustrate the conversion process.Show any derivations that are performed for converting quantities in the documentation.
4. +Schematic Representation+: Include schematic figures that visually represent what the specific verification case is modeling to enhance understanding.
5. +Verification vs Test+: If a coarser meshed simulation was used in the tests compared to what is used in the actual verification, add a note at the end of the documentation page that mentions this and why it was done.
