//
//  CpRegisterCell.h
//  wutongguo
//
//  Created by Lucifer on 2019/2/26.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TemporaryModel;
@class CpRegisterModel;

@interface CpRegisterCell : UITableViewCell

@property (nonatomic , strong) CpRegisterModel *model;
@property (nonatomic , copy) TemporaryModel *dataModel;

@property (nonatomic, copy)void(^textFieldChangeBlock)(NSString *value,NSString *title);
@property (nonatomic, copy)void(^textFieldBeginEditing)(NSString *value,NSString *title);
@property (nonatomic, copy)void(^getCodeBlock)(NSInteger type);// type = 1开始  0 结束

@end
