//
//  GAScrollView.m
//  GAScrollView
//
//  Created by Graphic-one on 17/3/12.
//  Copyright © 2017年 Graphic-one. All rights reserved.
//

#import "GAScrollView.h"
#import "GAScrollViewItem.h"
#import "GAScrollViewStyle.h"

@interface NSTimer (GAScrollView)
-(void)pause;
-(void)resume;
@end

@implementation NSTimer (GAScrollView)
-(void)pause{
    if (![self isValid]) return ;
    
    [self setFireDate:[NSDate distantFuture]];
}
-(void)resume{
    if (![self isValid]) return ;
    
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]];
}
@end

#pragma mark - 

@interface GAScrollView () <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) NSArray<_GAScrollViewItemModel* >* models;

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) UIPageControl* pageCtl;
@end

@implementation GAScrollView
{
    NSTimer* _Nullable _timer;
    
    NSUInteger _prevIndex;
    NSUInteger _movingIndex;
}

#pragma mark - Public
+ (instancetype)scrollViewWithFrame:(CGRect)frame
                      configuration:(GAScrollViewConfiguration* )config
                             titles:(nullable NSArray* )titles
                        localImages:(nullable NSArray* )images
                    netWorkIMGPaths:(nullable NSArray* )paths
{
    GAScrollView* scrollView = [[GAScrollView alloc] initWithFrame:frame];
    [scrollView _convertDataSource:titles images:images paths:paths];
    scrollView.config = config;
    return scrollView;
}

#pragma mark - Private
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _settingUI];
    }
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    if (_config.style == GAScrollViewrRunStyleAuto && self.models.count > 1) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)removeFromSuperview{
    if (_timer) {
        [_timer invalidate];
    }
    _timer = nil;
    [super removeFromSuperview];
}

- (void)_settingUI{
    [self addSubview:({
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView;
    })];
    
    [_contentView addSubview:({
        _collectionView = [[UICollectionView alloc] initWithFrame:_contentView.bounds collectionViewLayout:[self _defaultCollectionFlowLayout]];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[GAScrollViewItem class] forCellWithReuseIdentifier:GAScrollViewItemIdentifier];
        _collectionView;
    })];
    [_contentView addSubview:({
        _pageCtl = [[UIPageControl alloc] init];
        _pageCtl.backgroundColor = [UIColor clearColor];
        _pageCtl;
    })];
}

- (void)_convertDataSource:(NSArray* )titles images:(NSArray* )images paths:(NSArray* )paths{
    if (!(images && images.count > 0) && !(paths && paths.count > 0)) return ;
    
    BOOL isLocal, isHasTitles ;
    isLocal = ( images && images.count > 0 ) ? YES : NO;
    if (titles && titles.count > 0) isHasTitles = YES;
    if (isHasTitles && isLocal) NSParameterAssert(titles.count == images.count);
    if (isHasTitles && !isLocal) NSParameterAssert(titles.count == paths.count);
    
    NSUInteger count = isLocal ? images.count : paths.count;
    NSMutableArray* mArr = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        _GAScrollViewItemModel* model = [_GAScrollViewItemModel modelWithTitle:isHasTitles ? titles[i] : nil
                                                                          path:isLocal     ?   nil     : paths[i]
                                                                         image:isLocal     ? images[i] : nil];
        
        [mArr addObject:model];
    }
    
    _models = mArr.copy;
}

