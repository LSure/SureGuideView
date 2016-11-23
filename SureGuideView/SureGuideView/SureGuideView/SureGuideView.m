//
//  SureGuideView.m
//  ProjectRefactoring
//
//  Created by 刘硕 on 2016/11/17.
//  Copyright © 2016年 刘硕. All rights reserved.
//

#import "SureGuideView.h"
#import "UIImage+Adaptive.h"
#import "AppDelegate.h"
NSString *const SureShouldShowGuide = @"SureShouldShowGuide";
@interface SureGuideView ()
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) NSInteger imageCount;
@end
@implementation SureGuideView

+ (instancetype)sureGuideViewWithImageName:(NSString*)imageName
                                imageCount:(NSInteger)imageCount{
    return [[self alloc]initWithImageName:imageName imageCount:imageCount];
}

- (instancetype)initWithImageName:(NSString*)imageName
                       imageCount:(NSInteger)imageCount{
    if (self = [super init]) {
        _imageName = imageName;
        _imageCount = imageCount;
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    if (_imageCount) {
        for (NSInteger i = 0; i < _imageCount; i++) {
            NSString *realImageName = [NSString stringWithFormat:@"%@_%ld",_imageName,i + 1];
            UIImage *image = [UIImage imageAdaptiveNamed:realImageName];
            UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
            imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            imageView.userInteractionEnabled = YES;
            imageView.tag = 1000 + i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchImageView:)];
            [imageView addGestureRecognizer:tap];
            [self addSubview:imageView];
        }
    }
    [self show];
}

- (void)touchImageView:(UITapGestureRecognizer*)tap {
    UIImageView *tapImageView = (UIImageView*)tap.view;
    //依次移除
    [tapImageView removeFromSuperview];
    if (tapImageView.tag - 1000 == 0) {
        //最后一张
        if (self.lastTapBlock) {
            self.lastTapBlock();
        }
        [self hide];
    }
}

- (void)show {
    [UIApplication sharedApplication].statusBarHidden = YES;
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDel.window addSubview:self];
}

- (void)hide {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self removeFromSuperview];
}

+ (BOOL)shouldShowGuider {
    NSNumber *number = [[NSUserDefaults standardUserDefaults]objectForKey:SureShouldShowGuide];
    if ([number isEqual:@200]) {
        return NO;
    } else {
        [[NSUserDefaults standardUserDefaults]setObject:@200 forKey:SureShouldShowGuide];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return YES;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
