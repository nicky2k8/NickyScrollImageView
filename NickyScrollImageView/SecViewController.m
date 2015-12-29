//
//  SecViewController.m
//  NickyScrollImageView
//
//  Created by NickyTsui on 15/12/26.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import "SecViewController.h"
#import "NickyImageScrollView.h"
@interface SecViewController ()
@property (strong,nonatomic) NickyImageScrollView       *imageScrollview;
@end

@implementation SecViewController
- (void)dealloc{
    NSLog(@"vc dealloc");
    if (self.imageScrollview){
        [self.imageScrollview killImageScrollView];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.imageScrollview resumeTimer];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.imageScrollview stopTimer];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *imageArray = @[
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254991353_750x400.jpg",
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254912135_750x400.jpg",
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254980388_750x400.jpg",
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254908208_750x400.jpg",
                            @"http://resources.sixin.cn/resource/load?path=resources/1/20151205/20151205170254788144_750x400.jpg"];
    
    self.imageScrollview.imageArray = imageArray;
    [self.view addSubview:self.imageScrollview];
    // Do any additional setup after loading the view.
}
- (NickyImageScrollView *)imageScrollview{
    if (!_imageScrollview){
        _imageScrollview = [[NickyImageScrollView alloc]initWithFrame:CGRectMake(0, 0, 375, 300)];
    }
    return _imageScrollview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
