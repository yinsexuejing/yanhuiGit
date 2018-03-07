//
//  SettlementViewController.m
//  ZhongJianMalliOS
//
//  Created by 段 on 2017/11/29.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "SettlementViewController.h"
#import "OrderAdressTableViewCell.h"
#import "OrderHeadView.h"
#import "OrderNumberCell.h"
#import "OrderCouponCell.h"
#import "OrderCouponNumberCell.h"
#import "OrderDetailAdressCell.h"
#import "AddNewAdressViewController.h"
#import "AdressViewController.h"
#import "MyOrderViewController.h"
#import "YNPayPasswordView.h"
@interface SettlementViewController ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL haveAdress;
    int number;
    NSDictionary *dataDiction;
    NSDictionary *priceDiction;
    double totalMoney;
    
    UILabel *totalPriceLabel;//总金额
    UILabel *redMoneyPriceLabel;//现金红包
    UILabel *shopPriceLabel;//购物币
    UILabel *redyMoneyPriceLabel;//现金币
    UILabel *integralPriceLabel;//积分
    
    double remain;//实付钱
    double redPay;//现金红包抵用
    double shopPay;//购物币抵用
    double redyPay;//现金币抵用
    double integralPay;//积分抵用
    
    
}
@property (nonatomic,strong)UITableView *orderTableView;
@property (nonatomic,strong)UILabel *priceNumberLabel;
@property (nonatomic,strong)UISwitch *shoppingSwich;//购物币抵用
@property (nonatomic,strong)UISwitch *redyMoneySwich;//现金币
@property (nonatomic,strong)UISwitch *redSwich;//红包
@property (nonatomic,strong)UISwitch *integralSwich;//积分抵用


@end
static NSString *const adressCellID = @"OrderAdressTableViewCell";
static NSString *const orderNumberCellID = @"OrderNumberCell";
static NSString *const orderCouponCCellID = @"OrderCouponCell";
static NSString *const orderCouponNumberCellID = @"OrderCouponNumberCell";
static NSString *const orderDetailAdressCellID = @"OrderDetailAdressCell";
@implementation SettlementViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    _orderDiction = [NSDictionary dictionary];
    dataDiction = [NSDictionary dictionary];
    priceDiction = [NSDictionary dictionary];
    
    number = 1;
    haveAdress = NO;
    redPay = 0;//现金红包抵用
    shopPay = 0;//购物币抵用
    redyPay = 0;//现金币抵用
    integralPay = 0;//积分抵用
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedAdress:) name:@"selectedAdress" object:nil];
    [self requestData];
    [self setNav];
    
    [self creatTableView];
    
    [self setBottomView];
}
- (void)requestData {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *token = [user objectForKey:@"userToken"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer new];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *url = [NSString stringWithFormat:@"%@%@",HTTPUrl,@"/zjapp/v1/AddressManager/getDefaultAddressOfUser"];
    NSDictionary *dic = @{
                          @"token":token
                          };
    [manager POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"-=-=-=-%@",responseObject);
        if ([responseObject[@"error_code"] intValue] == 0) {
            if ([responseObject[@"data"] isEqualToString:@""] || [responseObject[@"data"] count] < 2) {
              
                NSLog(@"111");
                
            }else{

                dataDiction = responseObject[@"data"];
                if ([dataDiction count] != 0) {
                    haveAdress = YES;
                }else {
                    haveAdress = NO;
                }
            }
           
        }else {
            NSString *title = [NSString stringWithFormat:@"%@",responseObject[@"error_message"]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                LoginViewController *login = [LoginViewController new];
                
                [self.navigationController pushViewController:login animated:YES];
            }]];
//            alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertControllerStyleAlert handler:^(UIAlertAction * _Nonnull action) {
//
//            }]
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        }
        [_orderTableView reloadData];
        [hud hideAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [hud hideAnimated:YES];
    }];
    
    NSString *url1 = [NSString stringWithFormat:@"%@%@%@",HTTPUrl,@"/zjapp/v1/PersonalCenter/initPersonalWallet/",token];
    [manager GET:url1 parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功=%@",responseObject);
        [hud hideAnimated:YES];
        if ([responseObject[@"error_code"] intValue] == 0) {
            priceDiction = responseObject[@"data"][@"personDataMap"];
            [_orderTableView reloadData];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [hud hideAnimated:YES];
    }];
    
    
}
- (void)setNav {
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
    title.text = @"确认订单";
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
        make.top.equalTo(title.mas_bottom).offset(-1);
        make.height.mas_offset(1);
    }];
    
}
- (void)creatTableView {
    _orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KWIDTH, KHEIGHT-44-64) style:UITableViewStyleGrouped];
    _orderTableView.backgroundColor = [UIColor colorWithHexString:@"f4f4f4"];
    _orderTableView.delegate = self;
    _orderTableView.dataSource = self;
