//
//  NickyImageScrollView.m
//  NickyScrollImageView
//
//  Created by NickyTsui on 15/12/26.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import "NickyImageScrollView.h"
#import "NickyImagePreView.h"
#import <UIImageView+WebCache.h>

static NSInteger const      maxNumber = 10;
static NSString *const      nickyImageScrollViewCell = @"nickyImageScrollViewCell";

@interface NickyImageCell : UICollectionViewCell

@property (strong,nonatomic)UIImageView         *imageView;

@end
@implementation NickyImageCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.frame;
}

- (UIImageView *)imageView{
    if (!_imageView){
        _imageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}
@end

@interface NickyImageScrollView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong,nonatomic)UICollectionView                *collectionView;

@property (strong,nonatomic)UICollectionViewFlowLayout      *collectionViewLayout;

@property (assign,nonatomic)NSInteger                       fakeCurrentPage;

@end


@implementation NickyImageScrollView

@synthesize scrollTimeInterval = _scrollTimeInterval;

- (void)dealloc{
    NSLog(@"check Dealloc");
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame imageLoadMode:NickyImageScrollViewAsyncDownloadMode];
    return self;
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
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollTimeInterval target:self selector:@selector(imageScrollDidNextPage:) userInfo:nil repeats:YES];
}
- (instancetype)initWithFrame:(CGRect)frame imageLoadMode:(NickyImageScrollViewMode)loadMode{
    self = [super initWithFrame:frame];
    if (self){
        self.loadMode = loadMode;
        
        [self addSubview:self.collectionView];
        [self addSubview:self.pageControl];
        self.pageControl.center = CGPointMake(self.center.x, self.bounds.size.height - 10);
        
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollTimeInterval target:self selector:@selector(imageScrollDidNextPage:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self.scrollTimer forMode:UITrackingRunLoopMode];
        
    }
    return self;
}
- (void)killImageScrollView{
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
    [self removeFromSuperview];
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
    switch (self.loadMode) {
        case NickyImageScrollViewAsyncDownloadMode:
        {   //异步下载执行 Async Download Method
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
    return maxNumber;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.canShowPreView){
        NickyImageCell *cell = (NickyImageCell*)[collectionView cellForItemAtIndexPath:indexPath];
        // 获取当前视图位于window的位置
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGRect windowFrame = [window convertRect:self.frame fromView:self.superview];
        __weak __typeof(self)weakSelf = self;
        [NickyImagePreView showWithImages:self.imageArray originalFrame:windowFrame originalImage:cell.imageView.image currentNumber:indexPath.item superCollectionView:self.collectionView didFinishBlock:^(NSInteger endIndex) {
            [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:endIndex inSection:maxNumber/2] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }];
        return;
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
    if (self.imageArray){
        self.currentPage = _fakeCurrentPage % self.imageArray.count;
    }
    
}
- (void)setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;
    self.pageControl.currentPage = _currentPage;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPage inSection:maxNumber/2] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = [imageArray copy];
    if(_imageArray.count){
        self.pageControl.numberOfPages=_imageArray.count;
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:maxNumber/2] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}
- (void)setImageContentMode:(UIViewContentMode)imageContentMode{
    _imageContentMode = imageContentMode;
    [self.collectionView reloadData];
}

- (void)setPageControlY:(CGFloat)pageControlY{
    _pageControlY = pageControlY;
    self.pageControl.center = CGPointMake(self.center.x, _pageControlY);
}
@end
