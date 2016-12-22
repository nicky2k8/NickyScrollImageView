//
//  NickyImagePreView.h
//  NickyScrollImageView
//
//  Created by NickyTsui on 16/1/8.
//  Copyright © 2016年 com.nickyTsui. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^nickyPreviewRemoveBlock)(NSInteger endIndex);
typedef CGRect(^nickyPreviewWillRemoveToFrame)(NSInteger index);
@interface NickyImageScrollPreView : UIView
@property (strong,nonatomic)UIImageView     *originalImage;
/**
 *  scrollview原始位置
 */
@property (assign,nonatomic)CGRect          originalFrame;
/**
 *  图片数组
 */
@property (strong,nonatomic)NSArray         *imageArray;

+ (instancetype)showWithImages:(NSArray *)images
                 originalFrame:(CGRect)originalFrame
                 originalImage:(UIImage *)originalImage
                 currentNumber:(NSInteger)currentNumber
           superCollectionView:(UICollectionView *)collectionView
                didFinishBlock:(nickyPreviewRemoveBlock)finishBlock
                willMoveToRect:(nickyPreviewWillRemoveToFrame)originalRectBlock;
@end
