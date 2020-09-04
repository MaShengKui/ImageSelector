//
//  MainViewController.m
//  ImageSelector
//
//  Created by mask on 16/6/24.
//  Copyright © 2016年 mask. All rights reserved.
//

#import "MainViewController.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

#define rgb(a,b,c) [UIColor colorWithRed:(a)/255.0f green:(b)/255.0f blue:(c)/255.0f alpha:1]

// placeholder
#define kTipString @"请输入您的想要说的话"

// 最多可输入文字个数
#define MAX_TEXT_NUMBER 255

// 最多上传图片个数
#define MAX_IMAGE_NUMBER 9

// 用于记录放大之前的frame
static CGRect oldframe;

@interface MainViewController () <UITextViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate>

/// 获取到button上显示的图片
@property (nonatomic,strong) UIImage *uploadImage;

/// 用来替换原来位置的图片
@property (nonatomic,strong) UIImage *replaceImage;

/// 用于捏合放大与缩小的scrollView
@property (nonatomic,strong) UIScrollView *imgScrollView;

/// 显示图片的按钮
@property (nonatomic,strong) UIButton *imgButton;

@end

@implementation MainViewController
{
    UIView *_showImgView; // textView下面的选取图片的区域
    
    NSMutableArray *_imagesArray; // 图片数组
    
    CATransition *_animation; // 动画
    
    BOOL _isReplace; // 判断是否需要替换
    
    NSInteger _replaceIndex; // 替换的位置索引
    
    CGFloat _scaleNum; // 图片放大倍数，初始值为1，即保持原图效果
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    _imagesArray = [[NSMutableArray alloc] initWithCapacity:0];
    _showImgView = [[UIView alloc] initWithFrame:CGRectMake(0, 170, WIDTH, 30 + 90)];
    _showImgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_showImgView];
    
    // 设置代理
    self.textView.delegate = self;
    
    //布局图片选取区域
    [self loadImageShowOnView];
    
    // 添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewEndEditingFuncAction:)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - 结束编辑
- (void)textViewEndEditingFuncAction:(UIGestureRecognizer *)tap {
    [self.view endEditing:YES];
}

