//
//  DXTabBarViewController.m
//  ZhongJianMalliOS
//
//  Created by 段 on 2017/9/7.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "DXTabBarViewController.h"
#import "DXTabBar.h"
#import "NavigationViewController.h"

@interface DXTabBarViewController ()<UITabBarControllerDelegate>

@end

@implementation DXTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
    [self setUpTabBar];

    [self addChildViewControllers];
}

#pragma mark - 更换系统tabbar
-(void)setUpTabBar
{
    DXTabBar *tabBar = [[DXTabBar alloc] init];
    tabBar.backgroundColor = [UIColor whiteColor];
    //KVC把系统换成自定义
    [self setValue:tabBar forKey:@"tabBar"];
}

#pragma mark - 添加子控制器
- (void)addChildViewControllers {
 
    NSArray *childArray = @[
                            @{MallClassKey  : @"HomeViewController",
                              MallTitleKey  : @"首页",
                              MallImgKey    : @"home_gray",//@"2拷贝",
                              MallSelImgKey : @"home_blue"//@"2拷贝"
                              },
                            
                            @{MallClassKey  : @"ClassViewController",
                              MallTitleKey  : @"分类",
                              MallImgKey    : @"classification",//@"0拷贝",
                              MallSelImgKey : @"classification_blue"//@"0拷贝"
                              },
                            
//                            @{MallClassKey  : @"NOHaveViewController",//@"HealthViewController",
//                              MallTitleKey  : @"健康圈",
//                              MallImgKey    : @"healthy",//@"大吉拷贝",
//                              MallSelImgKey : @"health_blue"//@"大吉拷贝"
//                              },
                            
                            @{MallClassKey  : @"ShopCarViewController",//@"NOHaveViewController",//@"ShopCarViewController",
                              MallTitleKey  : @"购物车",
                              MallImgKey    : @"shoppingCart_gray",//@"1拷贝",
                              MallSelImgKey : @"shoppingCart_blue"//@"1拷贝"//
                              },
                            
                            @{MallClassKey  : @"PersonCenterViewController",
                              MallTitleKey  : @"个人中心",
                              MallImgKey    : @"my_gray",//@"8拷贝",
                              MallSelImgKey : @"my_blue"//@"8拷贝"
                              },
                            
                            ];

    [childArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIViewController *vc = [NSClassFromString(dict[MallClassKey]) new];
        vc.navigationItem.title = ([dict[MallTitleKey] isEqualToString:@"首页"] || [dict[MallTitleKey] isEqualToString:@"分类"]) ? nil : dict[MallTitleKey];
        NavigationViewController *nav = [[NavigationViewController alloc] initWithRootViewController:vc];
        UITabBarItem *item = nav.tabBarItem;
//        [item initWithTitle:dict[MallTitleKey] image:[UIImage imageNamed:dict[MallImgKey]] selectedImage:[UIImage imageNamed:dict[MallSelImgKey]]];
//        item.image = [UIImage imageNamed:dict[MallImgKey]];
        item.title = dict[MallTitleKey];
//        item.title setValue:@"" forKey:<#(nonnull NSString *)#>
//        item.title.
//        item.selectedImage = [UIImage imageNamed:dict[MallSelImgKey]] ;
        item.image = [[UIImage imageNamed:dict[MallImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [[UIImage imageNamed:dict[MallSelImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
        item.imageInsets = UIEdgeInsetsMake(0, 0,-2, 0);//（当只有图片的时候）需要自动调整
        [self addChildViewController:nav];
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
