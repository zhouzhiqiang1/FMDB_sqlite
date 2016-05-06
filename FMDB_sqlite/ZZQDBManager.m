//
//  ZZQDBManager.m
//  FMDB
//
//  Created by r_zhou on 16/2/26.
//  Copyright © 2016年 r_zhou. All rights reserved.
//

#import "ZZQDBManager.h"
//#import "GSFileManager.h"

/**
 *  数据库版本
 */
#define kYDDBUserVersion 1

#pragma mark - SQL Type
static NSString * const kSQLTypeInteger = @"integer";
static NSString * const kSQLTypeText = @"text";
static NSString * const kSQLTypeLong = @"long";
static NSString * const kSQLTypeFloat = @"float";

#pragma mark - Table Name
static NSString * const kUserTableName = @"USER_TABLES";
static NSString * const kFriendTableName = @"FRIEND_TABLES";

#pragma mark - Column Name
static NSString * const kColumnNameUserID = @"userid";
static NSString * const kColumnNameUserName = @"name";
static NSString * const kColumnNameUserPortraitUri = @"portraitUri";

@interface ZZQDBManager()
@property (nonatomic, strong) FMDatabaseQueue *queue;
@end

@implementation ZZQDBManager

+ (ZZQDBManager *)shareInstance
{
    static ZZQDBManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        //        [instance bindDB];
    });
    return instance;
}

#pragma mark - 公共接口
/**
 *  绑定数据库，包括表的创建、升级等
 */
- (void)bindDB
{
    // 数据库的路径
//    NSString *dbPath = [[GSFileManager sharedManager] pathForDomain:GSFileDirDomain_CurUser appendPathName:@"userdb.sqlite"];
    
    //1.获得数据库文件的路径
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"路径 %@",dbPath);
    NSString *fileName = [dbPath stringByAppendingPathComponent:@"student.sqlite"];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:fileName];
    self.queue = queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        
        if (![db tableExists:kUserTableName]) {
            NSString *sqlstring = [NSString stringWithFormat:
                                   @"CREATE TABLE %@ (%@ long PRIMARY KEY, %@ text, %@ text)",
                                   kUserTableName,
                                   kColumnNameUserID,
                                   kColumnNameUserName,
                                   kColumnNameUserPortraitUri];
            [db executeUpdate:sqlstring];
        }
        
        if (![db tableExists:kFriendTableName]) {
            NSString *sqlstring = [NSString stringWithFormat:
                                   @"CREATE TABLE %@ (%@ long PRIMARY KEY, FOREIGN KEY(%@) REFERENCES %@(%@))",
                                   kFriendTableName,
                                   kColumnNameUserID,
                                   kColumnNameUserID,
                                   kUserTableName,
                                   kColumnNameUserID];
            
            [db executeUpdate:sqlstring];
        }
        
        if (db.userVersion < kYDDBUserVersion) {
            [self _upgradeDB:db];
            [db setUserVersion:kYDDBUserVersion];
        }
    }];
}

/*
 * 解绑数据库
 */
- (void)unbindDB
{
    [self.queue close];
    [self setQueue:nil];
}

/*
 * 保存用户信息到数据库
 */
- (void)insertUserToDB:(YDFriendInfo *)aUserInfo
{
    NSDictionary *dict = @{kColumnNameUserID:@(aUserInfo.userID),
                           kColumnNameUserName:aUserInfo.name?aUserInfo.name:@"",
                           kColumnNameUserPortraitUri:aUserInfo.photo?aUserInfo.photo:@""};
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL isSuccess = [self _excuteInsertStatementToDB:db fromDic:dict atTable:kUserTableName];
        if (!isSuccess) {
            NSLog(@"Error when insert user to Database");
        }
    }];
}

/**
 *  批量保存用户信息到数据库
 *
 *  @param users 要保存的用户信息
 */
- (void)batchInsertUsersToDB:(NSArray *)users
{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (YDFriendInfo *userInfo in users) {
            @autoreleasepool {
                NSDictionary *dict = @{kColumnNameUserID:@(userInfo.userID),
                                       kColumnNameUserName:userInfo.name?userInfo.name:@"",
                                       kColumnNameUserPortraitUri:userInfo.photo?userInfo.photo:@""};
                
                BOOL isSuccess = [self _excuteInsertStatementToDB:db fromDic:dict atTable:kUserTableName];
                if (!isSuccess) {
                    NSLog(@"Error when insert user to Database");
                }
            }
        }
    }];
}


/**
 *  从表中获取用户信息
 *
 *  @param userId 要获取的用户id
 *
 *  @return 返回该用户信息
 */
- (YDFriendInfo *) getUserByUserId:(NSString*)userId
{
    __block YDFriendInfo *userInfo = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sqlstring = [NSString stringWithFormat:@"SELECT * FROM %@ where userid = ?", kUserTableName];
        FMResultSet *rs = [db executeQuery:sqlstring, userId];
        while ([rs next]) {
            userInfo = [[YDFriendInfo alloc] init];
            userInfo.userID = [rs longForColumn:@"userid"];
            userInfo.name = [rs stringForColumn:@"name"];
            userInfo.photo = [rs stringForColumn:@"portraitUri"];
        }
        [rs close];
    }];
    return userInfo;
    
    
//    // 1.执行查询语句
//    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM t_student"];
//
//    // 2.遍历结果
//    while ([resultSet next]) {
//         int ID = [resultSet intForColumn:@"id"];
//         NSString *name = [resultSet stringForColumn:@"name"];
//         int age = [resultSet intForColumn:@"age"];
//         NSLog(@"%d %@ %d", ID, name, age);
//    }

}


