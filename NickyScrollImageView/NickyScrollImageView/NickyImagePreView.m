//
//  NickyImagePreView.m
//  NickyScrollImageView
//
//  Created by NickyTsui on 16/1/8.
//  Copyright © 2016年 com.nickyTsui. All rights reserved.
//

#import "NickyImagePreView.h"
#import <UIImageView+WebCache.h>
#define appWindow [UIApplication sharedApplication].keyWindow


static NSString *const cellIdentifier = @"preCell";

@interface NickyImagePreViewCell : UICollectionViewCell <UIScrollViewDelegate>
@property (strong,nonatomic) UIScrollView                         *imageScrollView;
@property (strong,nonatomic) UIImageView                *imageView;
@end

@implementation NickyImagePreViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self.contentView addSubview:self.imageScrollView];
    [self.imageScrollView addSubview:self.imageView];
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageScrollView.frame = self.contentView.bounds;
    if (self.imageView.image){
        self.imageView.frame = [self calFrame:self.imageView.image];
    }
//    self.imageView.frame = self.contentView.bounds;
}
- (UIImageView *)imageView{
    if (!_imageView){
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _imageView.layer.masksToBounds = YES;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}
- (UIScrollView *)imageScrollView{
    if (!_imageScrollView){
        _imageScrollView = [[UIScrollView alloc]init];
        _imageScrollView.maximumZoomScale = 3.0;
        _imageScrollView.minimumZoomScale = 1;
        _imageScrollView.delegate = self;
        _imageScrollView.bounces = YES;
        _imageScrollView.delaysContentTouches = YES;
        _imageScrollView.contentMode = UIViewContentModeScaleToFill;
    }
    return _imageScrollView;
}


-(CGRect)calFrame:(UIImage *)targetImage{
    CGRect superFrame = [UIScreen mainScreen].bounds;
    CGFloat radio = targetImage.size.width/superFrame.size.width;
    CGSize size = CGSizeMake(targetImage.size.width/radio, targetImage.size.height/radio);
    
    CGFloat w = size.width;
    CGFloat h = size.height;
    
    CGFloat superW =superFrame.size.width ;
    CGFloat superH =superFrame.size.height;
    
    CGFloat calW = superW;
    CGFloat calH = superW;
    
    if (w>=h) {
        if(w> superW){
            CGFloat scale = superW / w;
            calW = w * scale;
            calH = h * scale;
            
        }else if(w <= superW){
            
            calW = w;
            calH = h;
        }
        
    }else if(w<h){
        
        CGFloat scale1 = superH / h;
        CGFloat scale2 = superW / w;
        
        BOOL isFat = w * scale1 > superW;
        
        CGFloat scale =isFat ? scale2 : scale1;
        
        if(h> superH){
            calW = w * scale;
            calH = h * scale;
            
        }else if(h <= superH){
            if(w>superW){
                calW = w * scale;
                calH = h * scale;
            }else{
                calW = w;
                calH = h;
            }
            
        }
    }
    CGPoint screenCenter = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    CGFloat x = screenCenter.x - w *.5f;
    CGFloat y = screenCenter.y - h * .5f;
    CGRect frame = (CGRect){CGPointMake(x, y),CGSizeMake(w, h)};
    return frame;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if(scrollView.zoomScale <=1) scrollView.zoomScale = 1.0f;
    
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    [self.imageView setCenter:CGPointMake(xcenter, ycenter)];
}


//2.重新确定缩放完后的缩放倍数
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

#pragma mark - 缩放大小获取方法
-(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height = [_imageScrollView frame].size.height/scale;
    zoomRect.size.width = [_imageScrollView frame].size.width/scale;
    zoomRect.origin.x = center.x - zoomRect.size.width/2;
    zoomRect.origin.y = center.y - zoomRect.size.height/2;
    return zoomRect;
}


@end

@interface NickyImagePreView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *superCollectionView;
}
@property (strong,nonatomic)UICollectionViewFlowLayout  *flowLayout;
@property (strong,nonatomic)UICollectionView            *collectionView;
@property (strong,nonatomic)UIView                      *backgroundView;

@end

@implementation NickyImagePreView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeAction:)];
        
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)closeAction:(id)sender{
    NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:self.collectionView.contentOffset];
    
    NickyImagePreViewCell *currentCell = (NickyImagePreViewCell*)[self.collectionView cellForItemAtIndexPath:currentIndexPath];
    self.originalImage.image = currentCell.imageView.image;
    
    [self addSubview:self.originalImage];
    [self.collectionView removeFromSuperview];
    
    [UIView animateWithDuration:.3 animations:^{
        self.originalImage.frame = self.originalFrame;
        
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        self->superCollectionView.hidden = NO;
        [self removeFromSuperview];
    }];
    
}
+ (instancetype)showWithImages:(NSArray *)images
                 originalFrame:(CGRect)originalFrame
                 originalImage:(UIImage *)originalImage
                 currentNumber:(NSInteger)currentNumber
           superCollectionView:(UICollectionView *)collectionView{
    NickyImagePreView *preView = [[NickyImagePreView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    preView.originalFrame = originalFrame;
    preView.imageArray    = images;
    preView.originalImage.image = originalImage;
    preView->superCollectionView = collectionView;
    preView->superCollectionView.hidden = YES;
    [preView addSubview:preView.backgroundView];
    [preView addSubview:preView.originalImage];
    [appWindow addSubview:preView];
    
    
    [UIView animateWithDuration:.3 animations:^{
        preView.originalImage.frame = preView.bounds;
        preView.backgroundView.alpha = 1;
    
    } completion:^(BOOL finished) {
        preView.collectionView.contentOffset = CGPointMake(currentNumber * preView.collectionView.bounds.size.width, 0);
        [preView addSubview:preView.collectionView];
        [preView.originalImage removeFromSuperview];
    }];
    
    return preView;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.bounds.size;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    __block NickyImagePreViewCell *preCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    preCell.imageScrollView.zoomScale = 1.0;
    [preCell.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[indexPath.item]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        preCell.imageView.frame = [preCell calFrame:image];
    }];
    
    return preCell;
}
- (UICollectionView *)collectionView{
    if (!_collectionView){
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[NickyImagePreViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}
- (UICollectionViewFlowLayout *)flowLayout{
    if (!_flowLayout){
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _flowLayout.scrollDirection = 1;
        _flowLayout.minimumInteritemSpacing = CGFLOAT_MIN;
        _flowLayout.minimumLineSpacing = CGFLOAT_MIN;
    }
    return _flowLayout;
}
- (UIImageView *)originalImage{
    if (!_originalImage){
        _originalImage = [[UIImageView alloc]initWithFrame:self.originalFrame];
        _originalImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _originalImage;
}
- (UIView *)backgroundView{
    if (!_backgroundView){
        _backgroundView = [[UIView alloc]initWithFrame:self.bounds];
        _backgroundView.alpha = 0;
        _backgroundView.backgroundColor = [UIColor blackColor];
    }
    return _backgroundView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
