//
//  DirectUpgradesViewController.m
//  ZhongJianMalliOS
//
//  Created by 段 on 2017/12/29.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "DirectUpgradesViewController.h"
#import "DirectUpgradeTableViewCell.h"
#import "UpgradeViewController.h"
#import "ApplicationFormViewController.h"
@interface DirectUpgradesViewController ()  {
//    NSMutableArray *dataArr;
    NSDictionary *dataDict;
    UIButton *freeButton;
    UIImageView *upImage;
    UIImageView *bottomImage;
    UIButton *upgradesButton;
}

//@property (nonatomic,strong)UITableView *upgradesTable;

@end
//static NSString *const directUpgradeCellID = @"DirectUpgradeTableViewCell";

@implementation DirectUpgradesViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
//    dataArr = [NSMutableArray arrayWithCapacity:0];
    dataDict = [NSDictionary dictionary];
    [self configNav];
    [self requestData];
    [self configTableView];
}
- (void)requestData {
//    [dataArr removeAllObjects];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer new];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *token = [user objectForKey:@"userToken"];
    NSString *url = [NSString stringWithFormat:@"%@%@%@",HTTPUrl,@"/zjapp/v1/MemberShip/entrance/",token];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject[@"error_code"] integerValue] == 0) {
            dataDict = responseObject[@"data"];
            NSString *show;
            if ([dataDict count] != 0) {
                
                if ([dataDict[@"DirectUpdate"][@"isExit"] integerValue] == 0) {
                    upgradesButton.hidden = YES;
                    upImage.userInteractionEnabled = NO;
                    bottomImage.userInteractionEnabled = NO;
                }else {
                    if ([dataDict[@"DirectUpdate"][@"type"] integerValue] == 1) {
                        show = [NSString stringWithFormat:@"直接升级VIP"];
                    }else if ([dataDict[@"DirectUpdate"][@"type"] integerValue] == 2) {
                        show = [NSString stringWithFormat:@"直接升级准代"];
                    }else if ([dataDict[@"DirectUpdate"][@"type"] integerValue] == 3) {
                        show = [NSString stringWithFormat:@"直接升级代理"];
                    }else {
                       
                    }
                    [upgradesButton setTitle:show forState:UIControlStateNormal];
                }
                
                
            }
            
//            NSString *isExit = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"GC"][@"isExit"]];
//            if ([isExit isEqualToString:@"1"]) {
//                [dataArr addObject:responseObject[@"data"][@"GC"]];
//            }
//            NSString *nedisExit = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"VIP"][@"isExit"]];
//            if ([nedisExit isEqualToString:@"1"]) {
//                [dataArr addObject:responseObject[@"data"][@"VIP"]];
//            }
            
        }
//        NSLog(@"-==-=--%@",dataArr);
      
        [hud hideAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [hud hideAnimated:YES];
    }];
    
    
}
#pragma mark -- UI
- (void)configNav {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 100;
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(10);
        make.width.mas_offset(20);
        make.height.mas_offset(20);
        make.top.mas_offset(30);
    }];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, KWIDTH, 44)];
    title.text = @"直接升级";
    title.textAlignment = 1;
    title.textColor = [UIColor colorWithHexString:@"444444"];
    title.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(20);
        make.height.mas_offset(44);
        make.right.mas_offset(-50);
        make.left.mas_offset(50);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"f4f4f4"];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(0);
        make.right.mas_offset(0);
        make.top.mas_offset(63);
        make.height.mas_offset(1);
    }];
    
}
- (void)configTableView {
    
    
    UIView *bgImage = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KWIDTH, KHEIGHT-64)];
    bgImage.backgroundColor = [UIColor colorWithHexString:@"f4f4f4"];
    [self.view addSubview:bgImage];
    
    upImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-2"]];
    upImage.userInteractionEnabled = YES;
    [bgImage addSubview:upImage];
    [upImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(5);
        make.right.mas_offset(-5);
        make.height.mas_offset(80);
        make.top.mas_offset(10);
    }];
    UIImageView *headIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"free"]];
    [upImage addSubview:headIcon];
    [headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(25);
        make.centerY.mas_offset(0);
        make.height.mas_offset(20);
        make.width.mas_offset(20);
    }];
    UILabel *freeLabel = [[UILabel alloc] init];
    freeLabel.text = @"开通绿色通道";
    freeLabel.font = [UIFont systemFontOfSize:13];
    freeLabel.textColor = lightBlackTextColor;
    [upImage addSubview:freeLabel];
    [freeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headIcon.mas_right).offset(11);
        make.height.mas_offset(20);
        make.top.mas_offset(18);
