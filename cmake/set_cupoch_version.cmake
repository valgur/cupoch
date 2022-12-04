# central location for specifying the Cupoch version
file(STRINGS "${CMAKE_SOURCE_DIR}/src/cupoch/version.txt" CUPOCH_VERSION_READ)
foreach (ver ${CUPOCH_VERSION_READ})
    if (ver MATCHES "CUPOCH_VERSION_(MAJOR|MINOR|PATCH|TWEAK) +([^ ]+)$")
        set(CUPOCH_VERSION_${CMAKE_MATCH_1} "${CMAKE_MATCH_2}" CACHE INTERNAL "")
    endif ()
endforeach ()
string(CONCAT CUPOCH_VERSION "${CUPOCH_VERSION_MAJOR}"
        ".${CUPOCH_VERSION_MINOR}"
        ".${CUPOCH_VERSION_PATCH}"
        ".${CUPOCH_VERSION_TWEAK}")
# npm version has to be MAJOR.MINOR.PATCH
string(CONCAT PROJECT_VERSION_THREE_NUMBER "${CUPOCH_VERSION_MAJOR}"
        ".${CUPOCH_VERSION_MINOR}"
        ".${CUPOCH_VERSION_PATCH}")
message(STATUS "cupoch ${CUPOCH_VERSION}")
