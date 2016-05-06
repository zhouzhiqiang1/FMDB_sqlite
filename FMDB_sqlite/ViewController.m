//
//  ViewController.m
//  FMDB_sqlite
//
//  Created by r_zhou on 16/5/5.
//  Copyright © 2016年 r_zhous. All rights reserved.
//

#import "ViewController.h"
#import "ZZQDBManager.h"
#import "ZZQDataModel.h"

#define kKeyPathUserInfo @"userInfo"

@interface ViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) YDFriendInfo *info;
// 输出拿到数据
@property (strong, nonatomic) YDFriendInfo *infos;

@property (assign, nonatomic) int mun;
@property (strong, nonatomic) NSArray *nameArray;
@property (strong, nonatomic) NSArray *photoArray;
@property (strong, nonatomic) NSString *queryStrOne;
@property (strong, nonatomic) NSString *queryStrTwo;
@end

@implementation ViewController
@synthesize info;
@synthesize infos;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.queryStrOne = @"";
    self.queryStrTwo = @"";
    self.obtainDatabaseDataTextField.delegate = self;
    self.obtainDatabaseDataTextField.tag = 0;
    self.obtanDataTextField.delegate = self;
    self.obtanDataTextField.tag = 1;
    
    self.nameArray = @[@"龙一",@"凤二",@"张三",@"李四",@"王五",@"赵六"];
    self.photoArray = @[@"龙一图",@"凤二图",@"张三图",@"李四图",@"王五图",@"赵六图"];
    
    info = [[YDFriendInfo alloc] init];
    self.mun = 1;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * 删除指定数据
 */
- (IBAction)onDeleteBtnAction:(id)sender {
    [[ZZQDBManager shareInstance] deleteData:self.queryStrTwo];
}


/*
 * 清空数据库
 */
- (IBAction)onDeleteAction:(id)sender {
    [[ZZQDBManager shareInstance] clearData];
    self.mun = 1;
}


/*
 * 绑定数据库
 */
- (IBAction)onBindDBAction:(id)sender {
    
    [[ZZQDBManager shareInstance] bindDB];
    
    self.contentLabel.text = @"绑定数据库";
}


/*
 * 数据库数据存储
 */
- (IBAction)onDatabaseStorageAction:(id)sender {
    
    
    info.userID = self.mun;
    info.name = self.nameArray[self.mun - 1];
    info.photo = self.photoArray[self.mun - 1];

    
    
    if (self.mun < self.nameArray.count) {
        NSLog(@"数据库数据存储");
        [[ZZQDBManager shareInstance] insertUserToDB:info];
        self.mun += 1;
        self.contentLabel.text = [NSString stringWithFormat:@"储存信息:\n%@",info];
    } else {
        NSLog(@"没有数据可以存储");
    }
}

/*
 * 获取数据库数据
 */
- (IBAction)onObtainDatabaseDataAction:(id)sender {
    NSLog(@"获取数据库数据");
    
    if ([self.queryStrOne isEqualToString:@""]) {
        return;
    }
    YDFriendInfo *userInfo = [[ZZQDBManager shareInstance] getUserByUserId:self.queryStrOne];
    NSLog(@"YDFriendInfo = %@",userInfo);
    
    self.contentLabel.text = [NSString stringWithFormat:@"获取数据库数据:\n%@",userInfo];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField.tag == 0) {
        if ([string isEqualToString:@""]) {
            self.queryStrOne = [self.queryStrOne substringToIndex:self.queryStrOne.length - 1];
        } else {
            self.queryStrOne = [self.queryStrOne isEqualToString:@""] ? string:[NSString stringWithFormat:@"%@%@",self.queryStrOne,string];
        }
    } else {
        if ([string isEqualToString:@""]) {
            self.queryStrTwo = [self.queryStrTwo substringToIndex:self.queryStrTwo.length - 1];
        } else {
            self.queryStrTwo = [self.queryStrTwo isEqualToString:@""] ? string:[NSString stringWithFormat:@"%@%@",self.queryStrTwo,string];
        }
    }

    
    return YES;
}
//  NSString *str=@"123AbcBSFDSasd";
//    NSLog(@"%@",[str substringFromIndex:2]);//从指定的字符串开始到尾部
//    NSLog(@"%@",[str substringToIndex:5]);//是开始位置截取到指定位置但是不包含指定位置
//    NSLog(@"%@",[newsModel.title substringWithRange:NSMakeRange(0, 10)]);//按照给定的NSRang字符串截取自串的宽度和位置
//    NSLog(@"%@",[str substringWithRange:NSMakeRange(0, 4)]); //从第几个开始 到第几个结束
//    NSLog(@"%@",[str substringWithRange:NSMakeRange(6, 4)]);//从第几个开始  后几位
//    NSLog(@"%@",[str substringFromIndex:2]);//从指定的字符串开始到尾部
//    NSLog(@"%@",[str substringToIndex:5]);//是开始位置截取到指定位置但是不包含指定位置
//    NSLog(@"%@",[str substringWithRange:NSMakeRange(0, 10)]);//按照给定的NSRang字符串截取自串的宽度和位置

/**111
 *  解绑数据库
 */
- (IBAction)onUnBinDBAction:(id)sender {
    NSLog(@"解绑数据库");
    
    [[ZZQDBManager shareInstance] unbindDB];
    
    self.contentLabel.text = @"解绑数据库";
}

@end
