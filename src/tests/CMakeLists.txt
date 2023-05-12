cmake_minimum_required(VERSION 3.0)

find_package(GTest REQUIRED CONFIG)

file(GLOB_RECURSE UNIT_TEST_SOURCES "test_utility/*.cpp")
set(DEPENDENCIES cupoch_utility)

function(TEST module)
  if(NOT BUILD_cupoch_${module})
    message(STATUS "Skipping unit tests for ${module} because ${module} is not enabled")
    return()
  endif()
  file(GLOB_RECURSE TEST_SOURCES "${module}/*.cpp")
  set(UNIT_TEST_SOURCES ${UNIT_TEST_SOURCES} ${TEST_SOURCES} PARENT_SCOPE)
  set(DEPENDENCIES ${DEPENDENCIES} cupoch_${module} PARENT_SCOPE)
endfunction()

TEST(collision)
TEST(geometry)
TEST(integration)
TEST(io)
TEST(knn)
TEST(odometry)
TEST(planning)
TEST(registration)

add_executable(unittests ${UNIT_TEST_SOURCES})
add_definitions(-DTEST_DATA_DIR="${PROJECT_SOURCE_DIR}/examples/testdata")
target_link_libraries(unittests PRIVATE ${DEPENDENCIES} GTest::GTest GTest::Main)