#define kDefaultPagePadding 8
#pragma mark - property setting
- (void)setConfig:(GAScrollViewConfiguration *)config{
    _config = config;
    if (!_models || _models == (id)kCFNull || _models.count == 0) return ;
    if (!_config || _config == (id)kCFNull) return ;
    
    _collectionView.bounces = config.isOpenBounces;
    
    UICollectionViewFlowLayout* resultFlowLayout ;
    switch (config.transformStyle) {
        case GAScrollViewTransformStyleDefault:
            resultFlowLayout = [[__GAScrollViewStyleDefault alloc] init];
            break;
        
        case GAScrollViewTransformStyleTranslation:
            resultFlowLayout = [[__GAScrollViewStyleTranslation alloc] init];
            break;
        
        case GAScrollViewTransformStyleRotating:
            resultFlowLayout = [[__GAScrollViewStyleRotating alloc] init];
            break;
        
        default:
            resultFlowLayout = [self _defaultCollectionFlowLayout];
            break;
    }
    _collectionView.collectionViewLayout = resultFlowLayout;
    
    _pageCtl.numberOfPages = _models.count ;
    
    if (_models.count > 1) {
        switch (config.style) {
            case GAScrollViewrRunStyleAutoAndSpringback:{
                _timer = [NSTimer timerWithTimeInterval:_config.timeInterval target:self selector:@selector(_timeMethod:) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
                break;
            }
            case GAScrollViewrRunStyleAuto:{
                _timer = [NSTimer timerWithTimeInterval:_config.timeInterval target:self selector:@selector(_timeMethod:) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
                
                NSMutableArray* mArr = _models.mutableCopy;
                [mArr insertObject:_models.lastObject atIndex:0];
                [mArr addObject:_models.firstObject];
                _models = mArr.copy;
                
                break;
            }
            case GAScrollViewrRunStyleNone:{
                if (_timer)  [_timer invalidate];
                _timer = nil;
                break;
            }
                
            default:
                _timer = [NSTimer timerWithTimeInterval:_config.timeInterval target:self selector:@selector(_timeMethod:) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
                break;
        }
    }else{
        if (_timer)  [_timer invalidate];
        _timer = nil;
    }

    if (!config.isNeedPageController || (config.whenOnlyHidden && _models.count == 1)) {
        [_pageCtl removeFromSuperview];
    }else{
        if (!CGRectIsEmpty(_config.pageFrame)) {
            _pageCtl.frame = _config.pageFrame;
        }else{
            CGSize pageSize = [_pageCtl sizeForNumberOfPages:_pageCtl.numberOfPages];
            switch (_config.pageAlignment) {
                case UIControlContentHorizontalAlignmentCenter:
                    _pageCtl.frame = (CGRect){{0,self.contentView.bounds.size.height - _config.titleHeight},{self.contentView.bounds.size.width,_config.titleHeight}};
                    break;
                    
                case UIControlContentHorizontalAlignmentLeft:
                    _pageCtl.frame = (CGRect){{kDefaultPagePadding,self.contentView.bounds.size.height - _config.titleHeight},{pageSize.width,_config.titleHeight}};
                    break;
                    
                case UIControlContentHorizontalAlignmentRight:
                    _pageCtl.frame = (CGRect){{self.contentView.bounds.size.width - kDefaultPagePadding - pageSize.width,self.contentView.bounds.size.height -_config.titleHeight},{pageSize.width,_config.titleHeight}};
                    break;
                    
                case UIControlContentHorizontalAlignmentFill:
#ifdef DEBUG
    NSAssert(false, @" GAScrollView : Can't forUIControlContentHorizontalAlignmentFill ");
#endif
                    _pageCtl.frame = (CGRect){{0,self.contentView.bounds.size.height - _config.titleHeight},{self.contentView.bounds.size.width,_config.titleHeight}};
                    break;
                    
                default:
                    _pageCtl.frame = (CGRect){{0,self.contentView.bounds.size.height - _config.titleHeight},{self.contentView.bounds.size.width,_config.titleHeight}};
                    break;
            }
        }
        _pageCtl.pageIndicatorTintColor = _config.defaultColor;
        _pageCtl.currentPageIndicatorTintColor = _config.selectedColor;
    }
}
- (void)setTitles:(NSArray *)titles{
    _titles = titles;
    [self _convertDataSource:_titles images:_images paths:_paths];
    self.config = _config;
}
- (void)setImages:(NSArray *)images{
    _images = images;
    [self _convertDataSource:_titles images:_images paths:_paths];
    self.config = _config;
}
- (void)setPaths:(NSArray *)paths{
    _paths = paths;
    [self _convertDataSource:_titles images:_images paths:_paths];
    self.config = _config;
}

#pragma mark - UICollection
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GAScrollViewItem* cell = [GAScrollViewItem returnReuseCollectionCell:collectionView indexPath:indexPath configuration:_config];
    cell.model = self.models[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([_delegate respondsToSelector:@selector(scrollView:currentClickIndex:)]) {
        NSUInteger index = indexPath.row;

        if (_config.style == GAScrollViewrRunStyleAuto && self.models.count > 1) {
            if (indexPath.row == 0) {
                index = (self.models.count - 2) - 1;
            }else if (indexPath.row == (self.models.count - 1)) {
                index = 0;
            }else{
                index = indexPath.row - 1;
            }
        }
        
        [_delegate scrollView:self currentClickIndex:index];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger resultRow = indexPath.row;
    if (_config.style == GAScrollViewrRunStyleAuto && self.models.count > 1) {
        if (indexPath.row == 0) {
            resultRow = (self.models.count - 2) - 1;
        }else if (indexPath.row == self.models.count - 1){
            resultRow = 0;
        }else{
            resultRow = resultRow - 1;
        }
    }
    _movingIndex = resultRow;
    if ([_delegate respondsToSelector:@selector(scrollView:willScrollFrom:to:)] && _prevIndex != _movingIndex) {
        [_delegate scrollView:self willScrollFrom:_prevIndex to:_movingIndex];
    }
}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self _resetCorrectIndex];
    
    float curIndex = (_collectionView.contentOffset.x) / (_collectionView.bounds.size.width);
    if (_pageCtl) {
        if (_config.style == GAScrollViewrRunStyleAuto) {
            _pageCtl.currentPage = roundf(curIndex - 1);
        }else{
            _pageCtl.currentPage = roundf(curIndex);
        }
    }

    NSUInteger tmpIndex = _prevIndex;
    if ((((int)(curIndex * 1000000)) == (((int)curIndex) * 1000000))){
         _prevIndex = curIndex;
        if (_config.style == GAScrollViewrRunStyleAuto && self.models.count > 1) {
            if (curIndex == 0) {
                _prevIndex = (self.models.count - 2) - 1;
            }else if (curIndex == self.models.count - 1){
                _prevIndex = 0;
            }else{
                _prevIndex = curIndex - 1;
            }
        }
    }
    
    if (_prevIndex - _movingIndex == 0) {
        if ([_delegate respondsToSelector:@selector(scrollView:didScrollFrom:to:)] && tmpIndex != _movingIndex) {
            [_delegate scrollView:self didScrollFrom:tmpIndex to:_movingIndex];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_timer) [_timer pause];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_timer) [_timer resume];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self _resetCorrectIndex];
}

#pragma mark - time method
- (void)_timeMethod:(NSTimer* )timer{
    CGFloat curIndex = (_collectionView.contentOffset.x) / (_collectionView.bounds.size.width);
    CGFloat nextIndex = curIndex + 1;
    
    switch (_config.style) {
        case GAScrollViewrRunStyleAutoAndSpringback:{
            if (nextIndex > (self.models.count - 1)) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            }else{
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:nextIndex inSection:0];
                [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            }
            break;
        }
        case GAScrollViewrRunStyleAuto:{
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:nextIndex inSection:0];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            break;
        }
        case GAScrollViewrRunStyleNone:{
            return;
            break;
        }
        default:
            return;
            break;
    }
}

