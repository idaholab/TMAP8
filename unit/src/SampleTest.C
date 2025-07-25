/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "gtest/gtest.h"

TEST(MySampleTests, descriptiveTestName)
{
  // compare equality
  EXPECT_EQ(2, 1 + 1);
  EXPECT_DOUBLE_EQ(2 * 3.5, 1.0 * 8 - 1);

  // compare equality and immediately terminate this test if it fails
  // ASSERT_EQ(2, 1);

  // this won't run if you uncomment the above test because above assert will fail
  ASSERT_NO_THROW(1 + 1);

  // for a complete list of assertions and for more unit testing documentation see:
  // https://github.com/google/googletest/blob/master/googletest/docs/Primer.md
}

TEST(MySampleTests, anotherTest)
{
  EXPECT_LE(1, 2);
  // ...
}
