//
//  NickyImageScrollView.h
//  NickyScrollImageView
//
//  Created by NickyTsui on 15/12/26.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, NickyImageScrollViewMode) {
    NickyImageScrollViewAsyncDownloadMode = 2009, // Async Download Mode 异步下载并缓存(请加入SDWebImage框架,或自己重写)
    NickyImageScrollViewLoadBundleMode = 2010     // Load Image By Bundle 加载本地文件
};
@protocol NickyImageScrollViewDelegate;

@interface NickyImageScrollView : UIView
/**
 * delegate . it is used to callback the image's click action
 * 代理 回调当前选择项
 */
@property (weak,nonatomic)  id<NickyImageScrollViewDelegate>        delegate;
/**
 *  images array .
 *  When using NickyImageScrollViewAsyncDownloadMode ,put the image URL into the Array and using some methods to download the Images,it can be modified in collectionView return Cell's method
 *  (act. It's using SDWebImage to Download the Image)
 *  Or using NickyImageScrollViewLoadBundleMode , Image will be load by [UIImage imageNamed:@""]
 *  图片数组  若加载方式为  网络异步加载时  请往数组放置 字符串url   加载本地请放置文件名
 */
@property (copy,nonatomic)  NSArray                     *imageArray;
/**
 *  Current Scroll Page Number
 *  当前页
 */
@property (assign,nonatomic)NSInteger                   currentPage;
/**
 *  The timer which will call CollectionView to scroll.
 *  滚动的计时器
 */
@property (strong,nonatomic)NSTimer                     *scrollTimer;
/**
 *
 *  设置滚动时间间隔
 */
@property (assign,nonatomic)NSTimeInterval              scrollTimeInterval;
/**
 *  图片放置模式(等比缩放?)
 */
@property (assign,nonatomic)UIViewContentMode           imageContentMode;
/**
 *  白色点
 */
@property (strong,nonatomic)UIPageControl               *pageControl;
/**
 *  白色点 的Y点
 */
@property (assign,nonatomic)CGFloat                     pageControlY;
/**
 *  加载模式 0时,使用异步加载  数组放置字符串url  1时,放置图片文件名数组
 */
@property (assign,nonatomic)NickyImageScrollViewMode    loadMode;
/**
 *  假如是 网络请求 可以放置占位图
 */
@property (strong,nonatomic)UIImage                     *placeImage;
/**
 *  View Init Method
 *
 *  @param frame    setting View's Frame
 *  @param loadMode which will control the Loading Image Way
 *
 *  @return View
 */
- (instancetype)initWithFrame:(CGRect)frame imageLoadMode:(NickyImageScrollViewMode)loadMode;
/**
 *  加载下一页
 *
 *  @param sender
 */
- (void)imageScrollDidNextPage:(id)sender;
/**
 *  it must be used in ViewController 's "viewWillDisappear" methods
 *  暂停计时器 (请在viewwilldisappear中调用)
 */
- (void)stopTimer;
/**
 *  it must be used in ViewController 's "viewWillAppear" methods
 *  恢复计时器 (请在viewwillappear中调用)
 */
- (void)resumeTimer;
/**
 *  it must be used in Parent View 's "dealloc" methods
 *  请在父视图的dealloc中调用,否则 定时器无法释放
 */
- (void)killImageScrollView;


@end

@protocol NickyImageScrollViewDelegate <NSObject>

@optional

- (void)nickyImageScrollView:(NickyImageScrollView*)imageScrollView didSelectedAtIndexPath:(NSIndexPath *)indexPath;

@end
