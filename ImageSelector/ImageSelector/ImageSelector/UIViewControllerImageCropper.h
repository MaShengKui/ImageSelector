//
//  UIViewControllerImageCropper.h
//  ImageSelector
//
//  Created by mask on 16/6/24.
//  Copyright © 2016年 mask. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface UIViewControllerImageCropper : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>

@property(nonatomic,strong)UIView *grayView;

/// 拍照、从相册中选取
- (void)selectImage:(id)sender;

/// 修改已选图片
- (void)editImage:(id)sender;

/// 放大图片
- (void)enlargeUploadImage;

/// 替换图片
- (void)replaceUploadImage;

/// 删除图片
- (void)removeUploadImage;


#pragma mark Camera Utility

- (BOOL)isCameraAvailable;

- (BOOL)doesCameraSupportTakingPhotos;

- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType
                  sourceType:(UIImagePickerControllerSourceType)paramSourceType;

- (BOOL)isRearCameraAvailable;

- (BOOL)isFrontCameraAvailable;

- (BOOL)isPhotoLibraryAvailable;

- (void)showAlertContentViewOnKeyWindow:(UIView *)alertView;

- (void)hideAlertContentViewOnKeyWindow;


@end
