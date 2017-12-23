//
//  开源：https://github.com/cyq1162/Sagit
//  作者：陈裕强 create on 2017/12/12.
//  博客：(昵称：路过秋天） http://www.cnblogs.com/cyq1162/
//  起源：IT恋、IT连 创业App http://www.itlinks.cn
//  Copyright © 2017-2027年. All rights reserved.
//

#import "STUIViewController.h"

@implementation UIViewController(ST)
-(UIViewController *)preController
{
    if(self.navigationController!=nil)
    {
        NSInteger count=self.navigationController.viewControllers.count;
        if(count>1)
        {
            return self.navigationController.viewControllers[count-2];
        }
    }
    return self;
}
- (UIViewController*)asRoot {
    
    return [self asRoot:RootViewDefaultType];
    //return;
    //    AppDelegate *delegate= (AppDelegate*)[UIApplication sharedApplication].delegate;
    //    delegate.window.rootViewController=rootController;
    
    
    //    typedef void (^Animation)(void);
    //    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    //
    //    rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    Animation animation = ^{
    //        BOOL oldState = [UIView areAnimationsEnabled];
    //        [UIView setAnimationsEnabled:NO];
    //        [UIApplication sharedApplication].keyWindow.rootViewController = rootViewController;
    //        [UIView setAnimationsEnabled:oldState];
    //    };
    //
    //    [UIView transitionWithView:window
    //                      duration:0.5f
    //                       options:UIViewAnimationOptionTransitionCrossDissolve
    //                    animations:animation
    //                    completion:nil];
}
//将当前视图设置为根视图
-(UIViewController*)asRoot:(RootViewControllerType)rootViewControllerType{
    
    UIViewController *controller=self;
    if(rootViewControllerType==RootViewNavigationType)
    {
        controller = [[UINavigationController alloc]initWithRootViewController:self];
        //self.navigationController.navigationBar.hidden=!self.view.needNavigationBar;
    }
    [UIApplication sharedApplication].delegate.window.rootViewController=controller;
    return self;
}
- (void)stPush:(UIViewController *)viewController title:(NSString *)title
{
    [self stPush:viewController title:title imgName:nil];
}
- (void)stPush:(UIViewController *)viewController title:(NSString *)title imgName:(NSString *)imgName
{
    // || ([NSString isNilOrEmpty:imgName] && [NSString isNilOrEmpty:title])
    if(self.navigationController==nil){return;}
    [self.view needNavigationBar:!self.navigationController.navigationBar.hidden];//存档最后的导航栏状态，用于检测是否还原。
    self.navigationController.navigationBar.hidden=NO;//显示返回导航工具条。
    self.navigationController.navigationBar.translucent=NO;//让默认View在导航工具条之下。
    
    if (self.navigationController.viewControllers.count != 0)
    {
        if (title)
        {
            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:viewController action:@selector(stPop)];
        }
        else if(imgName)
        {
            viewController.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithImage:STImage(imgName) style:UIBarButtonItemStyleDone target:viewController action:@selector(stPop)];
        }
        else
        {
            UIButton * btn=nil;
            if(![self.navigationController.navigationBar.lastSubView isKindOfClass:[UIButton class]])
            {
                //创一张空View 显示
                btn=[[UIButton alloc] initWithFrame:STRectMake(0, 0, 200, STNavHeightPx)];
                [btn backgroundColor:ColorClear];
                [self.navigationController.navigationBar addSubview:btn];
            }
            else
            {
                btn=(UIButton*)self.navigationController.navigationBar.lastSubView;
                [btn height:STNavHeightPx];//重设高度,在被pop这后，为了不影响其它自定义，高度会被置为0
            }
            
            //移除事件，避免target指向一个旧的viewController
            [btn removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
            [btn addTarget:viewController action:@selector(stPop) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
//    if([self isKindOfClass:[STController class]])//因为STController可以拦截系统滑动返回的事件做进一步处理，所以打开交互
//    {
        //打开右滑返回交互。 (已通过重写NavigationController扩展处理了)
        self.navigationController.interactivePopGestureRecognizer.delegate=(id)self.navigationController;
    //}
    [self.navigationController pushViewController:viewController animated:YES];
    //return self;
}

- (void)stPop {
    if(self.navigationController!=nil)
    {
        
        //如果上级就是根视图，就隐藏，否则仍显示
        if(self.navigationController.viewControllers.count==2)
        {
            
//            if(![self.navigationController.viewControllers[0].view needNavigationBar])
//            {
                self.navigationController.navigationBar.hidden=![self.navigationController.viewControllers[0].view needNavigationBar];
            //}
            //显示返回导航工具条，如果是滑动的话，View会自动归位，但自定义事件返回，不归位（所以在自定义事件中也设置一下次）
        }
        [self.navigationController popViewControllerAnimated:YES];
//        if(![self isKindOfClass:[STController class]])//如果不是STController
//        {
//            //右滑已禁止的情况下，在这里设置状态。
//            [self setStateAfterSTPop];
//        }
    }
   // return self;
}
//-(void)setStateAfterSTPop
//{
//    if(self.navigationController!=nil)
//    {
////        if([self.navigationController.navigationBar.lastSubView isKindOfClass:[UIButton class]])
////        {
////            [self.navigationController.navigationBar.lastSubView height:0];//取消自定义复盖的UIButton
////        }
////        //如果上级就是根视图，就隐藏，否则仍显示
////        if(self.navigationController.viewControllers.count==1)
////        {
////            self.navigationController.navigationBar.hidden=YES;//显示返回导航工具条。
////        }
//    }
//}
/*
 NewsController *NewsViewC                     = [[NewsController alloc]init];
 NewsViewC.tabBarItem.title                    = @"消息";
 
 NewsViewC.tabBarItem.image                    = STImageOriginal(@"menu_icon_3_normal-");// imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
 NewsViewC.tabBarItem.selectedImage            = STImageOriginal(@"menu_icon_3_selected");// imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
 UINavigationController *nav3                  = [[UINavigationController alloc]initWithRootViewController:NewsViewC];
 */
#pragma mark 共用接口
//子类重写
-(void)reloadData{}
-(void)reloadData:(NSString*)para{}
#pragma mark for TabBar 属性扩展
-(UIViewController*)tabTitle:(NSString*)title
{
    self.tabBarItem.title=title;
    return self;
}
-(UIViewController*)tabImage:(NSString*)imgName
{
    self.tabBarItem.image=STImageOriginal(imgName);
    return self;
}
-(UIViewController*)tabSelectedImage:(NSString*)imgName
{
    self.tabBarItem.selectedImage=STImageOriginal(imgName);
    return self;
}
-(UIViewController*)tabBadgeValue:(NSString*)value
{
    self.tabBarItem.badgeValue=value;
    return self;
}
-(UIViewController*)tabBadgeColor:(id)colorOrHex
{
    self.tabBarItem.badgeColor=[self.view toColor:colorOrHex];
    return self;
}
-(UINavigationController*)toUINavigationController
{
    if(self.navigationController!=nil){return self.navigationController;}
    return [[UINavigationController alloc]initWithRootViewController:self];
}
@end
