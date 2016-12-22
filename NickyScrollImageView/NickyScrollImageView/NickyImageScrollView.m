//
//  NickyImageScrollView.m
//  NickyScrollImageView
//
//  Created by NickyTsui on 15/12/26.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import "NickyImageScrollView.h"
#import "NickyImageScrollPreView.h"

#import "UIImageView+WebCache.h"
//#import "Objc_code_header.h"

static NSInteger const      maxNumber = 20;
static NSString *const      nickyImageScrollViewCell = @"nickyImageScrollViewCell";

@interface NSTimer (NickyTsuiKit)
+ (NSTimer *)nickytsuiScheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval block:(void(^)()) block repeats:(BOOL)repeat;

@end

@implementation NSTimer (NickyTsuiKit)
+ (NSTimer *)nickytsuiScheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval block:(void (^)())block repeats:(BOOL)repeat{
    return [self scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(_nickyStartTimer:) userInfo:[block copy] repeats:repeat];
}
+ (void)_nickyStartTimer:(NSTimer *)timer{
    void(^timerBlock)() = timer.userInfo;
    if (timerBlock) timerBlock();
}
@end

@interface NickyImageCell : UICollectionViewCell

@property (strong,nonatomic)UIImageView         *imageView;

@property (strong,nonatomic)UILabel             *titleLabel;

@property (strong,nonatomic)UIView              *shadowView;



/**
 *  是否开启文字
 */
@property (assign,nonatomic)BOOL                        shouldOpenTextLabel;
/**
 *  是否使用阴影
 */
@property (assign,nonatomic)BOOL                        shouldOpenShadow;

@end
@implementation NickyImageCell

- (void)setShouldOpenShadow:(BOOL)shouldOpenShadow{
    if (_shouldOpenShadow!=shouldOpenShadow){
        _shouldOpenShadow = shouldOpenShadow;
        self.shadowView.hidden = !shouldOpenShadow;
    }
}
- (void)setShouldOpenTextLabel:(BOOL)shouldOpenTextLabel{
    if (_shouldOpenTextLabel != shouldOpenTextLabel){
        _shouldOpenTextLabel = shouldOpenTextLabel;
        self.titleLabel.hidden = !shouldOpenTextLabel;
    }
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView];
//        [self.contentView addSubview:self.shadowView];
//        [self.contentView addSubview:self.titleLabel];
        
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.frame;
}

- (UIView *)shadowView{
    if (!_shadowView){
        _shadowView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 60, self.bounds.size.width, 60)];
        CAGradientLayer *gradient = [CAGradientLayer layer];  //设置渐变颜色
        gradient.frame = _shadowView.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[UIColor colorWithWhite:0 alpha:0].CGColor,
                           (id)[UIColor colorWithWhite:0 alpha:.6].CGColor,nil];
        
        //设置渐变颜色方向
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(0,1);
        [_shadowView.layer insertSublayer:gradient atIndex:0];
    }
    return _shadowView;
}
- (UIImageView *)imageView{
    if (!_imageView){
        _imageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}
- (UILabel *)titleLabel{
    if (!_titleLabel){
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, self.contentView.frame.size.height-45, self.contentView.frame.size.width - 40, 30)];
        _titleLabel.textColor = [UIColor whiteColor];
//        _titleLabel.shadowColor = [UIColor blackColor];
//        _titleLabel.shadowOffset = CGSizeMake(1, 1);
//        _titleLabel.font = [UIFont systemFontOfSize:kDYTextSmallSize];
    
    }
    return _titleLabel;
}
@end

@interface NickyImageScrollView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong,nonatomic)UICollectionViewFlowLayout      *collectionViewLayout;

@property (assign,nonatomic)NSInteger                       fakeCurrentPage;

@end


@implementation NickyImageScrollView

