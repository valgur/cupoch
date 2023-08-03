#include <cupoch/geometry/image.h>
#include <cupoch/imageproc/sgm.h>
#include <cupoch/io/class_io/image_io.h>

using namespace cupoch;

void testSGM() {
    auto limg = io::CreateImageFromFile("../../testdata/left.png")->CreateGrayImage();
    auto rimg = io::CreateImageFromFile("../../testdata/right.png")->CreateGrayImage();
    imageproc::SGMOption params(limg->width_, limg->height_);
    imageproc::SemiGlobalMatching sgm(params);
    auto disp = sgm.ProcessFrame(*limg, *rimg);
    disp->LinearTransform(255.0 / 127.0);
}

int main() {
    // Only testing that the code compiles and links.
    return 0;
}
