/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2023 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TMAP8TestApp.h"
#include "MooseMain.h"

int
main(int argc, char * argv[])
{
  Moose::main<TMAP8TestApp>(argc, argv);

  return 0;
}