#pragma mark - 布局图片选取区域
- (void)loadImageShowOnView {
    // 移除showImgView中所有的子控件
    for (UIView *sView in _showImgView.subviews) {
        [sView removeFromSuperview];
    }
    
    // 创建图片选择区域
    UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 170, 20)];
    tipsLab.text = @"图片附件";
    tipsLab.textColor = rgb(153, 153, 153);
    tipsLab.font = [UIFont systemFontOfSize:15];
    [_showImgView addSubview:tipsLab];
    
    
    NSInteger counts = _imagesArray.count + 1, rowCounts = 3; // 每列3个
    NSInteger rows = counts%rowCounts == 0 ?(counts/rowCounts):(counts/rowCounts + 1); // 行索引
    
    _showImgView.frame = CGRectMake(0, 170, WIDTH, 40+rows * 90);
    self.contentView.frame = CGRectMake(0, 0, WIDTH, 170 + 40 + rows * 90);
    self.bgScrollView.contentSize = CGSizeMake(WIDTH, 170 + 40 + rows * 90);
    
    // 利用切割函数进行布局
    CGRect aRect,bRect, cRect = CGRectMake(0, 30, WIDTH, MAXFLOAT);
    
    for (int i = 0; i < rows; i++) {
        
        CGRectDivide(cRect, &aRect, &cRect, 90, CGRectMinYEdge);
        CGFloat width = aRect.size.width/rowCounts;
        
        for (int n = 0; n < rowCounts; n++) {
            NSInteger countIndex =  (i * rowCounts + n);
            if (countIndex >= counts) {
                continue;
            }
            
            CGRectDivide(aRect, &bRect, &aRect, width, CGRectMinXEdge);
            bRect = UIEdgeInsetsInsetRect(bRect, UIEdgeInsetsMake(0, (bRect.size.width - 80) / 2, 10, (bRect.size.width - 80) / 2));
            
            // 选择按钮
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = bRect;
            [button setImage:[UIImage imageNamed:@"tianjia"] forState:UIControlStateNormal];
            [button setBackgroundColor:rgb(153, 153, 153)];
            button.tag = countIndex;
            button.exclusiveTouch=YES;
            [_showImgView addSubview:button];
            
            if (countIndex == counts - 1) {
                [button addTarget:self action:@selector(uploadFileClickAction:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                button.tag = (3 * i + n);
                button.backgroundColor = [UIColor clearColor];
                [button addTarget:self action:@selector(changeImageClickAction:) forControlEvents:UIControlEventTouchUpInside];
                [button setImage:[_imagesArray objectAtIndex:countIndex] forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - 对添加的图片进行编辑操作：放大、替换、删除
- (void)changeImageClickAction:(id)sender {
    self.imgButton = (UIButton *)sender;
    _isReplace = NO;
    if (self.imgButton.imageView.image != nil) {
        _replaceIndex = self.imgButton.tag;
        self.uploadImage = self.imgButton.imageView.image;
        [self editImage:nil];
    }
}

#pragma mark - 放大当前图片--重写父类方法
- (void)enlargeUploadImage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self enlargeUploadImage:self.imgButton];
    });
}

// 放大图片
- (void)enlargeUploadImage:(UIButton *)button {
    // 放大倍数初始值为1，即显示原图
    _scaleNum = 1;
    // 隐藏状态栏
    [UIApplication sharedApplication].statusBarHidden=YES;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe = [button convertRect:button.bounds toView:_showImgView];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0;
    
    // 添加捏合手势，放大与缩小图片
    self.imgScrollView = [[UIScrollView alloc]initWithFrame:backgroundView.bounds];
    [self.imgScrollView addSubview:button];
    
    // 设置UIScrollView的滚动范围和图片的真实尺寸一致
    self.imgScrollView.contentSize = button.frame.size;
    // 设置代理scrollview的代理对象
    self.imgScrollView.delegate = self;
    
    // 设置实现缩放
    // 设置最大伸缩比例
    self.imgScrollView.maximumZoomScale = 3;
    // 设置最小伸缩比例
    self.imgScrollView.minimumZoomScale = 1;
    [self.imgScrollView setZoomScale:1 animated:NO];
    
    self.imgScrollView.scrollsToTop = NO;
    self.imgScrollView.scrollEnabled = YES;
    self.imgScrollView.showsHorizontalScrollIndicator = NO;
    self.imgScrollView.showsVerticalScrollIndicator = NO;
    
    [backgroundView addSubview:self.imgScrollView];
    [window addSubview:backgroundView];
    
    //单击手势
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired  = 1;
    [backgroundView addGestureRecognizer:singleTapGesture];
    
    //双击手势
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    [backgroundView addGestureRecognizer:doubleTapGesture];
    
    // 当检测双击手势失败之后响应单击手势
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    // 保持原图高度
    CGFloat originImageHeight = [self imageCompressForWidth:button.imageView.image targetWidth:WIDTH].size.height;
    if (originImageHeight >= HEIGHT) {
        originImageHeight = (HEIGHT - 20 - 55);
    }
    [UIView animateWithDuration:0.3 animations:^{
        button.frame = CGRectMake(0, (HEIGHT - originImageHeight) * 0.5, self.view.frame.size.width, originImageHeight);
        backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        button.userInteractionEnabled = NO;
    }];
    
    [self loadImageShowOnView];
}

#pragma mark - 还原图片
- (void)hideImage:(UITapGestureRecognizer*)tap {
    UIView *backgroundView = tap.view;
    _animation = [CATransition animation];
    _animation.duration = 0.3;
    _animation.timingFunction = UIViewAnimationCurveEaseInOut;
    _animation.fillMode = kCAFillModeForwards;
    _animation.type = kCATransitionFade;
    backgroundView.alpha = 0;
    [backgroundView.layer addAnimation:_animation forKey:@"animation"];
    self.imgButton.frame = oldframe;
    [_showImgView addSubview:self.imgButton];
    self.imgButton.userInteractionEnabled = YES;
    // 恢复显示状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - 处理单击手势
- (void)handleSingleTap:(UIGestureRecognizer *)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    [self hideImage:tap];
}

#pragma mark - 处理双击手势
- (void)handleDoubleTap:(UIGestureRecognizer *)sender {
    if (_scaleNum >= 1 && _scaleNum <= 2) {
        _scaleNum++;
    } else {
        _scaleNum = 1;
    }
    [self.imgScrollView setZoomScale:_scaleNum animated:YES];
}

#pragma mark - 替换当前图片--重写父类方法
- (void)replaceUploadImage {
    _isReplace = YES;
    //替换图片
    [self selectImage:nil];
}

#pragma mark - 删除当前图片--重写父类方法
- (void)removeUploadImage {
    //删除图片
    [_imagesArray removeObject:self.uploadImage];
    [self loadImageShowOnView];
}

#pragma mark - 添加图片
- (void)uploadFileClickAction:(id)sender {
    _isReplace = NO;
    [self.view endEditing:YES];
    if (_imagesArray.count >= MAX_IMAGE_NUMBER) {
        // alert提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:[NSString stringWithFormat:@"最多只能上传%d张图片", MAX_IMAGE_NUMBER]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    UIButton *btn = (UIButton*)sender;
    if (btn.tag >= _imagesArray.count) {
        [self selectImage:nil];
    }
}

#pragma mark - VPImageCropperDelegate 剪裁图片完成
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        //如果是替换的话，直接替换掉原图片,否则作为新元素加入到数组中
        if (_isReplace) {
            self.replaceImage = editedImage;
            [_imagesArray replaceObjectAtIndex:_replaceIndex withObject:self.replaceImage];
        } else {
            [_imagesArray addObject:editedImage];
        }
        [self loadImageShowOnView];
    }];
}