- (void)_resetCorrectIndex{
    if (_config.style == GAScrollViewrRunStyleAuto && self.models.count > 1) {
        float curIndex = (_collectionView.contentOffset.x) / (_collectionView.bounds.size.width);
        if (curIndex == 0) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(self.models.count - 2) inSection:0];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            _pageCtl.currentPage = _pageCtl.numberOfPages - 1;
            return ;
        }else if (curIndex == self.models.count - 1){
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            _pageCtl.currentPage = 0;
            return ;
        }
    }
}

#pragma mark - default layout
- (UICollectionViewFlowLayout* )_defaultCollectionFlowLayout{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = layout.minimumInteritemSpacing = 0;
    layout.itemSize = _contentView.bounds.size;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return layout;
}

@end

#pragma mark -

@implementation GAScrollViewConfiguration
+ (instancetype)quickConfigurationTitleFontSize:(CGFloat)fontSize
                                     titleColor:(UIColor* )titleColor
                              pageSelectedColor:(UIColor* )pageColor
                                          style:(GAScrollViewrRunStyle)style
                                 transformStyle:(GAScrollViewTransformStyle)transformStyle
{
    return [self instanceBannerConfigurationPlaceholderImage:nil orColor:nil needTitle:YES titleHeight:50 titleAlignment:NSTextAlignmentLeft titleFrame:CGRectZero andTitleFontName:nil andTitleFontSize:fontSize andTitleColor:titleColor needPage:YES whenOnlyHidden:YES pageAlignment:UIControlContentHorizontalAlignmentRight pageFrame:CGRectZero andPageDefaultColor:nil andPageSelectedColor:pageColor needDiskCache:YES style:style transformStyle:transformStyle cacheScheme:GACacheImageScheme_Auto timeInterval:1.0 openBounces:YES];
}

