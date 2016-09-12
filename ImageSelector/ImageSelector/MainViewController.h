//
//  MainViewController.h
//  ImageSelector
//
//  Created by msk on 16/6/24.
//  Copyright © 2016年 msk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerImageCropper.h"
@interface MainViewController : UIViewControllerImageCropper
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;//背景scrollView，用于页面滑动
@property (weak, nonatomic) IBOutlet UIView *contentView;//内容视图
@property (weak, nonatomic) IBOutlet UIView *topView;//页面上部分
@property (weak, nonatomic) IBOutlet UITextView *textView;//文字编辑区域
@property (weak, nonatomic) IBOutlet UILabel *textNumLab;//文字限制lab

@end