#pragma mark - UIScrollViewDelegate
#pragma mark 告诉imgScrollview要缩放的是哪个子控件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgButton;
}

#pragma mark 等比例放大，让放大的视图保持在imgScrollView的中央
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (self.imgScrollView.bounds.size.width > self.imgScrollView.contentSize.width) ? (self.imgScrollView.bounds.size.width - self.imgScrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.imgScrollView.bounds.size.height > self.imgScrollView.contentSize.height) ?
    (self.imgScrollView.bounds.size.height - self.imgScrollView.contentSize.height) * 0.5 : 0.0;
    self.imgButton.center = CGPointMake(self.imgScrollView.contentSize.width * 0.5 + offsetX,self.imgScrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - UITextViewDelegate 用于实现placeholder的效果
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:kTipString]) {
        textView.text = @"";
        textView.textColor = rgb(153, 153, 153);
    }
    textView.textColor = rgb(51, 51, 51);
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length < 1) {
        textView.text = kTipString;
        textView.textColor = rgb(153, 153, 153);
    } else {
        textView.textColor = rgb(51, 51, 51);
    }
}

#pragma mark - 限制输入字数(最多不超过255个字)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //不支持系统表情的输入
    if ([[textView textInputMode] primaryLanguage] == nil || [[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"]) {
        return NO;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_TEXT_NUMBER) {
            return YES;
        } else {
            return NO;
        }
    }
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger caninputlen = (MAX_TEXT_NUMBER - comcatstr.length);
    
    if (caninputlen >= 0) {
        return YES;
    } else {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        if (rg.length > 0){
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                //因为是ascii码直接取就可以了不会错
                s = [text substringWithRange:rg];
            } else {
                __block NSInteger idx = 0;
                //截取出的字串
                __block NSString  *trimString = @"";
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                    
                    if (idx >= rg.length) {
                        //取出所需要就break，提高效率
                        *stop = YES;
                        return ;
                    }
                    trimString = [trimString stringByAppendingString:substring];
                    idx++;
                }];
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            //既然是超出部分截取了，那一定是最大限制了。
            self.textNumLab.text = [NSString stringWithFormat:@"%d/%ld",0,(long)MAX_TEXT_NUMBER];
        }
        return NO;
    }
}

#pragma mark - 显示当前可输入字数/总字数
- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    if (existTextNum > MAX_TEXT_NUMBER) {
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *s = [nsTextContent substringToIndex:MAX_TEXT_NUMBER];
        [textView setText:s];
    }
    //不让显示负数
    self.textNumLab.text = [NSString stringWithFormat:@"%ld/%d", MAX(0,MAX_TEXT_NUMBER - existTextNum), MAX_TEXT_NUMBER];
}

#pragma mark - 工具方法
#pragma mark - 指定宽度按比例缩放图片
- (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, size) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if (newImage == nil) {
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}

@end
