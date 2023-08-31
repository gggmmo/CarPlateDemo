//
//  OpenCVWrapper.m
//  CarPlateDemo
//
//  Created on 17/8/2023.
//


#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"

#pragma clang pop
#endif

#import "UIImage+Blur.h"

using namespace std;
using namespace cv;

#pragma mark - Private Declarations

@interface OpenCVWrapper ()

#ifdef __cplusplus

+ (Mat)_grayFrom:(Mat)source;
+ (Mat)_matFrom:(UIImage *)source;
+ (UIImage *)_imageFrom:(Mat)source;

#endif

@end

#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public

+ (UIImage *)toBlur:(UIImage *)source {
    CGRect rect = [OpenCVWrapper _rectFrom:[self _matFrom:source]];
    if (CGRectEqualToRect(rect, CGRectNull)) {
        return source;
    } else {
        UIImage *cropped = [[self _croppIngimageByImageName:source toRect:rect] applyBlurWithRadius:10 tintColor:[UIColor clearColor] saturationDeltaFactor:1.8 maskImage:nil];
        
        UIGraphicsBeginImageContextWithOptions(source.size, false, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [source drawAtPoint:CGPointZero];

        CGPoint pointImg2 = rect.origin;
        [cropped drawAtPoint: pointImg2];

        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}

+ (UIImage *)_croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

#pragma mark Private
struct by_areaDsc {
    bool operator()(vector<cv::Point> const &a, vector<cv::Point> const &b) const {
        return contourArea(a ,false) > contourArea(b ,false);
    }
};


+ (CGRect)_rectFrom:(Mat)source {
    Mat gray;
    cvtColor(source, gray, COLOR_BGR2GRAY);
    
    Mat bilateral;
    bilateralFilter(gray, bilateral, 11, 17, 17);
    
    Mat blur;
    GaussianBlur(bilateral, blur, cv::Size(5, 5), 0);
    
    Mat canny;
    Canny(blur, canny, 170, 250);
    
    
    Mat plateImg;
    NSMutableArray<UIImage *> *images = [NSMutableArray array];
    vector<vector<cv::Point>> contours;
    findContours(canny, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    std::sort(contours.begin(), contours.end(), by_areaDsc());
    
    vector<cv::Point> rectangleContours[30];
    for( int i = 0; i < contours.size(); i++ )
    {
        Mat contour = (Mat)contours[i];
        vector<cv::Point> approxCurve;
        approxPolyDP(contour, approxCurve, 0.02 * arcLength(contour, true), true);
        if (approxCurve.size() == 4) {
            cout << "\n|| approxCurve: " << approxCurve;
            cv::Rect rect = boundingRect(approxCurve);
            cout << "\n|| rect: " << rect;
            if ( rect.height >=5 && rect.width >= 5) {
                return CGRectMake(rect.x, rect.y, rect.width, rect.height);
            }
        }
    }

    return CGRectNull;
}

+ (Mat)_findContoursFrom:(Mat)source {
    cout << "-> findContoursFrom ->";
    
    Mat result;
    findContours(source, result, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    
    return result;
}

+ (Mat)_matFrom:(UIImage *)source {
    cout << "matFrom ->";
    
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    
    return result;
}

+ (UIImage *)_imageFrom:(Mat)source {
    cout << "\n-> imageFrom\n";
    
    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = source.step[0];
    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
    
    CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return result;
}

@end
