//
//  GAScrollViewItem.h
//  GAScrollView
//
//  Created by Graphic-one on 17/3/12.
//  Copyright © 2017年 Graphic-one. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GAScrollViewConfiguration;

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@interface _GAScrollViewItemModel : NSObject
@property (nullable,nonatomic,strong) NSString* title;
@property (nullable,nonatomic,strong) NSString* path;
@property (nullable,nonatomic,strong) NSData* image;
+ (instancetype)modelWithTitle:(nullable NSString* )title path:(nullable NSString* )path image:(nullable NSData* )image;
@end


#pragma mark -

static NSString* const GAScrollViewItemIdentifier = @"__GAScrollViewItemIdentifier";

@interface GAScrollViewItem : UICollectionViewCell

+ (instancetype)returnReuseCollectionCell:(UICollectionView* )collectionView
                                indexPath:(NSIndexPath* )indexPath
                            configuration:(GAScrollViewConfiguration* )config;

@property (nonatomic,strong) _GAScrollViewItemModel* model;

@end

NS_ASSUME_NONNULL_END
