//
//  UIImage+Adaptive.m
//  ProjectRefactoring
//
//  Created by 刘硕 on 2016/11/17.
//  Copyright © 2016年 刘硕. All rights reserved.
//

#import "UIImage+Adaptive.h"
#define IS_iPHONE4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960),[[UIScreen mainScreen] currentMode].size): NO)
#define IS_iPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136),[[UIScreen mainScreen] currentMode].size): NO)
#define IS_iPHONE6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334),[[UIScreen mainScreen] currentMode].size)): NO)
#define IS_iPHONE6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1242, 2208),[[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1125, 2001),[[UIScreen mainScreen] currentMode].size)): NO)
@implementation UIImage (Adaptive)

+ (instancetype)imageAdaptiveNamed:(NSString*)imagename {
    NSString *realImageName = imagename;
    //当前设备为iphone4/4S
    if (IS_iPHONE4) {
        realImageName = [NSString stringWithFormat:@"%@_iphone4",realImageName];
    }
    //当前设备为iphone5/5S
    if (IS_iPHONE5) {
        realImageName = [NSString stringWithFormat:@"%@_iphone5",realImageName];
    }
    //当前设备为iphone6/6S/7
    if (IS_iPHONE6) {
        realImageName = [NSString stringWithFormat:@"%@_iphone6",realImageName];
    }
    //当前设备为iphone6P/6SP/7P
    if (IS_iPHONE6P) {
        realImageName = [NSString stringWithFormat:@"%@_iphone6p",realImageName];
    }
    return [self imageNamed:realImageName];
}

@end
