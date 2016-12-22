//
//  NickyImageScrollView.h
//  NickyScrollImageView
//
//  Created by NickyTsui on 15/12/26.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, NickyImageScrollViewMode) {
    NickyImageScrollViewAsyncDownloadMode = 2009, // 异步下载并缓存(请加入yywebImage框架,或自己重写)
    NickyImageScrollViewLoadBundleMode = 2010     // 加载本地文件
};


@protocol NickyImageScrollViewDelegate;

@interface NickyImageScrollView : UIView
/**
 *  是否开启文字
 */
@property (assign,nonatomic)BOOL                        shouldOpenTextLabel;
/**
 *  是否使用阴影
 */
@property (assign,nonatomic)BOOL                        shouldOpenShadow;
/**
 *  代理 回调当前选择项
 */
@property (weak,nonatomic)  id<NickyImageScrollViewDelegate>        delegate;
/**
 *  图片数组  若加载方式为  网络异步加载时  请往数组放置 字符串url   加载本地请放置文件名
 */
@property (copy,nonatomic)  NSArray                     *imageArray;
/**
 * 图片注释 (文字)
 */
@property (copy,nonatomic)  NSArray                     *textArray;
/**
 *  当前页
 */
@property (assign,nonatomic)NSInteger                   currentPage;
/**
 *  滚动的计时器
 */
@property (strong,nonatomic)NSTimer                     *scrollTimer;
/**
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
 *  白色点 的X点
 */
@property (assign,nonatomic)CGFloat                     pageControlX;
/**
 *  加载模式 NickyImageScrollViewAsyncDownloadMode时,使用异步加载  数组放置字符串url
 *          NickyImageScrollViewLoadBundleMode时,放置图片文件名数组
 */
@property (assign,nonatomic)NickyImageScrollViewMode    loadMode;
/**
 *  假如是 网络请求 可以放置占位图
 */
@property (strong,nonatomic)UIImage                     *placeImage;
/**
 *  点击图片时是否能显示大图预览
 */
@property (assign,nonatomic)BOOL                        canShowPreView;
/**
 *  是否设置pagecontrol边距
 */
@property (assign,nonatomic)BOOL                        shouldSetMargin;
/**
 *  边距位置 point
 */
@property (assign,nonatomic)CGPoint                     marginRightAndBottom;

@property (strong,nonatomic)UICollectionView            *collectionView;


- (instancetype)initWithFrame:(CGRect)frame imageLoadMode:(NickyImageScrollViewMode)loadMode;
/**
 *  加载下一页
 *
 *  @param sender
 */
- (void)imageScrollDidNextPage:(id)sender;
/**
 *  暂停计时器 (请在viewwilldisappear中调用)
 */
- (void)stopTimer;
/**
 *  恢复计时器 (请在viewwillappear中调用)
 */
- (void)resumeTimer;
/**
 *  请在父视图的dealloc中调用,否则 定时器无法释放
 */
- (void)killImageScrollView;

- (void)settingImageArray:(NSArray *)imageArray;

@end

@protocol NickyImageScrollViewDelegate <NSObject>

@optional

- (void)nickyImageScrollView:(NickyImageScrollView*)imageScrollView didSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)nickyImageScrollView:(NickyImageScrollView*)imageScrollView didEndScrollAtIndex:(NSInteger) index;

@end
