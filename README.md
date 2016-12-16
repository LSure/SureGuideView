# SureGuideView
######内容源由
每当项目更新，对于新功能的使用通常会给予用户以蒙版引导提示。

为避免繁琐无用的操作，可将该功能模块进行封装。下面分享自己封装流程，可作为[自定义控件封装思路](http://www.jianshu.com/p/53895b673038)的后续，旨在帮助封装程度较低的朋友们。

![引导示例，图来自网络.png](http://upload-images.jianshu.io/upload_images/1767950-508c0f5d9bb27dcb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

考虑需求，为了更方便处理，引导图的命名通常具有一定规则，例如：guide_1、guide_2等，但因需要屏幕适配，设计会依次提供3.5、4、4.7、5.5寸的效果图，也就是说每张图片需要对应四种屏幕尺寸。所以在真实的项目开发中，需要适配的图片命名通常为guide_1_iphone5、guide_1_iphone6、guide_1_iphone6p等。

对于此需求我们可以为UIImage添加类别，当```UIImage```调用```imageAdaptiveNamed```方法时对应添加设备标示，代码如下：
```
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
```
对于设备的判断推荐使用**[UIDevice currentDevice].mode**，比如
```
#define IS_iPHONE6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334),[[UIScreen mainScreen] currentMode].size)): NO)
```
接下来创建继承于UIView的自定义类，这里希望外漏方法，使调用该方法的程序员只需传递引导蒙版图片的通用名字和图片个数即可。

首先想到的是这样的一个方法，在自定义View的init基础上进行扩展参数，如下：
```
- (instancetype)initWithImageName:(NSString*)imageName
                       imageCount:(NSInteger)imageCount；
```
但是还不够好，对应自定义类要让调用的人使用起来更简洁，因此我们会将此方法转化为类方法
```
+ (instancetype)sureGuideViewWithImageName:(NSString*)imageName
                                imageCount:(NSInteger)imageCount;
```
对应的实现如下，这里为了图片通用名称与图片个数可全局使用，因此声明为属性。
```
//蒙版图片通用名称，如guide
@property (nonatomic, copy) NSString *imageName;
//蒙版图片个数
@property (nonatomic, assign) NSInteger imageCount;
```
```
//需外漏的方法
+ (instancetype)sureGuideViewWithImageName:(NSString*)imageName
                                imageCount:(NSInteger)imageCount{
    return [[self alloc]initWithImageName:imageName imageCount:imageCount];
}
//初始化操作
- (instancetype)initWithImageName:(NSString*)imageName
                       imageCount:(NSInteger)imageCount{
    if (self = [super init]) {
        _imageName = imageName;
        _imageCount = imageCount;
        [self createUI];
    }
    return self;
}
```
接下来即为将对应的图片创建即可。
```
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
            [self addSubview:imageView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchImageView:)];
            [imageView addGestureRecognizer:tap];
        }
    }
    [self show];
}
```
经过如上操作，即可将所传入的蒙版图片通用名称进行更改，例如guide->guide_1_iphone6等，若需在最后一张点击后进行事件处理，可以通过Block或代理进行回调。
```
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
```
最后即为控制其显隐性的问题了，对于引导界面，通常是加载到UIWindow上，而非视图控制器，分别声明show与hide方法。
```
//显示
- (void)show {
    [UIApplication sharedApplication].statusBarHidden = YES;
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDel.window addSubview:self];
}
```
```
//隐藏
- (void)hide {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self removeFromSuperview];
}
```
对于引导蒙版的显示，通常为用户第一次进入App显示，因此我们可以简单的通过```NSUserDefaults ```实现该操作。
分别在.h.m中外漏参数
```
//.h
extern NSString *const SureShouldShowGuide;
//.m
NSString *const SureShouldShowGuide = @"SureShouldShowGuide";
```
这一点可以在[为什么要尽量避免使用宏定义](http://www.jianshu.com/p/81f83934ea83)中得知，也是方便其他人快速上手的原因。
```
//是否显示引导页面
+ (BOOL)shouldShowGuider {
    NSNumber *number = [[NSUserDefaults standardUserDefaults]objectForKey:SureShouldShowGuide];
    if ([number isEqual:@200]) {//若有值存在，不显示
        return NO;
    } else {//值不存在，显示并赋值
        [[NSUserDefaults standardUserDefaults]setObject:@200 forKey:SureShouldShowGuide];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return YES;
    }
}
```
至此，我们所需要的蒙版引导页面封装完毕。调用也十分简洁：
```
//判断是否显示引导页面
if ([SureGuideView shouldShowGuider]) {
    //展示
    [SureGuideView sureGuideViewWithImageName:@"guide" imageCount:3];
}
```
此例较基础，但作为封装思路的理解还是有所益处的，希望对大家有所帮助！

######demo下载链接
[一劳永逸，iOS引导蒙版封装流程demo🔗](https://github.com/LSure/SureGuideView)