////插入数据
//-(void)insert:(FMDatabase *)aDB {
// 
//    BOOL insert = [aDB executeUpdate:@"insert into t_health (name,phone) values(?,?)",@"jacob",@"138000000000"];
//    if (insert) {
//        NSLog(@"插入数据成功");
//    }else{
//        NSLog(@"插入数据失败");
//    }
// }


/**
 *  获取所有用户
 *
 *  @return 所有用户数组
 */
- (NSArray *)getAllUsers
{
    NSMutableArray *allUsers = [NSMutableArray new];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sqlstring = [NSString stringWithFormat:@"SELECT * FROM %@", kUserTableName];
        FMResultSet *rs = [db executeQuery:sqlstring];
        while ([rs next]) {
            YDFriendInfo *model = [[YDFriendInfo alloc] init];
            model.userID = [rs longForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.photo = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

- (void)clearData
{
//    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        BOOL isSuccess = [self _excuteClearDataFromDB:db atTable:kFriendTableName];
//        isSuccess = isSuccess && [self _excuteClearDataFromDB:db atTable:kUserTableName];
//        if (isSuccess) {
//            NSLog(@"清空数据库缓存成功");
//        } else {
//            NSLog(@"清空数据库失败");
//        }
//    }];
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL isSuccess = [self _excuteClearDataFromDB:db atTable:kUserTableName];
        isSuccess = isSuccess && [self _excuteClearDataFromDB:db atTable:kUserTableName];
        if (isSuccess) {
            NSLog(@"清空数据库缓存成功");
        } else {
            NSLog(@"清空数据库失败");
        }
    }];

}


- (void)deleteData:(NSString *)aTable
{

    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *executeString = [NSString stringWithFormat:@"DELETE FROM %@ where userid = '%@'",kUserTableName,aTable];
        BOOL isSuccess = [db executeUpdate:executeString];
        if (isSuccess) {
            NSLog(@"删除数据库缓存成功");
        } else {
            NSLog(@"删除数据库失败");
        }

    }];

    
}

#pragma mark - 内部函数

/**
 *  升级数据库
 *
 *  @param aDB FMDatabase
 */
- (void)_upgradeDB:(FMDatabase *)aDB
{
    // 用户表
    NSDictionary *userTableDict = @{kColumnNameUserID:kSQLTypeText,
                                    kColumnNameUserName:kSQLTypeText,
                                    kColumnNameUserPortraitUri:kSQLTypeText};
    
    NSArray *userTableKeys = [userTableDict allKeys];
    for (NSString *key in userTableKeys) {
        NSString *columnType = [userTableDict objectForKey:key];
        
        [self _excuteAddColumnStatementToDB:aDB
                                     column:key
                                       type:columnType
                          ifNotExistInTable:kUserTableName];
    }
    
    // 好友表
    NSDictionary *friendTableDict = @{kColumnNameUserID:kSQLTypeText};
    
    NSArray *friendTableKeys = [friendTableDict allKeys];
    for (NSString *key in friendTableKeys) {
        NSString *columnType = [friendTableDict objectForKey:key];
        
        [self _excuteAddColumnStatementToDB:aDB
                                     column:key
                                       type:columnType
                          ifNotExistInTable:kFriendTableName];
    }
    
}

#pragma mark - 数据库操作
- (BOOL)_excuteAddColumnStatementToDB:(FMDatabase *)aDB column:(NSString *)aColumn type:(NSString *)aType ifNotExistInTable:(NSString *)aTable
{
    NSString *executeString = [NSString stringWithFormat:@"alter table %@ add %@ %@", aTable, aColumn, aType];
    //    DDLogDebug(@"添加语句 %@", executeString);
    BOOL isSuccess = [aDB executeUpdate:executeString];
    //    BOOL isSuccess = [aDB executeUpdate:@"alter table ? add ? ?", aTable, aColumn, aType];
    return isSuccess;
}

/**
 *  Insert
 *
 *  @param aDB    FMDatabase
 *  @param aDic   要插入的数据
 *  @param aTable 数据表
 *
 *  @return 是否插入成功
 */
- (BOOL)_excuteInsertStatementToDB:(FMDatabase *)aDB fromDic:(NSDictionary *)aDic atTable:(NSString *)aTable
{
    NSMutableString *parma = [[NSMutableString alloc] init];
    NSMutableString *values = [[NSMutableString alloc] init];
    
    int i = 0;
    NSArray *keys = [aDic allKeys];
    for (NSString *key in keys)
    {
        [parma appendFormat:@"%@", key];
        [values appendFormat:@":%@", key];
        
        if (++i < keys.count)
        {
            [parma appendString:@", "];
            [values appendString:@", "];
        }
    }
    NSString *executeString = [NSString stringWithFormat:@"REPLACE INTO %@(%@) VALUES (%@)",aTable, parma, values];
    //    DDLogDebug(@"插入语句 %@", executeString);
    BOOL isSuccess = [aDB executeUpdate:executeString withParameterDictionary:aDic];
    return isSuccess;
}

/**
 *  clear
 */
- (BOOL)_excuteClearDataFromDB:(FMDatabase *)aDB atTable:(NSString *)aTable
{
    NSString *executeString = [NSString stringWithFormat:@"DELETE FROM %@",aTable];
    BOOL isSuccess = [aDB executeUpdate:executeString];
    return isSuccess;
}


@end
