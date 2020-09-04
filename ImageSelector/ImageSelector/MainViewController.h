//
//  MainViewController.h
//  ImageSelector
//
//  Created by mask on 16/6/24.
//  Copyright © 2016年 mask. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerImageCropper.h"

@interface MainViewController : UIViewControllerImageCropper

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

/// 背景scrollView，用于页面滑动
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;

/// 内容视图
@property (weak, nonatomic) IBOutlet UIView *contentView;

/// 页面上部分
@property (weak, nonatomic) IBOutlet UIView *topView;

/// 文字编辑区域
@property (weak, nonatomic) IBOutlet UITextView *textView;

/// 文字限制label
@property (weak, nonatomic) IBOutlet UILabel *textNumLab;

@end
