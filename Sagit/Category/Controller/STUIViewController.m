//
//  开源：https://github.com/cyq1162/Sagit
//  作者：陈裕强 create on 2017/12/12.
//  博客：(昵称：路过秋天） http://www.cnblogs.com/cyq1162/
//  起源：IT恋、IT连 创业App http://www.itlinks.cn
//  Copyright © 2017-2027年. All rights reserved.
//

#import "STUIViewController.h"
#import <objc/runtime.h>
#import "STDictionary.h"
#import "STDefine.h"
#import "STDefineUI.h"
#import "STUIView.h"
#import "STUIViewAddUI.h"
#import "STUIViewAutoLayout.h"
#import "Sagit.h"

@implementation UIViewController(ST)

//-(UIView *)view
//{
//    UIView *view=[self key:@"view"];
//    if(!view)
//    {
//        view=[[STView alloc]initWithController:self];
//        [self key:@"view" value:view];
//    }
//    return view;
//}
//此方法在第一次view时被触发，把view修改成 STView
-(void)loadView
{
    self.view=[[STView alloc]initWithController:self];
}

#pragma mark keyvalue
static char keyValueChar='k';
-(id)key:(NSString *)key
{
    id value=[self.keyValue get:key];
    if(value==nil)
    {
        value=[self.keyValueWeak get:key];
    }
    return value;
}
-(UIViewController*)key:(NSString *)key valueWeak:(id)value
{
    [self.keyValueWeak set:key value:value];
    return self;
}
-(UIViewController*)key:(NSString *)key value:(id)value
{
    [self.keyValue set:key value:value];
    return self;
}
-(NSMutableDictionary<NSString*,id>*)keyValue
{
    
    NSMutableDictionary<NSString*,id> *kv= (NSMutableDictionary<NSString*,id>*)objc_getAssociatedObject(self, &keyValueChar);
    if(kv==nil)
    {
        kv=[NSMutableDictionary<NSString*,id> new];
        [self setKeyValue:kv];
    }
    return kv;
}
-(UIViewController*)setKeyValue:(NSMutableDictionary<NSString*,id>*)keyValue
{
    objc_setAssociatedObject(self, &keyValueChar, keyValue,OBJC_ASSOCIATION_RETAIN);
    return self;
}
-(NSMapTable*)keyValueWeak
{
    NSMapTable *kv=[self.keyValue get:@"keyValueWeak"];
    if(kv==nil)
    {
        kv=[NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
        [self.keyValue set:@"keyValueWeak" value:kv];
    }
    return kv;
}
#pragma mark 设置为默认的根视图

-(UIView *)baseView
{
    return self.view.baseView;
}

//获取上一个（父）控制器
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
-(UIViewController *)nextController
{
    return [self key:@"nextController"];
}
- (UIViewController*)asRoot {
    
    return [self asRoot:RootViewDefaultType];
}
//将当前视图设置为根视图
-(UIViewController*)asRoot:(RootViewControllerType)rootViewControllerType{
    
    UIViewController *controller=self;
    if(rootViewControllerType==RootViewNavigationType)
    {
        controller = [[UINavigationController alloc]initWithRootViewController:self];
    }
    [UIApplication sharedApplication].delegate.window.rootViewController=controller;
    return self;
}
#pragma mark 扩展导航栏事件
-(BOOL)needNavBar
{
    if([self key:@"needNavBar"]!=nil)
    {
        return [[self key:@"needNavBar"] isEqualToString:@"1"];
    }
    if(self.navigationController!=nil)
    {
        return !self.navigationController.navigationBar.hidden;
    }
    return NO;
}
-(UIViewController*)needNavBar:(BOOL)yesNo
{
    return [self needNavBar:yesNo setNavBar:NO];
}
-(UIViewController*)needNavBar:(BOOL)yesNo setNavBar:(BOOL)setNavBar
{
    [self key:@"needNavBar" value:yesNo?@"1":@"0"];
    if(setNavBar && self.navigationController!=nil)
    {
        self.navigationController.navigationBar.hidden=!yesNo;
    }
    return self;
}

-(BOOL)needTabBar
{
    if([self key:@"needTabBar"]!=nil)
    {
        return [[self key:@"needTabBar"] isEqualToString:@"1"];
    }
    if(self.tabBarController!=nil)
    {
        return !self.tabBarController.tabBar.hidden;
    }
    return NO;
}
-(UIViewController*)needTabBar:(BOOL)yesNo
{
    return [self needTabBar:yesNo setTabBar:NO];
}
-(UIViewController*)needTabBar:(BOOL)yesNo setTabBar:(BOOL)setTabBar
{
    [self key:@"needTabBar" value:yesNo?@"1":@"0"];
    if(setTabBar && self.tabBarController!=nil)
    {
        self.tabBarController.tabBar.hidden=!yesNo;
    }
    return self;
}
#pragma mark 导航栏功能
- (void)stPush:(UIViewController *)viewController
{
    [self stPush:viewController title:STNavLeftDefaultTitle img:STNavLeftDefaultImage];
}
- (void)stPush:(UIViewController *)viewController title:(NSString *)title
{
    [self stPush:viewController title:title img:STNavLeftDefaultImage];
}
- (void)stPush:(UIViewController *)viewController title:(NSString *)title img:(id)imgOrName
{
    if(self.navigationController==nil){return;}
    [self block:@"存档最后的Tab栏状态，用于检测是否还原。" on:^(UIViewController *controller)
    {
        if(controller.tabBarController!=nil)//存档最后的Tab栏状态，用于检测是否还原。
        {
            [controller needTabBar:!self.tabBarController.tabBar.hidden];
            controller.tabBarController.tabBar.hidden=YES;
        }
    }];
    [self block:@"存档最后的Nav栏状态，用于检测是否还原。" on:^(UIViewController *controller)
     {
         [controller needNavBar:!controller.navigationController.navigationBar.hidden];//存档最后的导航栏状态，用于检测是否还原。
         controller.navigationController.navigationBar.hidden=NO;//显示返回导航工具条。
         controller.navigationController.navigationBar.translucent=NO;//让默认View在导航工具条之下。
     }];

    if (self.navigationController.viewControllers.count != 0)
    {
        NSMutableDictionary *dic=[viewController key:STNavConfig];
        if(dic==nil)
        {
            dic=[NSMutableDictionary new];
            [viewController key:STNavConfig value:dic];
        }
        if(title)
        {
            [dic set:STNavLeftTitle value:title];
        }
        if(imgOrName)
        {
            [dic set:STNavLeftImage value:imgOrName];
        }
        [viewController reSetNav:self.navigationController];
    }
    
    [self key:@"nextController" valueWeak:viewController];//设置指向的下一个控制器（用于滑动返回时，若有循环引用无法释放时，补上一刀）
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self.navigationController;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)stPop {
    if(self.navigationController!=nil)
    {
        NSInteger count=self.navigationController.viewControllers.count;
        UIViewController *preController=self.navigationController.viewControllers[count-2];
        self.navigationController.navigationBar.hidden=![preController needNavBar];
        if(self.tabBarController!=nil)
        {
            self.tabBarController.tabBar.hidden=![preController needTabBar];
        }
        [self dispose];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([self isKindOfClass:[UINavigationController class]])
    {
        //什么鬼，升级到Xcode 9.2 二次push之后，第二次竟然已经到了Navigation了？ 修正图票事件后好了？
        [((UINavigationController*)self) popViewControllerAnimated:YES];
        
    }
}
//系统内部调用的方法
-(UIViewController*)reSetNav:(UINavigationController*)navController
{
    NSDictionary *dic=[self key:STNavConfig];
    if(dic!=nil)
    {
        //标题
        if(!self.title)
        {
            [self title:dic[STNavTitle]];
        }
        //左导航功能按钮
        [self leftNav:dic[STNavLeftTitle] img:dic[STNavLeftImage] navController:navController];
        //右导航功能按钮
        [self rightNav:dic[STNavRightTitle] img:dic[STNavRightImage]];
    }
    return self;
}
-(UIViewController*)leftNav:(NSString*)title img:(id)imgOrName navController:(UINavigationController*)navController
{
    if(self.navigationItem==nil){return self;}
    if (title!=nil)
    {
        if([title isEqualToString:@""])
        {
            self.navigationItem.leftBarButtonItem = [UIBarButtonItem new];
        }
        else
        {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(stPop)];
        }
    }
    else if(imgOrName)
    {
        //这里引用的viewController在第二次回退时，出现了野指针问题。
        self.navigationItem.leftBarButtonItem=
        [[UIBarButtonItem alloc] initWithImage:[UIView toImage:imgOrName] style:UIBarButtonItemStyleDone target:self action:@selector(stPop)];
    }
    else
    {
        if(navController==nil){navController=self.navigationController;if(navController==nil){return self;}}
        UIButton * btn=nil;
        if(![navController.navigationBar.lastSubView isKindOfClass:[UIButton class]])
        {
            //创一张空View 显示
            btn=[[UIButton alloc] initWithFrame:STRectMake(0, 0, 200, STNavHeightPx)];
            [btn backgroundColor:ColorClear];
            [navController.navigationBar addSubview:btn];
        }
        else
        {
            btn=(UIButton*)navController.navigationBar.lastSubView;
            [btn height:STNavHeightPx];//重设高度,在被pop这后，为了不影响其它自定义，高度会被置为0
        }
        
        //移除事件，避免target指向一个旧的viewController
        [btn removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [btn addTarget:self action:@selector(stPop) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}
-(UIViewController*)rightNav:(NSString*)title img:(id)imgOrName
{
    if(self.navigationItem==nil){return self;}
    if(title)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(rightNavClick:)];
    }
    else if(imgOrName)
    {
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIView toImage:imgOrName] style:UIBarButtonItemStyleDone target:self action:@selector(rightNavClick:)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem=[UIBarButtonItem new];
    }
    return self;
}
-(void)rightNavClick:(UIBarButtonItem*)view
{
    if(view!=nil)
    {
        
        view.enabled=NO;
        [self onRightNavBarClick:view];
        [Sagit delayExecute:2 onMainThread:YES block:^{
            if(view)
            {
                view.enabled=YES;
            }
        }];
        
    }
}
//用于被用户复盖方法
-(void)onRightNavBarClick:(UIBarButtonItem*)view
{
    
}
-(void)redirect:(UIView*)view{
    if(view==nil){return;}
    NSString* name=[view key:@"clickSel"];
    if(name!=nil)
    {
        if(![name hasSuffix:@"Controller"])
        {
            name=[name append:@"Controller"];
        }
        Class class=NSClassFromString(name);
        if(class!=nil)
        {
            STController *controller=[class new];
            if(self.navigationController!=nil)
            {
                NSDictionary *config=[view key:STNavConfig];
                if(config!=nil)
                {
                    [controller key:STNavConfig value: [config toNSMutableDictionary]];
                    [self stPush:controller title:nil img:nil];
                }
                else
                {
                    [self stPush:controller title:STNavLeftDefaultTitle img:STNavLeftDefaultImage];
                }
                
            }
            else
            {
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
    }
}
#pragma mark 共用接口
//子类重写
-(void)reloadData{}
-(void)reloadData:(NSString*)para{}

#pragma mark 代码说明块
-(UIViewController*)block:(NSString*)description on:(ControllerDescription)descBlock
{
    if(descBlock!=nil)
    {
        //STWeakSelf;
        descBlock(self);
        descBlock=nil;
    }
    return self;
}

#pragma mark for TabBar 属性扩展
-(UIViewController*)title:(NSString*)title
{
    self.title=title;
    return self;
}
-(UIViewController*)tabTitle:(NSString*)title
{
    self.tabBarItem.title=title;
    return self;
}
-(UIViewController*)tabImage:(id)imgOrName
{
    if([imgOrName isKindOfClass:[NSString class]])
    {
        self.tabBarItem.image=STImageOriginal(imgOrName);
    }
    else
    {
        self.tabBarItem.image=[UIView toImage:imgOrName];
    }
    return self;
}
-(UIViewController*)tabSelectedImage:(id)imgOrName
{
    if([imgOrName isKindOfClass:[NSString class]])
    {
        self.tabBarItem.selectedImage=STImageOriginal(imgOrName);
    }
    else
    {
        self.tabBarItem.selectedImage=[UIView toImage:imgOrName];
    }
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
//!框架自动释放资源（不需要人工调用）
-(void)dispose
{
    @try
    {
        [self.view dispose];//清除自身资源
        //清理键值对。
        NSMutableDictionary *dic=self.keyValue;
        if(dic!=nil)
        {
            NSMapTable *kv=[self.keyValue get:@"keyValueWeak"];
            if(kv!=nil)
            {
                [kv removeAllObjects];
                kv=nil;
            }
            [dic removeAllObjects];
            dic=nil; //不设置为Null，因为在回退到前一个时，还要检测有没有nextControlelr。
        }
    }
    @catch(NSException *err){}
}
//fuck 这个dealloc不能存在，会影响UIAlertView，当alertViewStyle=UIAlertViewStylePlainTextInput;时，内存错误。
//-(void)dealloc
//{
//    //self.view=nil;//处理内存释放后的异常。
//    NSLog(@"UIViewController relase -> %@", [self class]);
//}
@end
