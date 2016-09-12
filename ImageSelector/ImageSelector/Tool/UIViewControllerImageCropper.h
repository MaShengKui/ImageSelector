//
//  UIViewControllerImageCropper.h
//  ImageSelector
//
//  Created by msk on 16/6/24.
//  Copyright © 2016年 msk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface UIViewControllerImageCropper : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>

@property(nonatomic,strong)UIView *grayView;

-(void)actionSheetShow:(id)sender;//第一种ActionSheet弹出样式
-(void)actionSheetShowAgain:(id)sender;//第二种ActionSheet弹出样式
-(void)enlargeUploadImage;//放大图片
-(void)replaceUploadImage;//替换图片
-(void)removeUploadImage;//删除图片


#pragma mark camera utility
- (BOOL) isCameraAvailable;

- (BOOL) doesCameraSupportTakingPhotos;

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;

- (BOOL) isRearCameraAvailable;

- (BOOL) isFrontCameraAvailable;

- (BOOL) isPhotoLibraryAvailable;

-(void)showAlertContentViewOnKeyWindow:(UIView*)alertView;
-(void)hideAlertContentViewOnKeyWindow;


@end
