//
//  ZZQDBManager.h
//  FMDB
//
//  Created by r_zhou on 16/2/26.
//  Copyright © 2016年 r_zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZQDataModel.h"
#import "FMDB.h"

@interface ZZQDBManager : NSObject

+ (ZZQDBManager *)shareInstance;

#pragma mark - 公共接口
/**
 *  绑定数据库
 */
- (void)bindDB;

/**
 *  解绑数据库
 */
- (void)unbindDB;

/**
 *  保存用户信息到数据库
 *
 *  @param aUserInfo 要保存的用户信息
 */
- (void)insertUserToDB:(YDFriendInfo *)aUserInfo;

/**
 *  批量保存用户信息到数据库
 *
 *  @param users 要保存的用户信息
 */
- (void)batchInsertUsersToDB:(NSArray *)users;


/**
 *  从表中获取用户信息
 *
 *  @param userId 要获取的用户id
 *
 *  @return 返回该用户信息
 */
- (YDFriendInfo *)getUserByUserId:(NSString *)userId;

/**
 *  获取所有用户
 *
 *  @return 所有用户数组
 */
- (NSArray *)getAllUsers;

/**
 *  清空所有数据
 */
- (void)clearData;

/**
 *  删除指定userid数据
 */
- (void)deleteData:(NSString *)aTable;

@end