//        make.centerY.mas_offset(0);
        make.width.mas_equalTo(KWIDTH*0.6);
    }];
    UILabel *freePrice = [[UILabel alloc] init];
    freePrice.text = @"￥99";
    freePrice.font = [UIFont systemFontOfSize:13];
    freePrice.textColor = lightBlackTextColor;
    [upImage addSubview:freePrice];
    [freePrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headIcon.mas_right).offset(11);
        make.height.mas_offset(20);
        make.top.equalTo(freeLabel.mas_bottom).offset(0);
        make.width.mas_equalTo(KWIDTH*0.6);
    }];
    UIImageView *next = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    [upImage addSubview:next];
    [next mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-20);
        make.height.mas_offset(12);
        make.width.mas_offset(12);
        make.centerY.equalTo(upImage.mas_centerY).offset(0);
    }];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClickOne)];
    [upImage addGestureRecognizer:tapGes];
    
    bottomImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-2"]];
    bottomImage.userInteractionEnabled = YES;
    [bgImage addSubview:bottomImage];
    [bottomImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(5);
        make.right.mas_offset(-5);
        make.height.mas_offset(80);
        make.top.equalTo(upImage.mas_bottom).offset(10);
    }];
    UIImageView *headIcon1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"quasiagency_gold"]];
    [bottomImage addSubview:headIcon1];
    [headIcon1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(25);
        make.centerY.mas_offset(0);
        make.height.mas_offset(20);
        make.width.mas_offset(20);
    }];
    UILabel *vipLabel = [[UILabel alloc] init];
    vipLabel.text = @"开通VIP";
    vipLabel.font = [UIFont systemFontOfSize:13];
    vipLabel.textColor = lightBlackTextColor;
    [bottomImage addSubview:vipLabel];
    [vipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headIcon1.mas_right).offset(11);
        make.height.mas_offset(20);
        make.top.mas_offset(18);
        //        make.centerY.mas_offset(0);
        make.width.mas_equalTo(KWIDTH*0.6);
    }];
    UILabel *vipPrice = [[UILabel alloc] init];
    vipPrice.text = @"￥3000";
    vipPrice.font = [UIFont systemFontOfSize:13];
    vipPrice.textColor = lightBlackTextColor;
    [bottomImage addSubview:vipPrice];
    [vipPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headIcon1.mas_right).offset(11);
        make.height.mas_offset(20);
        make.top.equalTo(vipLabel.mas_bottom).offset(0);
        make.width.mas_equalTo(KWIDTH*0.6);
    }];
    UIImageView *next1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    [bottomImage addSubview:next1];
    [next1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-20);
        make.height.mas_offset(12);
        make.width.mas_offset(12);
        make.centerY.equalTo(bottomImage.mas_centerY).offset(0);
    }];
    
    UITapGestureRecognizer *tapGes1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClickTwo)];
    [bottomImage addGestureRecognizer:tapGes1];
    
    
