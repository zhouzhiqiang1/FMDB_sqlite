//
//  ZZQDataModel.h
//  FMDB
//
//  Created by r_zhou on 16/2/29.
//  Copyright © 2016年 r_zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jastor.h"

/**
 *  好友信息
 */
@interface YDFriendInfo : Jastor
/** 好友用户id **/
@property (assign, nonatomic) long long userID;
/** 好友头像 **/
@property (copy, nonatomic) NSString *photo;
/** 好友昵称 **/
@property (copy, nonatomic) NSString *name;
@end

