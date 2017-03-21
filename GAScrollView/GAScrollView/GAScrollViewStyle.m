//
//  GAScrollViewStyle.m
//  GAScrollView
//
//  Created by Graphic-one on 17/3/12.
//  Copyright © 2017年 Graphic-one. All rights reserved.
//

#import "GAScrollViewStyle.h"

#pragma mark -

@implementation __GAScrollViewStyleDefault
- (void)prepareLayout{
    [super prepareLayout];
    [self _setLayout];
}

- (void)_setLayout{
    self.minimumLineSpacing = self.minimumInteritemSpacing = 0;
    self.itemSize = self.collectionView.bounds.size;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}
@end


#pragma mark -

@implementation __GAScrollViewStyleTranslation
{
    CGFloat         _prevOffset;
    NSIndexPath*    _curIndexPath;
    NSIndexPath*    _movingInIndexPath;
    CGFloat         _difference;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)prepareLayout{
    [super prepareLayout];
    [self _setLayout];
}

- (void)_setLayout{
    self.minimumLineSpacing = self.minimumInteritemSpacing = 0;
    self.itemSize = self.collectionView.bounds.size;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

- (UICollectionViewLayoutAttributes* )layoutAttributesForItemAtIndexPath:(NSIndexPath* )indexPath{
    UICollectionViewLayoutAttributes* attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    [self _transform2LayoutAttributes:attributes];
    return attributes;
}

- (NSArray* )layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray* attributes  = [super layoutAttributesForElementsInRect:rect];
    NSArray* cellIndices = [self.collectionView indexPathsForVisibleItems];
    
    if(cellIndices.count == 0){
        return attributes;
    }else if(cellIndices.count == 1){
        _curIndexPath       = cellIndices.firstObject;
        _movingInIndexPath  = nil;
    }else if(cellIndices.count > 1){
        NSIndexPath* firstIndexPath = cellIndices.firstObject;
        if(firstIndexPath == _curIndexPath){
            _movingInIndexPath  = cellIndices[1];
        }else{
            _movingInIndexPath  = cellIndices.firstObject;
            _curIndexPath       = cellIndices[1];
        }
    }
    
    _difference = self.collectionView.contentOffset.x - _prevOffset;
    _prevOffset = self.collectionView.contentOffset.x;
    
    for(UICollectionViewLayoutAttributes* attribute in attributes){
        [self _transform2LayoutAttributes:attribute];
    }
    return attributes;
}

#pragma mark - calculate Animation
- (void)_transform2LayoutAttributes:(UICollectionViewLayoutAttributes* )layout{
    
}

@end


#pragma mark -

@implementation __GAScrollViewStyleRotating
{
    CGFloat         _prevOffset;
    NSIndexPath*    _curIndexPath;
    NSIndexPath*    _movingInIndexPath;
    CGFloat         _difference;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)prepareLayout{
    [super prepareLayout];
    [self _setLayout];
}

- (void)_setLayout{
    self.minimumLineSpacing = self.minimumInteritemSpacing = 0;
    self.itemSize = self.collectionView.bounds.size;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

- (UICollectionViewLayoutAttributes* )layoutAttributesForItemAtIndexPath:(NSIndexPath* )indexPath{
    UICollectionViewLayoutAttributes* attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    [self _transform2LayoutAttributes:attributes];
    return attributes;
}

- (NSArray* )layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray* attributes  = [super layoutAttributesForElementsInRect:rect];
    NSArray* cellIndices = [self.collectionView indexPathsForVisibleItems];
    
    if(cellIndices.count == 0){
        return attributes;
    }else if(cellIndices.count == 1){
        _curIndexPath       = cellIndices.firstObject;
        _movingInIndexPath  = nil;
    }else if(cellIndices.count > 1){
        NSIndexPath* firstIndexPath = cellIndices.firstObject;
        if(firstIndexPath == _curIndexPath){
            _movingInIndexPath  = cellIndices[1];
        }else{
            _movingInIndexPath  = cellIndices.firstObject;
            _curIndexPath       = cellIndices[1];
        }
    }
    
    _difference = self.collectionView.contentOffset.x - _prevOffset;
    _prevOffset = self.collectionView.contentOffset.x;
    
    for(UICollectionViewLayoutAttributes* attribute in attributes){
        [self _transform2LayoutAttributes:attribute];
    }
    return attributes;
}

#pragma mark - calculate Animation
- (void)_transform2LayoutAttributes:(UICollectionViewLayoutAttributes* )layout{
    
}

@end