//    _orderTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *footView = [[UIView alloc] init];
   
    footView.backgroundColor = [UIColor whiteColor];
    UILabel *totalMoneyLabel = [self creatLabeltext:@"订单总金额"];
    [footView addSubview:totalMoneyLabel];
    [totalMoneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(10);
        make.height.mas_offset(15);
        make.top.mas_offset(5);
    }];
    totalPriceLabel = [self creatLabeltext:[NSString stringWithFormat:@"￥%.2f",totalMoney]];
    totalPriceLabel.textAlignment = 2;
    [footView addSubview:totalPriceLabel];
    [totalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-10);
        make.height.mas_offset(15);
        make.top.mas_offset(5);
    }];
    UILabel *redMoneyLabel = [self creatLabeltext:@"现金红包抵用"];
    [footView addSubview:redMoneyLabel];
    [redMoneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(totalMoneyLabel.mas_bottom).offset(5);
        make.left.mas_offset(10);
        make.height.mas_offset(15);
    }];
    redMoneyPriceLabel = [self creatLabeltext:@"-￥0.00"];
    redMoneyPriceLabel.textAlignment = 2;
    [footView addSubview:redMoneyPriceLabel];
    [redMoneyPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-10);
        make.height.mas_offset(15);
        make.top.equalTo(totalMoneyLabel.mas_bottom).offset(5);
    }];
    UILabel *shopLabel = [self creatLabeltext:@"购物币抵用"];
    [footView addSubview:shopLabel];
    [shopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(redMoneyLabel.mas_bottom).offset(5);
        make.left.mas_offset(10);
        make.height.mas_offset(15);
    }];
    shopPriceLabel = [self creatLabeltext:@"-￥0.00"];
    shopPriceLabel.textAlignment = 2;
    [footView addSubview:shopPriceLabel];
    [shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-10);
        make.height.mas_offset(15);
        make.top.equalTo(redMoneyLabel.mas_bottom).offset(5);
    }];
    
    UILabel *redyLabel = [self creatLabeltext:@"现金币抵用"];
    [footView addSubview:redyLabel];
    [redyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shopLabel.mas_bottom).offset(5);
        make.left.mas_offset(10);
        make.height.mas_offset(15);
    }];
    redyMoneyPriceLabel = [self creatLabeltext:@"-￥0.00"];
    redyMoneyPriceLabel.textAlignment = 2;
    [footView addSubview:redyMoneyPriceLabel];
    [redyMoneyPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-10);
        make.height.mas_offset(15);
        make.top.equalTo(shopLabel.mas_bottom).offset(5);
    }];
    if ([_isVIP intValue] == 1)  {
        footView.frame = CGRectMake(0, 0, KWIDTH, 22*5);
        UILabel *insLabel = [self creatLabeltext:@"积分抵用"];
        [footView addSubview:insLabel];
        [insLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(redyLabel.mas_bottom).offset(5);
            make.left.mas_offset(10);
            make.height.mas_offset(15);
        }];
        integralPriceLabel = [self creatLabeltext:@"-￥0.00"];
        integralPriceLabel.textAlignment = 2;
        [footView addSubview:integralPriceLabel];
        [integralPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-10);
            make.height.mas_offset(15);
            make.top.equalTo(redyLabel.mas_bottom).offset(5);
        }];
        
        
        
    }else {
        footView.frame = CGRectMake(0, 0, KWIDTH, 22*4);
    }
    
    _orderTableView.tableFooterView = footView;
    _orderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.view addSubview:_orderTableView];
    
    
}
- (void)setBottomView {
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(0);
        make.width.mas_offset(KWIDTH);
        make.height.mas_offset(44);
        make.bottom.mas_offset(0);
    }];
    UILabel *totalLabel = [[UILabel alloc] init];
    totalLabel.text = @"实付：";
    totalLabel.font = [UIFont systemFontOfSize:15];
    totalLabel.textColor = [UIColor colorWithHexString:@"444444"];
    [bottomView addSubview:totalLabel];
    [totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(10);
        make.height.mas_offset(44);
        make.top.mas_offset(0);
    }];
    _priceNumberLabel = [[UILabel alloc] init];
    _priceNumberLabel.textColor = redTextColor;
    NSString *orderPrice = [NSString stringWithFormat:@"%@",_orderDiction[@"price"]];
    NSString *orderNum = [NSString stringWithFormat:@"%@",_orderDiction[@"shopNum"]];
    double price = [orderPrice doubleValue];
    double num = [orderNum doubleValue];
    totalMoney = price * num;
    remain = totalMoney;
    totalPriceLabel.text = [NSString stringWithFormat:@"￥ %.2f",totalMoney];
    NSString *totalPrice = [NSString stringWithFormat:@"%.2f",totalMoney];
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"￥ %@",totalPrice]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:15.0]
                          range:NSMakeRange(0, 2)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"Arial Rounded MT Bold" size:15]
                          range:NSMakeRange(2, totalPrice.length)];
    _priceNumberLabel.attributedText = AttributedStr;
    [bottomView addSubview:_priceNumberLabel];
    [_priceNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(totalLabel.mas_right).offset(0);
//        make.width
        make.top.mas_offset(0);
        make.height.mas_offset(44);
    }];
    
    
    UIButton *sendOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendOrderButton.backgroundColor = [UIColor colorWithHexString:@"6493fe"];
    [sendOrderButton setTitle:@"提交订单" forState:UIControlStateNormal];
    sendOrderButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [sendOrderButton addTarget:self action:@selector(sendOrderClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sendOrderButton];
    [sendOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(0);
        make.width.mas_offset(120);
        make.top.mas_offset(0);
        make.height.mas_offset(44);
    }];
    
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return section == 2 ? 3 : 1;
    if (section == 0) {
        return 1;
    }else if(section == 1) {
        return 1;
    }else if (section == 2) {
//        return 3;
        if ([_isVIP intValue] == 1) {
            return 4;
        }else {
            return 3;
        }
    }else {
        return 1;
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return section == 1 ? 90 : 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (haveAdress == YES) {
        if (indexPath.section == 0) {
            return 72;
        }else if (indexPath.section == 1) {
            return 36;//94;
        }else {
            return 50;
        }
        
    }else{
        return indexPath.section == 1 ? 36 : 50;//94
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 7;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = nil;
    if (section == 1) {
        
        OrderHeadView *sectionHead = [[OrderHeadView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 90)];
        sectionHead.headImage.image = [UIImage imageNamed:@"picture1"];
        [sectionHead.headImage sd_setImageWithURL:[NSURL URLWithString:_orderDiction[@"imageUrl"]]];
        sectionHead.headLabel.text = _producername;
        NSString *orderPrice = [NSString stringWithFormat:@"%@",_orderDiction[@"price"]];
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"￥ %@",orderPrice]];
        [AttributedStr addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:15.0]
                              range:NSMakeRange(0, 2)];
        [AttributedStr addAttribute:NSFontAttributeName
                              value:[UIFont fontWithName:@"Arial Rounded MT Bold" size:15]
                              range:NSMakeRange(2, orderPrice.length)];
        sectionHead.priceLabel.attributedText = AttributedStr;
        sectionHead.numberLabel.text = [NSString stringWithFormat:@"x%@",_orderDiction[@"shopNum"]];//@"x1";
        
        headView = sectionHead;
    }else {
        UIView *bgview = [[UIView alloc] initWithFrame:CGRectZero];
        headView = bgview;
    }
    return headView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 7)];
    
    return footView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        if (haveAdress == YES) {
            OrderDetailAdressCell *orderDetailAressCell = [[OrderDetailAdressCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:orderDetailAdressCellID];
            if ([dataDiction count] != 0) {
                orderDetailAressCell.nameLabel.text = [NSString stringWithFormat:@"%@",dataDiction[@"Name"]];
                orderDetailAressCell.phoneLabel.text = [NSString stringWithFormat:@"%@",dataDiction[@"Phone"]];
                orderDetailAressCell.detailAdressLabel.text = [NSString stringWithFormat:@"%@%@%@%@",dataDiction[@"ProvinceName"],dataDiction[@"CityName"],dataDiction[@"RegionName"],dataDiction[@"DetailAddress"]];
            }

            cell = orderDetailAressCell;
            
        }else {
            OrderAdressTableViewCell *adressCell = [[OrderAdressTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:adressCellID];
            adressCell.adressLabel.text = @"请添加收货地址";
            cell = adressCell;
        }
        
        
    }else if (indexPath.section == 1) {
        OrderNumberCell *numberCell = [[OrderNumberCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:orderNumberCellID];
 
//        };
        numberCell.costClassLabel.text = @"免邮";

        cell = numberCell;
    }else if(indexPath.section == 2){
        
        OrderCouponCell *couponCell = [[OrderCouponCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:orderCouponCCellID];
        if (!couponCell) {
            couponCell = [[OrderCouponCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:orderCouponCCellID];
        }
        if (indexPath.row == 0) {
          
            _redSwich = [[UISwitch alloc] init];
            _redSwich.on = NO;//设置初始为ON的一边
          
            _redSwich.onTintColor = [UIColor colorWithHexString:@"6493fe"];
            [_redSwich addTarget:self action:@selector(redSwitchAction:) forControlEvents:UIControlEventValueChanged];
            [couponCell addSubview:_redSwich];
            [_redSwich mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_offset(-25);
                make.width.mas_offset(35);
                make.height.mas_offset(21);
                make.top.mas_offset(10);
            }];
            
        }else if (indexPath.row == 1) {
            _shoppingSwich = [[UISwitch alloc] init];
            _shoppingSwich.on = NO;//设置初始为ON的一边


            _shoppingSwich.onTintColor = [UIColor colorWithHexString:@"6493fe"];
            [_shoppingSwich addTarget:self action:@selector(shopSwitchAction:) forControlEvents:UIControlEventValueChanged];
            [couponCell addSubview:_shoppingSwich];
            [_shoppingSwich mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_offset(-25);
                make.width.mas_offset(35);
                make.height.mas_offset(21);
                make.top.mas_offset(10);
            }];
        }else if(indexPath.row == 2){
            
            _redyMoneySwich = [[UISwitch alloc] init];
            _redyMoneySwich.on = NO;//设置初始为ON的一边
            _redyMoneySwich.onTintColor = [UIColor colorWithHexString:@"6493fe"];
            [_redyMoneySwich addTarget:self action:@selector(redyMoneySwitchAction:) forControlEvents:UIControlEventValueChanged];
            [couponCell addSubview:_redyMoneySwich];
            [_redyMoneySwich mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_offset(-25);
                make.width.mas_offset(35);
                make.height.mas_offset(21);
                make.top.mas_offset(10);
            }];

        }else if (indexPath.row == 3) {
            _integralSwich = [[UISwitch alloc] init];
            _integralSwich.on = NO;//设置初始为ON的一边
            
            _integralSwich.onTintColor = [UIColor colorWithHexString:@"6493fe"];
            [_integralSwich addTarget:self action:@selector(integralSwitchAction:) forControlEvents:UIControlEventValueChanged];
            [couponCell addSubview:_integralSwich];
            [_integralSwich mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_offset(-25);
                make.width.mas_offset(35);
                make.height.mas_offset(21);
                make.top.mas_offset(10);
            }];

        }
        if ([priceDiction count] != 0) {
            if ([_isVIP intValue] == 1) {
                NSString *text2 = [NSString stringWithFormat:@"可用现金红包￥%@",priceDiction[@"Coupon"]];
                NSString *text = [NSString stringWithFormat:@"可用购物币￥%@",priceDiction[@"RemainPoints"]];
                NSString *text1 = [NSString stringWithFormat:@"可用现金币￥%@",priceDiction[@"RemainElecNum"]];
                NSString *text3 = [NSString stringWithFormat:@"可用积分%@",priceDiction[@"RemainVIPAmount"]];
                NSArray *textArr = @[text2,text,text1,text3];
                couponCell.titleLabel.text = textArr[indexPath.row];
                
            }else {
                NSString *text = [NSString stringWithFormat:@"可用购物币￥%@",priceDiction[@"RemainPoints"]];
                NSString *text1 = [NSString stringWithFormat:@"可用现金币￥%@",priceDiction[@"RemainElecNum"]];
                NSString *text2 = [NSString stringWithFormat:@"可用现金红包￥%@",priceDiction[@"Coupon"]];
                NSArray *textArr = @[text2,text,text1];
                couponCell.titleLabel.text = textArr[indexPath.row];
            }
      
        }
 
        cell = couponCell;
    
    }
 
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"点击的是%ld行--%ld个",(long)indexPath.section,indexPath.row);
    if (indexPath.section == 0) {
//        AddNewAdressViewController *addVC = [AddNewAdressViewController new];
//        [self.navigationController pushViewController:addVC animated:YES];
        AdressViewController *adress = [AdressViewController new];
        adress.fromVCid = @"1";
        [self.navigationController pushViewController:adress animated:YES];
    }
    
    
}
#pragma mark -----积分
-(void)integralSwitchAction:(UISwitch *)sender {
    if (sender.on == YES) {
        _shoppingSwich.on = NO;
        _redSwich.on = NO;
        _redyMoneySwich.on = NO;

    }else {
        
    }
    [self selectedYesOrNo];
}
#pragma mark -----购物币
-(void)shopSwitchAction:(UISwitch *)sender {
 
    if (sender.on == YES) {
        _integralSwich.on = NO;
      
    }else {

    }

    [self selectedYesOrNo];
}
#pragma mark -----现金红包
-(void)redSwitchAction:(UISwitch *)sender {

    if (sender.on == YES) {
        _integralSwich.on = NO;
    
    }else {
        
    }
    [self selectedYesOrNo];
}
#pragma mark -----现金bi
-(void)redyMoneySwitchAction:(UISwitch *)sender {

    if (sender.on == YES) {
        _integralSwich.on = NO;
       
    }else {

    }
 
    [self selectedYesOrNo];
}
- (void)selectedYesOrNo {
    
    double elecNum = [_orderDiction[@"elecNum"] doubleValue]/2;
    NSDecimalNumber *orderNum = [NSDecimalNumber decimalNumberWithString:_orderDiction[@"shopNum"]];;//[NSString stringWithFormat:@"%@",]];
    NSDecimalNumber *elecNumber1 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",elecNum]];
    //积分
    double elecNum1 = [_orderDiction[@"elecNum"] doubleValue];
    NSDecimalNumber *elecNumber2 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",elecNum1]];
    elecNumber2 = [orderNum decimalNumberByMultiplyingBy:elecNumber2];
    elecNum1 = [elecNumber2 doubleValue];
    //商品红包
    NSDecimalNumber *elecNumber = [orderNum decimalNumberByMultiplyingBy:elecNumber1];
    elecNum = [elecNumber doubleValue];
    //自己的红包
    NSDecimalNumber *mineElecNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",priceDiction[@"Coupon"]]];
    double mineNumber = [mineElecNumber doubleValue];
    //剩余
    NSDecimalNumber *remainNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",totalMoney]];
    //购物币
    NSDecimalNumber *shopNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",priceDiction[@"RemainPoints"]]];
    //现金币
    NSDecimalNumber *redyNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",priceDiction[@"RemainElecNum"]]];
    //积分
    NSDecimalNumber *remainVIPNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",priceDiction[@"RemainVIPAmount"]]];

    if (_integralSwich.on == YES) {
        NSDecimalNumber *remainVIP;
        NSDecimalNumber *remainNum;
        if ([remainVIPNumber doubleValue] > elecNum1) {
             remainVIP = [remainNumber decimalNumberBySubtracting:elecNumber2];
            remain = [remainVIP doubleValue];
        }else {
            remainVIP = remainVIPNumber;
            remainNum = [remainNumber decimalNumberBySubtracting:remainVIP];
            remain = [remainNum doubleValue];
        }

        redPay = 0;
        redyPay = 0;
        shopPay = 0;
        
        if ([remainVIPNumber doubleValue] > elecNum1) {
            integralPriceLabel.text = [NSString stringWithFormat:@"-￥%.2f",elecNum1];
            integralPay = elecNum1;
            
        }else {
            double remainDouble = [remainVIPNumber doubleValue];
            integralPriceLabel.text = [NSString stringWithFormat:@"-￥%.2f",remainDouble];
            integralPay = remainDouble;
        }
   
        
    }else {
        integralPriceLabel.text = [NSString stringWithFormat:@"-￥0.00"];
        if (_redSwich.on == YES && _redyMoneySwich.on == YES && _shoppingSwich.on == YES) {
            NSDecimalNumber *subNum;
            NSDecimalNumber *remainNum;
            if (mineNumber > elecNum) {
                subNum = [remainNumber decimalNumberBySubtracting:elecNumber];//减红包
                redPay = elecNum;
            }else {
                subNum = [remainNumber decimalNumberBySubtracting:mineElecNumber];
                redPay = mineNumber;
            }
            redMoneyPriceLabel.text = [NSString stringWithFormat:@"-￥%.2f",redPay];
            
            NSLog(@"红包-%@----",subNum);
            if ([subNum doubleValue] > [shopNumber doubleValue]) {
                subNum = [subNum decimalNumberBySubtracting:shopNumber];//减购物币
                shopPay = [shopNumber doubleValue];//购物币抵用
            }else {
//                NSDecimalNumber *surplus = [shopNumber decimalNumberBySubtracting:subNum];
                shopPay = [subNum doubleValue];
                subNum = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            NSLog(@"购物币-%@----",subNum);
            if ([subNum doubleValue] > [redyNumber doubleValue]) {
                subNum = [subNum decimalNumberBySubtracting:redyNumber];//减现金币
                redyPay = [redyNumber doubleValue];
            }else {
//                NSDecimalNumber *surplus = [redyNumber decimalNumberBySubtracting:subNum];
                redyPay = [subNum doubleValue];
                subNum = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            NSLog(@"现金-%@----",subNum);
            
            remainNum = subNum;
            remain = [remainNum doubleValue];
            
        }else if (_redSwich.on == YES && _redyMoneySwich.on == NO && _shoppingSwich.on == NO) {
            NSDecimalNumber *subNum;
            NSDecimalNumber *remainNum;
//            subNum = [remainNumber decimalNumberBySubtracting:elecNumber];//减红包
            if (mineNumber > elecNum) {
                subNum = [remainNumber decimalNumberBySubtracting:elecNumber];//减红包
                redPay = elecNum;
            }else {
                subNum = [remainNumber decimalNumberBySubtracting:mineElecNumber];
                redPay = mineNumber;
            }
            
             redMoneyPriceLabel.text = [NSString stringWithFormat:@"-￥%.2f",redPay];
//            redPay = elecNum;
            shopPay = 0;
            redyPay = 0;
            NSLog(@"红包-%@----",subNum);
            remainNum = subNum;
            remain = [remainNum doubleValue];

        }
        else if(_redSwich.on == YES && _redyMoneySwich.on == NO && _shoppingSwich.on == YES) {
            NSDecimalNumber *subNum;
            NSDecimalNumber *remainNum;
//            subNum = [remainNumber decimalNumberBySubtracting:elecNumber];//减红包
            if (mineNumber > elecNum) {
                subNum = [remainNumber decimalNumberBySubtracting:elecNumber];//减红包
                redPay = elecNum;
            }else {
                subNum = [remainNumber decimalNumberBySubtracting:mineElecNumber];
                redPay = mineNumber;
            }
             redMoneyPriceLabel.text = [NSString stringWithFormat:@"-￥%.2f",redPay];
//            redPay = elecNum;
          NSLog(@"红包-%@----",subNum);
            if ([subNum doubleValue] > [shopNumber doubleValue]) {
                subNum = [subNum decimalNumberBySubtracting:shopNumber];//减购物币
                shopPay = [shopNumber doubleValue];//购物币抵用
            }else {
//                NSDecimalNumber *surplus = [shopNumber decimalNumberBySubtracting:subNum];
                shopPay = [subNum doubleValue];
                subNum = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            redyPay = 0;
            NSLog(@"购物币-%@----",subNum);
            remainNum = subNum;
            remain = [remainNum doubleValue];

        }else if (_redSwich.on == YES && _redyMoneySwich.on == YES && _shoppingSwich.on == NO) {
            NSDecimalNumber *subNum;
            NSDecimalNumber *remainNum;
//            subNum = [remainNumber decimalNumberBySubtracting:elecNumber];//减红包
            if (mineNumber > elecNum) {
                subNum = [remainNumber decimalNumberBySubtracting:elecNumber];//减红包
                redPay = elecNum;
            }else {
                subNum = [remainNumber decimalNumberBySubtracting:mineElecNumber];
                redPay = mineNumber;
            }
            redMoneyPriceLabel.text = [NSString stringWithFormat:@"-￥%.2f",elecNum];
//            redPay = elecNum;
            if ([subNum doubleValue] > [redyNumber doubleValue]) {
                subNum = [subNum decimalNumberBySubtracting:redyNumber];//减现金币
                redyPay = [redyNumber doubleValue];
            }else {
//                NSDecimalNumber *surplus = [redyNumber decimalNumberBySubtracting:subNum];
//                redyPay = [surplus doubleValue];
                redyPay = [subNum doubleValue];
                subNum = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            NSLog(@"现金-%@----",subNum);
            shopPay = 0;
            
            remainNum = subNum;
            remain = [remainNum doubleValue];
            
        }else if (_redSwich.on == NO && _redyMoneySwich.on == NO && _shoppingSwich.on == NO) {
            remain = [remainNumber doubleValue];
            shopPay = 0;
            redyPay = 0;
            redPay = 0;
            redMoneyPriceLabel.text = [NSString stringWithFormat:@"-￥0.00"];
            
        }else if (_redSwich.on == NO && _redyMoneySwich.on == YES && _shoppingSwich.on == NO) {
            NSDecimalNumber *subNum;
            NSDecimalNumber *remainNum;
            if ([remainNumber doubleValue] > [redyNumber doubleValue]) {
                subNum = [remainNumber decimalNumberBySubtracting:redyNumber];//减现金币
                redyPay = [redyNumber doubleValue];
            }else {
//                NSDecimalNumber *surplus = [redyNumber decimalNumberBySubtracting:remainNumber];
                redyPay = [remainNumber doubleValue];
                subNum = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            shopPay = 0;
            
            NSLog(@"现金-%@----",subNum);
            redPay = 0;
            
            remainNum = subNum;
            remain = [remainNum doubleValue];
            
        }else if (_redSwich.on == NO && _redyMoneySwich.on == NO && _shoppingSwich.on == YES) {
            NSDecimalNumber *subNum;
            NSDecimalNumber *remainNum;
            if ([remainNumber doubleValue] > [shopNumber doubleValue]) {
                subNum = [remainNumber decimalNumberBySubtracting:shopNumber];//减购物币
                shopPay = [shopNumber doubleValue];//购物币抵用
            }else {
//                NSDecimalNumber *surplus = [shopNumber decimalNumberBySubtracting:remainNumber];
                shopPay = [remainNumber doubleValue];
                subNum = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            NSLog(@"购物币-%@----",subNum);
            redPay = 0;
            redyPay = 0;
            
            remainNum = subNum;
            remain = [remainNum doubleValue];
        }else if (_redSwich.on == NO && _redyMoneySwich.on == YES && _shoppingSwich.on == YES) {
            NSDecimalNumber *subNum;
            NSDecimalNumber *remainNum;
            if ([remainNumber doubleValue] > [shopNumber doubleValue]) {
                subNum = [remainNumber decimalNumberBySubtracting:shopNumber];//减购物币
                shopPay = [shopNumber doubleValue];//购物币抵用
            }else {
//                NSDecimalNumber *surplus = [shopNumber decimalNumberBySubtracting:remainNumber];
//                shopPay = [surplus doubleValue];
                shopPay = [remainNumber doubleValue];
                subNum = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
              NSLog(@"购物币-%@----",subNum);
            if ([subNum doubleValue] > [redyNumber doubleValue]) {
                subNum = [subNum decimalNumberBySubtracting:redyNumber];//减现金币
                redyPay = [redyNumber doubleValue];
            }else {
                //                NSDecimalNumber *surplus = [redyNumber decimalNumberBySubtracting:subNum];
                redyPay = [subNum doubleValue];
                subNum = [NSDecimalNumber decimalNumberWithString:@"0"];
            }
            NSLog(@"现金-%@----",subNum);
            
            redPay = 0;
           
            remainNum = subNum;
            remain = [remainNum doubleValue];
        }
    }

    redMoneyPriceLabel.text = [NSString stringWithFormat:@"-￥%.2f",redPay];
    shopPriceLabel.text = [NSString stringWithFormat:@"-￥%.2f",shopPay];
    redyMoneyPriceLabel.text = [NSString stringWithFormat:@"-￥%.2f",redyPay];
    _priceNumberLabel.text = [NSString stringWithFormat:@"￥ %.2f",remain];
    
}
#pragma mark---传过来的地址
- (void)selectedAdress:(NSNotification *)notification{
    NSLog(@"接受到通知");
    NSDictionary *dic = notification.userInfo;
    NSLog( @"######%@",dic);
    dataDiction = dic;
    haveAdress = YES;
    [_orderTableView reloadData];
    
}
- (void)sendOrderClick:(UIButton*)sender {
    NSLog(@"订单提交");
    NSString *adrressId = [NSString stringWithFormat:@"%@",dataDiction[@"Id"]];
    NSLog(@"%@",adrressId);
    if (adrressId.length == 0 || [adrressId isEqualToString:@"(null)"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择收货地址" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
    }else {
 
        NSDecimalNumber *realPay = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",remain]];
        NSDecimalNumber *totalPay = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",totalMoney]];
        NSDecimalNumber *useCoupon = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",redPay]];
        NSDecimalNumber *useElecNum = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",redyPay]];
        NSDecimalNumber *usePointNum = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",shopPay]];
        NSDecimalNumber *useVIPRemainNum = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",integralPay]];

        NSDictionary *orderDic = @{
                                   @"adrressId":adrressId,
                                   @"orderHeads":@[
                                           @{@"producername":_producername,
                                             @"producerno":_producerno,
                                             @"producertel":_producertel,
                                             @"freight":@0,
                                             @"memo":@"",
                                             @"orderLines":@[
                                                     @{@"productId":_productId,
                                                       @"productNum":_orderDiction[@"shopNum"],
                                                       @"specId":_orderDiction[@"specId"]
                                                       }
                                                     ],
                                             @"realPay":realPay,
                                             @"totalAmount":totalPay,
                                             @"useCoupon":useCoupon,
                                             @"useElecNum":useElecNum,
                                             @"usePointNum":usePointNum,
                                             @"useVIPRemainNum":useVIPRemainNum
                                             } 
                                           ]
                                   
                                   };
 
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *token = [user objectForKey:@"userToken"];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer new];
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json"
                         forHTTPHeaderField:@"Content-Type"];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        NSNumber *isNormal = [NSNumber numberWithInteger:IsDefault];
        NSString *url = [NSString stringWithFormat:@"%@%@%@",HTTPUrl,@"/zjapp/v1/PersonalCenter/createBOrder/",token];
        [manager POST:url parameters:orderDic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"%@",responseObject);
            if ([responseObject[@"error_code"] integerValue] == 0) {
                NSString *type = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"type"]];
                if ([type isEqualToString:@"1"]) {
                    NSString *orderUrl = [NSString stringWithFormat:@"%@%@%@",HTTPUrl,@"/zjapp/v1/PersonalCenter/syncHandleOrderC/",token];
                    NSString *orderNoC = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"orderNoC"]];
                    [self setOrderURL:orderUrl orderNo:orderNoC];
                    
                }else {
                    NSString *appScheme = @"com.zhongjianAlipay";
                    NSString *orderString = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"singData"]];
                    // NOTE: 调用支付结果开始支付
                    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                        NSLog(@"reslut = %@",resultDic);
                    }];
                }
            }else {
                NSString *message = [NSString stringWithFormat:@"%@",responseObject[@"error_message"]];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
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
 
    
}
- (void)setOrderURL:(NSString *)url orderNo:(NSString *)order {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer new];
 
    NSDictionary *paramete = @{
                               @"orderNoC":order
                               };
    [manager POST:url parameters:paramete progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject[@"error_code"] intValue] == 0) {
            MyOrderViewController *myOrderVC = [MyOrderViewController new];
            myOrderVC.selectedIndex = 0;
            [self.navigationController pushViewController:myOrderVC animated:YES];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)backButtonClick {
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)dealloc{
    //第一种方法.这里可以移除该控制器下的所有通知
    // 移除当前所有通知
    NSLog(@"移除了所有的通知");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
}
- (UILabel *)creatLabeltext:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = redTextColor;
    label.text = text;
    label.font = [UIFont systemFontOfSize:13];
    
    
    return label;
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
