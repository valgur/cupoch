#pragma once

#include <thrust/pair.h>

#include <Eigen/Core>

#include "cupoch/utility/ijson_convertible.h"

namespace cupoch {
namespace camera {

/// \enum PinholeCameraIntrinsicParameters
///
/// \brief Sets default camera intrinsic parameters for sensors.
enum class PinholeCameraIntrinsicParameters {
    /// Default settings for PrimeSense camera sensor.
    PrimeSenseDefault = 0,
    /// Default settings for Kinect2 depth camera.
    Kinect2DepthCameraDefault = 1,
    /// Default settings for Kinect2 color camera.
    Kinect2ColorCameraDefault = 2,
};

/// \class PinholeCameraIntrinsic
///
/// \brief Contains the pinhole camera intrinsic parameters.
class PinholeCameraIntrinsic : public utility::IJsonConvertible {
public:
    /// \brief Default Constructor.
    PinholeCameraIntrinsic();
    /// \brief Parameterized Constructor.
    ///
    /// \param PinholeCameraIntrinsicParameters - Sets the camera parameters to
    /// the default settings of one of the sensors.
    PinholeCameraIntrinsic(PinholeCameraIntrinsicParameters);
    /// \brief Parameterized Constructor.
    ///
    /// \param width width of the image.
    /// \param height height of the image.
    /// \param fx focal length along the X-axis.
    /// \param fy focal length along the Y-axis.
    /// \param cx principal point of the X-axis.
    /// \param cy principal point of the Y-axis.
    PinholeCameraIntrinsic(
            int width, int height, float fx, float fy, float cx, float cy);
    ~PinholeCameraIntrinsic() override;

public:
    /// \brief Set camera intrinsic parameters.
    ///
    /// \param width - width of the image.
    /// \param height - height of the image.
    /// \param fx - focal length along the X-axis.
    /// \param fy - focal length along the Y-axis.
    /// \param cx - principal point of the X-axis.
    /// \param cy - principal point of the Y-axis.
    void SetIntrinsics(
            int width, int height, float fx, float fy, float cx, float cy) {
        width_ = width;
        height_ = height;
        intrinsic_matrix_.setIdentity();
        intrinsic_matrix_(0, 0) = fx;
        intrinsic_matrix_(1, 1) = fy;
        intrinsic_matrix_(0, 2) = cx;
        intrinsic_matrix_(1, 2) = cy;
    }

    /// Returns the focal length in a tuple of X-axis and Y-axis focal lengths.
    thrust::pair<float, float> GetFocalLength() const {
        return thrust::make_pair(intrinsic_matrix_(0, 0),
                                 intrinsic_matrix_(1, 1));
    }

    /// Returns the principle point in a tuple of X-axis and Y-axis principle
    /// point.
    thrust::pair<float, float> GetPrincipalPoint() const {
        return thrust::make_pair(intrinsic_matrix_(0, 2),
                                 intrinsic_matrix_(1, 2));
    }

    /// Returns the skew.
    float GetSkew() const { return intrinsic_matrix_(0, 1); }

    /// Returns `true` iff both the width and height are greater than 0.
    bool IsValid() const { return (width_ > 0 && height_ > 0); }

    bool ConvertToJsonValue(Json::Value &value) const override;
    bool ConvertFromJsonValue(const Json::Value &value) override;

public:
    /// Width of the image.
    int width_ = -1;
    /// Height of the image.
    int height_ = -1;
    /// 3x3 matrix. \n
    /// Intrinsic camera matrix:\n
    ///``[[fx, 0, cx],``\n
    ///`` [0, fy, cy],``\n
    ///`` [0, 0, 1]]``
    Eigen::Matrix3f intrinsic_matrix_;
};
}  // namespace camera
}  // namespace cupoch