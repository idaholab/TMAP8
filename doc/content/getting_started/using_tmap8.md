# Using TMAP8

## Running an Input File and Viewing Results

!style halign=left
After TMAP8 is installed and tested, you should now be able to run input files
using the `tmap8-opt` executable located at `~/projects/TMAP8`. Input files
demonstrating the capabilities of TMAP8 can be found in `~/projects/test/tests`.
Any input file (say, one called `example_input.i`) can be run with the following
basic syntax:

```bash
~/projects/TMAP8/tmap8-opt -i example_input.i
```

Information about the simulation and its progress will then be displayed on the
screen. If a log file of the iterative solution process is also desired, the
console output can be sent to a text file:

```bash
~/projects/TMAP8/tmap8-opt -i example_input.i --color off 2>&1 | tee log.txt
```

!alert note
The `--color off` option is to de-clutter the log file from extraneous
mark-up resulting from the displayed console text colors.

Many test input files also create an output file with the name format
`example_input_out.e` that contains all the simulation results that have been
selected for output. These results are best viewed using a visualization tool
like [Paraview](http://www.paraview.org/download/).

## TMAP8 Tests, Verification and Validation Cases, and Examples

!style halign=left
In general the input files for verification, validation, and example cases located within the `test/tests` directory are meant
to be a showcase of "production" TMAP8 capability. Users are encouraged to start there
when learning to use TMAP8 and setting up new simulations. Documentation for the verification and validation
cases can be found [on the TMAP8 verification and validation page](verification_and_validation/index.md), and documentation for the example
cases can be found [on the TMAP8 example page](examples/tmap_index.md).

The `test/tests` directory holds *all* TMAP8 regression, verification, validation, and example
tests for both complete and in-progress capability. These files *should not* be modified,
so that periodic tests of TMAP8 function can be performed successfully. If modification of
tests, verification and validation cases, or examples is desired, their input files should be copied and run elsewhere.

As TMAP8 is developed and more capabilities are added, the tests directory will continue to
grow. If you feel that you have added important new functionality, please create a test for
it, such that any future changes will not break that capability.
