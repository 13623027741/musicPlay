//
//  HuView.h
//  弧形进度条
//
//  Created by clare on 15/12/8.
//  Copyright © 2015年 zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kScreenW [[UIScreen mainScreen] bounds].size.width

#define kScreenH [[UIScreen mainScreen] bounds].size.height
@interface HuView : UIView
@property(nonatomic,assign)int num;
@property(nonatomic,strong)UILabel *numLabel;
@property(nonatomic,strong)NSTimer *timer;
@end