//    _upgradesTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KWIDTH, KHEIGHT-64) style:UITableViewStylePlain];
//    _upgradesTable.delegate = self;
//    _upgradesTable.dataSource = self;
//    _upgradesTable.backgroundColor = [UIColor colorWithHexString:@"f4f4f4"];
//    _upgradesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
//    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, KHEIGHT-80*3-64)];
    upgradesButton = [UIButton buttonWithType:UIButtonTypeCustom];
 
    upgradesButton.titleLabel.font = [UIFont systemFontOfSize:16];
    upgradesButton.backgroundColor = zjTextColor;
    upgradesButton.layer.masksToBounds = YES;
    upgradesButton.layer.cornerRadius = 20;
    [upgradesButton addTarget:self action:@selector(upgradesButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [bgImage addSubview:upgradesButton];
    [upgradesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(10);
        make.right.mas_offset(-10);
        make.height.mas_offset(40);
        make.top.equalTo(bottomImage.mas_bottom).offset(60);
    }];
//    _upgradesTable.tableFooterView = footView;
//    [self.view addSubview:_upgradesTable];
    
}
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 2;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 80;
//}
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    DirectUpgradeTableViewCell *cell = [[DirectUpgradeTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:directUpgradeCellID];
//    if (!cell) {
//        cell = [[DirectUpgradeTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:directUpgradeCellID];
//    }
////    NSArray *imageArr = @[@"free",@"quasiagency_gary",@"agent_gary"];
////    cell.headImageIcon.image = [UIImage imageNamed:imageArr[indexPath.row]];
////    NSArray *priceArr = @[@"购买99元绿色通道",@"升级到VIP"];//,@"升级到合伙人"];
////    cell.kindNameLabel.text = priceArr[indexPath.row];
////    if ([dataDict count] != 0) {
////        if (indexPath.row == 0) {
////            NSString *price = [NSString stringWithFormat:@"购买%@元绿色通道",dataDict[@"GC"][@"gcNeedPay"]];
////            cell.kindNameLabel.text = price;
////            cell.headImageIcon.image = [UIImage imageNamed:@"free"];
////
////        }else if(indexPath.row == 1) {
////            NSString *price = @"升级到VIP";//[NSString stringWithFormat:@"购买%@元绿色通道",dataArr[indexPath.row][@"gcNeedPay"]];
////            cell.kindNameLabel.text = price;
////            cell.headImageIcon.image = [UIImage imageNamed:@"quasiagency_gary"];
////
////        }
////    }
//
//
////    NSArray *kindArr = @[@"限时一个月",@"累计分值到3000"];//,@"团队分值到￥10W"];
////    cell.kindDetailLabel.text = kindArr[indexPath.row];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;
//
//}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
////    if (dataArr.count == 2 ) {
////    NSString *lev = [NSString stringWithFormat:@"%@",dataArr[indexPath.row][@"lev"]];
////    if (indexPath.row == 0) {
//////        [self requestString:@"0"];]
////        NSString *isExit = [NSString stringWithFormat:@"%@",dataArr[indexPath.row][@"isExit"]];
////        if ([isExit intValue] == 1) {
////            [self requestString:lev];
////        }else {
//////            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:<#(nullable NSString *)#> preferredStyle:<#(UIAlertControllerStyle)#>];
////
////        }
////
////    }else {
////        NSString *isExit = [NSString stringWithFormat:@"%@",dataArr[indexPath.row][@"isExit"]];
////        if ([isExit intValue] == 1) {
////            [self requestString:lev];
////        }else {
////            //            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:<#(nullable NSString *)#> preferredStyle:<#(UIAlertControllerStyle)#>];
////
////        }
////    }
//
//
////    }
//
//}
- (void)tapClickOne {
    [self requestString:@"0"];
    
}
- (void)tapClickTwo {
    [self requestString:@"1"];
}
- (void)requestString:(NSString *)lev {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer new];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *token = [user objectForKey:@"userToken"];
    NSString *url = [NSString stringWithFormat:@"%@%@%@",HTTPUrl,@"/zjapp/v1/MemberShip/createVOrder/",token];
//    NSString *type = [NSString stringWithFormat:@"%@",dataDict[@"DirectUpdate"][@"type"]];
    NSNumber *levNum = [NSNumber numberWithInteger:[lev integerValue]];
    
    NSDictionary *dic = @{
                          @"type":lev,
                          @"lev":levNum
                          };
    [manager POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSString *message = [NSString stringWithFormat:@"%@",responseObject[@"error_message"]];
        if ([responseObject[@"error_code"] integerValue] == 0) {
//            if ([code intValue] == 0) {
                NSString *appScheme = @"com.zhongjianAlipay";
                NSString *orderString = [NSString stringWithFormat:@"%@",responseObject[@"data"]];
                // NOTE: 调用支付结果开始支付
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    NSLog(@"reslut = %@",resultDic);
                }];
             [self requestData];
        }else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            
        }
        
        
        [hud hideAnimated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [hud hideAnimated:YES];
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)upgradesButtonClick {
    NSLog(@"升级");
//    UpgradeViewController *upgradeVC = [[UpgradeViewController alloc] init];
//    [self.navigationController pushViewController:upgradeVC animated:YES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer new];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *token = [user objectForKey:@"userToken"];
    NSString *url = [NSString stringWithFormat:@"%@%@%@",HTTPUrl,@"/zjapp/v1/MemberShip/directUpdate/",token];
    NSString *type = [NSString stringWithFormat:@"%@",dataDict[@"DirectUpdate"][@"type"]];
    NSDictionary *dic = @{
                          @"type":type
                          };
    [manager POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSString *message = [NSString stringWithFormat:@"%@",responseObject[@"error_message"]];
        if ([responseObject[@"error_code"] integerValue] == 0) {
            [self requestData];
        }else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            
        }
        
        
        [hud hideAnimated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [hud hideAnimated:YES];
    }];
    
    
}
- (void)backButtonClick {
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
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