@synthesize scrollTimeInterval = _scrollTimeInterval;
@synthesize imageArray = _imageArray;
@synthesize textArray = _textArray;
#define IS_MULTIPLY (self.imageArray.count>1)
- (void)dealloc{
//    NSLog(@"scroll dealloc");
}
- (NSTimeInterval)scrollTimeInterval{
    if (!_scrollTimeInterval){
        _scrollTimeInterval = 3.0;
    }
    return _scrollTimeInterval;
}
- (void)setScrollTimeInterval:(NSTimeInterval)scrollTimeInterval{
    _scrollTimeInterval = scrollTimeInterval;
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
    if (scrollTimeInterval==-1){
        return;
    }
//    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollTimeInterval target:self selector:@selector(imageScrollDidNextPage:) userInfo:nil repeats:YES];
    __weak __typeof(self)weakSelf = self;
    self.scrollTimer = [NSTimer nickytsuiScheduledTimerWithTimeInterval:self.scrollTimeInterval block:^{
        [weakSelf imageScrollDidNextPage:nil];
    } repeats:YES];
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame imageLoadMode:NickyImageScrollViewAsyncDownloadMode];
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame imageLoadMode:(NickyImageScrollViewMode)loadMode{
    self = [super initWithFrame:frame];
    if (self){
        self.loadMode = loadMode;
        
        [self addSubview:self.collectionView];
        [self addSubview:self.pageControl];
        self.pageControl.center = CGPointMake(self.center.x, self.bounds.size.height - 10);
        
        __weak __typeof(self)weakSelf = self;
        self.scrollTimer = [NSTimer nickytsuiScheduledTimerWithTimeInterval:self.scrollTimeInterval block:^{
            [weakSelf imageScrollDidNextPage:nil];
        } repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self.scrollTimer forMode:UITrackingRunLoopMode];
        
    }
    return self;
}
- (void)killImageScrollView{
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
    [self removeFromSuperview];
    self.delegate = nil;
}
- (void)startTimer{
    if ([self.scrollTimer isValid]){
        [self.scrollTimer setFireDate:[NSDate date]];
    }
}
- (void)stopTimer{
    if ([self.scrollTimer isValid]){
        [self.scrollTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)resumeTimer{
    if ([self.scrollTimer isValid]) {
        [self.scrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.scrollTimeInterval]];
    }
}
- (void)imageScrollDidNextPage:(id)sender{
    NSInteger page = (NSInteger)(self.collectionViewLayout.collectionView.contentOffset.x/self.collectionViewLayout.collectionView.bounds.size.width);
    [self.collectionViewLayout.collectionView setContentOffset:CGPointMake((page+1)*self.collectionView.bounds.size.width, 0) animated:YES];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NickyImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:nickyImageScrollViewCell forIndexPath:indexPath];
    cell.imageView.contentMode = self.imageContentMode;
    cell.contentView.contentMode = self.imageContentMode;
    if (self.textArray.count){
        cell.titleLabel.text = self.textArray[indexPath.item];
    }
    switch (self.loadMode) {
        case NickyImageScrollViewAsyncDownloadMode:
        {   //异步下载执行
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[indexPath.item]] placeholderImage:self.placeImage];
        }
            break;
        case NickyImageScrollViewLoadBundleMode:
        {
            cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.item]];
        }
            break;
        default:
            break;
    }
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.bounds.size;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageArray.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    NSInteger section = IS_MULTIPLY?maxNumber:1;
    return section;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.canShowPreView){
        NickyImageCell *cell = (NickyImageCell*)[collectionView cellForItemAtIndexPath:indexPath];
        // 获取当前视图位于window的位置
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGRect windowFrame = [window convertRect:self.frame fromView:self.superview];
        __weak __typeof(self)weakSelf = self;
        [NickyImageScrollPreView showWithImages:self.imageArray originalFrame:windowFrame originalImage:cell.imageView.image currentNumber:indexPath.item superCollectionView:self.collectionView didFinishBlock:^(NSInteger endIndex) {
            [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:endIndex inSection:IS_MULTIPLY?maxNumber/2:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }willMoveToRect:^CGRect(NSInteger index) {
            return windowFrame;
        }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(nickyImageScrollView:didSelectedAtIndexPath:)]){
        [self.delegate nickyImageScrollView:self didSelectedAtIndexPath:indexPath];
    }
}
- (UICollectionView *)collectionView{
    if (!_collectionView){
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.collectionViewLayout];
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[NickyImageCell class] forCellWithReuseIdentifier:nickyImageScrollViewCell];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
    }
    return _collectionView;
}
- (UICollectionViewFlowLayout *)collectionViewLayout{
    if (!_collectionViewLayout){
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionViewLayout.scrollDirection = 1;
    }
    return _collectionViewLayout;
}


-(UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor=[UIColor  whiteColor];
    }
    return _pageControl;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self resumeTimer];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSInteger page = (NSInteger)(self.collectionViewLayout.collectionView.contentOffset.x/self.collectionViewLayout.collectionView.bounds.size.width);
    if (self.fakeCurrentPage != page){
        self.fakeCurrentPage = page;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = (NSInteger)(self.collectionViewLayout.collectionView.contentOffset.x/self.collectionViewLayout.collectionView.bounds.size.width);
    if (self.fakeCurrentPage != page){
        self.fakeCurrentPage = page;
    }
}
- (void)setFakeCurrentPage:(NSInteger)fakeCurrentPage{
    _fakeCurrentPage = fakeCurrentPage;
    if (self.imageArray && self.imageArray.count > 0){
        self.currentPage = _fakeCurrentPage % self.imageArray.count;
        if (self.delegate && [self.delegate respondsToSelector:@selector(nickyImageScrollView:didEndScrollAtIndex:)]){
            [self.delegate nickyImageScrollView:self didEndScrollAtIndex:self.currentPage];
        }
    }
    
}
- (void)setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;
    self.pageControl.currentPage = _currentPage;
    if(self.imageArray.count){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPage inSection:IS_MULTIPLY?maxNumber/2:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = [imageArray copy];
    if(_imageArray.count){
        self.pageControl.numberOfPages=_imageArray.count;
        self.pageControl.frame = ({
            CGRect frame = self.pageControl.frame;
            frame.size.width =[self.pageControl sizeForNumberOfPages:_imageArray.count].width;
            frame.size.height =[self.pageControl sizeForNumberOfPages:_imageArray.count].height;
            
            frame;
        });
        if (self.shouldSetMargin){
            self.pageControl.frame = CGRectMake(self.frame.size.width - self.marginRightAndBottom.x - self.pageControl.frame.size.width, self.frame.size.height - self.marginRightAndBottom.y - self.pageControl.frame.size.height, self.pageControl.frame.size.width, self.pageControl.frame.size.height);
        }
        [self setScrollTimeInterval:_scrollTimeInterval];
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:IS_MULTIPLY?maxNumber/2:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

    }
}
- (void)settingImageArray:(NSArray *)imageArray{
    [self setImageArray:imageArray];
}
- (NSArray *)imageArray{
    return _imageArray;
}
- (void)setImageContentMode:(UIViewContentMode)imageContentMode{
    _imageContentMode = imageContentMode;
    [self.collectionView reloadData];
}

- (void)setPageControlY:(CGFloat)pageControlY{
    _pageControlY = pageControlY;
    self.pageControl.center = CGPointMake(self.pageControl.center.x, _pageControlY);
}

- (void)setPageControlX:(CGFloat)pageControlX{
    _pageControlX = pageControlX;
    self.pageControl.center = CGPointMake(_pageControlX, self.pageControl.center.y);
}
@end
