file(GLOB_RECURSE IMAGEPROC_SOURCE_FILES "*.cpp")
add_library(cupoch_imageproc ${IMAGEPROC_SOURCE_FILES})
target_link_libraries(cupoch_imageproc
    PUBLIC
        cupoch_geometry
        sgm::sgm
    PRIVATE
        cupoch_utility
)
