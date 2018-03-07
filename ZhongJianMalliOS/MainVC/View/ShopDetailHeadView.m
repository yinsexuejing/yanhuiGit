//
//  ShopDetailHeadView.m
//  ZhongJianMalliOS
//
//  Created by 段 on 2017/11/27.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ShopDetailHeadView.h"

@implementation ShopDetailHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatHeadView];
    }
    return self;
}
- (void)creatHeadView {
    self.backgroundColor = [UIColor whiteColor];
    UILabel *shopDetailLabel = [[UILabel alloc] init];
    shopDetailLabel.text = @"商品详情";
    shopDetailLabel.textColor = [UIColor colorWithHexString:@"444444"];
    shopDetailLabel.font = [UIFont systemFontOfSize:13];
    shopDetailLabel.textAlignment = 1;
    [self addSubview:shopDetailLabel];
    [shopDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_offset(0);
        make.width.mas_offset(80);
        make.height.mas_offset(40);
        make.top.mas_offset(0);
    }];
    UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg2"]];
    [self addSubview:leftImage];
    [leftImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(shopDetailLabel.mas_left).offset(0);
        make.centerY.mas_offset(0);
        make.height.mas_offset(8);
        make.width.mas_offset(25);
    }];
    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg1"]];
    [self addSubview:rightImage];
    [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(shopDetailLabel.mas_right).offset(0);
        make.width.mas_offset(25);
        make.centerY.mas_offset(0);
        make.height.mas_offset(8);
    }];
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
