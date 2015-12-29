//
//  ViewController.m
//  NickyScrollImageView
//
//  Created by NickyTsui on 15/12/26.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import "ViewController.h"
#import "NickyImageScrollView.h"
#import "SecViewController.h"
@interface ViewController ()
@property (strong,nonatomic)NickyImageScrollView *imgScrollview ;
@end

@implementation ViewController
- (void)ps:(id)sender{
    [self.navigationController pushViewController:[SecViewController new] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.imgScrollview resumeTimer];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.imgScrollview stopTimer];
    
}
- (void)dealloc{
    if (self.imgScrollview){
        [self.imgScrollview killImageScrollView];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *it = [[UIBarButtonItem alloc]initWithTitle:@"a" style:UIBarButtonItemStyleDone target:self action:@selector(ps:)];
    self.navigationItem.rightBarButtonItem = it;
    
    self.imgScrollview = [[NickyImageScrollView alloc]initWithFrame:CGRectMake(0, 64, 375, 200)];
    
    
    NSArray *imageArray = @[
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254991353_750x400.jpg",
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254912135_750x400.jpg",
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254980388_750x400.jpg",
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254908208_750x400.jpg",
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254788144_750x400.jpg"];
    
    self.imgScrollview.imageArray = imageArray;
    [self.view addSubview:self.imgScrollview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