+ (instancetype)instanceBannerConfigurationPlaceholderImage:(nullable UIImage* ) placeholderImage
                                                    orColor:(nullable NSArray<UIColor* >* )colors
                                                  needTitle:(BOOL)isNeedTitle
                                                titleHeight:(CGFloat)titleHeight
                                             titleAlignment:(NSTextAlignment)titleAlignment
                                                 titleFrame:(CGRect)titleFrame
                                           andTitleFontName:(nullable NSString* )fontName
                                           andTitleFontSize:(CGFloat)fontSize
                                              andTitleColor:(nullable UIColor* )titleColor
                                                   needPage:(BOOL)isNeedPage
                                             whenOnlyHidden:(BOOL)whenOnlyHidden
                                              pageAlignment:(UIControlContentHorizontalAlignment)pageAlignment
                                                  pageFrame:(CGRect)pageFrame
                                        andPageDefaultColor:(nullable UIColor* )defaultColor
                                       andPageSelectedColor:(UIColor* )selectedColor
                                              needDiskCache:(BOOL)isNeedDiskCache
                                                      style:(GAScrollViewrRunStyle)style
                                             transformStyle:(GAScrollViewTransformStyle)transformStyle
                                                cacheScheme:(GACacheImageScheme)cacheScheme
                                               timeInterval:(NSTimeInterval)timeInterval
                                                openBounces:(BOOL)isOpenBounces
{
    GAScrollViewConfiguration* config = [GAScrollViewConfiguration new];
    
    config.placeholderImage = placeholderImage;
    config.colors = config.placeholderImage ? nil : colors ?: @[[[UIColor grayColor] colorWithAlphaComponent:0.5] , [UIColor whiteColor]];
    
    config.needTitle = isNeedTitle;
    config.titleHeight = titleHeight > 0 ? titleHeight : 50;
    config.titleAlignment = titleAlignment;
    config.titleFrame = titleFrame;

    config.fontName = fontName ?: [UIFont systemFontOfSize:15].fontName;
    config.fontSize = fontSize > 0 ? fontSize : 15;
    config.titleColor = titleColor ?: [UIColor whiteColor];
    
    config.needPage = isNeedPage;
    config.whenOnlyHidden = whenOnlyHidden;
    config.defaultColor = defaultColor ?: [UIColor whiteColor];
    config.selectedColor = selectedColor;
    if (config.pageAlignment == UIControlContentHorizontalAlignmentFill) {
#ifdef DEBUG
        NSAssert(false, @"GAScrollView : Cannot be designated as UIControlContentHorizontalAlignmentFill ");
#endif
        config.pageAlignment = UIControlContentHorizontalAlignmentRight;
    }else{
        config.pageAlignment = pageAlignment;
    }
    config.pageFrame = pageFrame;
    
    config.needDiskCache = isNeedDiskCache;
    config.style = style;
    config.transformStyle = transformStyle;
    config.cacheScheme = cacheScheme;
    config.timeInterval = timeInterval;
    config.openBounces = isOpenBounces;
    
    return config;
}

@end
