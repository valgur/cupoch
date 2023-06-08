#include <libsgm.h>

#include <cstdlib>
#include <iostream>

int main() {
    sgm::StereoSGM sgmsgm_(128, 128, 64, 8, 8, sgm::EXECUTE_INOUT_CUDA2CUDA,
                           {});
    return EXIT_SUCCESS;
}
