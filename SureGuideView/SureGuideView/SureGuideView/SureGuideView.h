//
//  SureGuideView.h
//  ProjectRefactoring
//
//  Created by 刘硕 on 2016/11/17.
//  Copyright © 2016年 刘硕. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const SureShouldShowGuide;

@interface SureGuideView : UIView

@property (nonatomic, copy) void(^lastTapBlock)(void);

+ (instancetype)sureGuideViewWithImageName:(NSString*)imageName
                                imageCount:(NSInteger)imageCount;

+ (BOOL)shouldShowGuider;

- (void)show;

@end
