//
//  GAScrollViewItem.m
//  GAScrollView
//
//  Created by Graphic-one on 17/3/12.
//  Copyright © 2017年 Graphic-one. All rights reserved.
//

#import "GAScrollViewItem.h"
#import "GAScrollView.h"

#define GA_HAS_YYIMAGE 
#define GA_HAS_SDWEBIMAGE
#define GA_HAS_AFNETWORKING

#if __has_include (<UIImageView+YYWebImage.h>)
#import <UIImageView+YYWebImage.h>
#elif __has_include ("UIImageView+YYWebImage.h")
#import "UIImageView+YYWebImage.h"
#else
#undef GA_HAS_YYIMAGE
#endif

#if __has_include (<UIImage+AFNetworking.h>)
#import <UIImage+AFNetworking.h>
#elif __has_include ("UIImage+AFNetworking.h")
#import "UIImage+AFNetworking.h"
#else
#undef GA_HAS_SDWEBIMAGE
#endif

#if __has_include (<UIImageView+WebCache.h>)
#import <UIImageView+WebCache.h>
#elif __has_include ("UIImageView+WebCache.h")
#import "UIImageView+WebCache.h"
#else
#undef GA_HAS_AFNETWORKING
#endif


#pragma mark - 
///< Double processor cache (Memory & Disk)
@interface _CacheHandle : NSObject
+ (nullable UIImage* )getImage:(NSString* )url;
+ (BOOL)saveImage:(NSData* )data url:(NSString* )url toDisk:(BOOL)isNeedSaveDisk;
@end

@implementation _CacheHandle
static NSMapTable* _mapTable;
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mapTable = [[NSMapTable alloc] init];
    });
}

+ (NSString* )tmpPath{
    return [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
}

+ (UIImage *)getImage:(NSString *)url{
    if (!url || [url isEqual:(id)kCFNull]) return nil;
    
    NSString* file = [[self tmpPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",url.hash]];
    if ([_mapTable objectForKey:url]) {//Memory
        return [_mapTable objectForKey:url];
    }else if ([[NSFileManager defaultManager] fileExistsAtPath:file]){//Disk
        NSData* data = [NSData dataWithContentsOfFile:file];
        [_mapTable setObject:[UIImage imageWithData:data scale:[UIScreen mainScreen].scale] forKey:url];
        return [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
    }else{
        return nil;
    }
}

+ (BOOL)saveImage:(NSData *)data
              url:(NSString *)url
           toDisk:(BOOL)isNeedSaveDisk
{
    if (!data || [data isEqual:(id)kCFNull])  return NO;
    if (!url  || [url isEqual:(id)kCFNull]) return NO;
    
    NSString* file = [[self tmpPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",url.hash]];
    
    [_mapTable setObject:[UIImage imageWithData:data scale:[UIScreen mainScreen].scale] forKey:url];//Memory
    
    if (isNeedSaveDisk) {
        return [data writeToFile:file atomically:YES];//Disk
    }else{
        return [_mapTable objectForKey:url] != nil;
    }
}

@end


#pragma mark -

@implementation _GAScrollViewItemModel
+ (instancetype)modelWithTitle:(NSString *)title
                          path:(NSString *)path
                         image:(NSData *)image
{
    _GAScrollViewItemModel* model = [_GAScrollViewItemModel new];
    model.title = title;
    model.path  = path;
    model.image = image;
    return model;
}
@end



#pragma mark -

@interface GAScrollViewItem ()
@property (nonatomic,strong) GAScrollViewConfiguration* config;

@property (nonatomic,strong) UIImageView* imgView;
@property (nonatomic,strong) UILabel* tleLabel;
@end

@implementation GAScrollViewItem
{
    UIImage* _placeholderImage;
    BOOL _isDone;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:({
            _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
            _imgView;
        })];
        [self.contentView addSubview:({
            _tleLabel = [UILabel new];
            _tleLabel.backgroundColor = [UIColor clearColor];
            _tleLabel;
        })];
    }
    return self;
}

+ (instancetype)returnReuseCollectionCell:(UICollectionView* )collectionView
                                indexPath:(NSIndexPath* )indexPath
                            configuration:(GAScrollViewConfiguration* )config
{
    GAScrollViewItem* cell = [collectionView dequeueReusableCellWithReuseIdentifier:GAScrollViewItemIdentifier forIndexPath:indexPath];
    cell.config = config;
    return cell;
}

- (void)setModel:(_GAScrollViewItemModel *)model{
    _model = model;
    
    if (_config.isNeedTitleLabel && _tleLabel) _tleLabel.text = model.title;
    
    if (model.image && model.image != (id)kCFNull && model.image.length > 0) {
        _imgView.image = [UIImage imageWithData:model.image];
    }else if (model.path && model.path.length > 0){
        
        switch (_config.cacheScheme) {
            case GACacheImageScheme_YYImage:{
#ifdef GA_HAS_YYIMAGE
                [self _usingYYWebImage:_imgView model:model];
#else
                if(DEBUG) NSAssert(false, @" GAScrollView:You must have YYImage ");
                [self _usingAutoScheme:_imgView model:model];
#endif
                break;
            }
            case GACacheImageScheme_SDWebImage:{
#ifdef GA_HAS_SDWEBIMAGE
                [self _usingSDWebImage:_imgView model:model];
#else
                if(DEBUG) NSAssert(false, @" GAScrollView:You must have SDWebImage ");
                [self _usingAutoScheme:_imgView model:model];
#endif
                break;
            }
            case GACacheImageScheme_AFNetworking:{
#ifdef GA_HAS_AFNETWORKING
                [self _usingAFNetworking:_imgView model:model];
#else
                if(DEBUG) NSAssert(false, @" GAScrollView:You must have AFNetworking ");
                [self _usingAutoScheme:_imgView model:model];
#endif
                break;
            }
            case GACacheImageScheme_GAScrollView:{
                [self _usingGAScrollView:_imgView model:model];
                break;
            }
            case GACacheImageScheme_Auto:{
                [self _usingAutoScheme:_imgView model:model];
                break;
            }
                
            default:
                [self _usingAutoScheme:_imgView model:model];
                break;
        }
        
    }else{
        if (_placeholderImage && _placeholderImage != (id)kCFNull) {
            [_imgView setImage:_placeholderImage];
        }
    }
}

- (void)setConfig:(GAScrollViewConfiguration *)config{
    _config = config;
    
    if (config.placeholderImage && config.placeholderImage != (id)kCFNull) {
        _placeholderImage = config.placeholderImage;
    }else if (config.colors && config.colors.count > 0){
        _placeholderImage = [self _convertWithColors:config.colors];
    }else{
        _placeholderImage = [self _convertWithColors:@[[self _gradientLayerStartColor],[self _gradientLayerEndColor]]];
    }
    _imgView.image = _placeholderImage;
    
    if (config.isNeedTitleLabel) {
        if (!CGRectIsEmpty(config.titleFrame)) {
            _tleLabel.frame = config.titleFrame;
        }else{
            CGFloat titleHeight = config.titleHeight;
            _tleLabel.frame = (CGRect){{0,self.contentView.bounds.size.height - titleHeight},{self.contentView.bounds.size.width,titleHeight}};
        }
        _tleLabel.textAlignment = config.titleAlignment;
        _tleLabel.font = [UIFont fontWithName:config.fontName size:config.fontSize];
        _tleLabel.textColor = config.titleColor;
    }else{
        if (_tleLabel && _tleLabel.superview) {
            [_tleLabel removeFromSuperview];
        }
    }
}

#pragma mark - 

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
- (void)_usingYYWebImage:(UIImageView* )imageView model:(_GAScrollViewItemModel* )model{
    [self _performSelector:@selector(setImageWithURL:placeholder:) target:imageView withObjects:[NSURL URLWithString:model.path],_placeholderImage,nil];
}

- (void)_usingSDWebImage:(UIImageView* )imageView model:(_GAScrollViewItemModel* )model{
    [self _performSelector:@selector(sd_setImageWithURL:placeholderImage:) target:imageView withObjects:[NSURL URLWithString:model.path],_placeholderImage,nil];
}

- (void)_usingAFNetworking:(UIImageView* )imageView model:(_GAScrollViewItemModel* )model{
    [self _performSelector:@selector(setImageWithURL:placeholderImage:) target:imageView withObjects:[NSURL URLWithString:model.path],_placeholderImage,nil];
}
#pragma clang diagnostic pop

- (void)_performSelector:(SEL)aSelector target:(id)target withObjects:(id)object,... {
    if (!target || target == (id)kCFNull) return;
    
    NSMethodSignature* signature = [[target class] instanceMethodSignatureForSelector:aSelector];
    if (!signature) {
        NSAssert(!DEBUG, @" GAScrollView:You don't have included the framework of the method(***%@***) ",NSStringFromSelector(aSelector));
    }else{
        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:signature];
        invo.target = target;
        invo.selector = aSelector;
        
        if (object) {
            [invo setArgument:&object atIndex:2];
            
            va_list ap;
            id argument;
            va_start(ap, object);
            int index = 0;
            while ((argument = va_arg(ap, id))) {
                [invo setArgument:&argument atIndex:(index + 3)];
                index++;
            }
            va_end(ap);
        }
        [invo invoke];
    }
}

- (void)_usingGAScrollView:(UIImageView* )imageView model:(_GAScrollViewItemModel* )model{
    if ([_CacheHandle getImage:model.path]) {
        [_imgView setImage:[_CacheHandle getImage:model.path]];
        _isDone = YES;
    }else{
        if (!_isDone) {
            NSURLSession* shareSession = [NSURLSession sharedSession];
            NSURLSessionTask* task = [shareSession dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:model.path]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    _isDone = NO;
                }else{
                    [_CacheHandle saveImage:data url:model.path toDisk:_config.isNeedDiskCache];
                    UIImage* image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_imgView setImage:image];
                        _isDone = YES;
                    });
                }
            }];
            [task resume];
        }
    }
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunreachable-code"
- (void)_usingAutoScheme:(UIImageView* )imageView model:(_GAScrollViewItemModel* )model{
#ifdef GA_HAS_YYIMAGE
    [self _usingYYWebImage:_imgView model:model]; return;
#endif
    
#ifdef GA_HAS_SDWEBIMAGE
    [self _usingSDWebImage:_imgView model:model]; return;
#endif
    
#ifdef GA_HAS_AFNETWORKING
    [self _usingAFNetworking:_imgView model:model]; return;
#endif
    
    [self _usingGAScrollView:_imgView model:model];
}
#pragma clang diagnostic pop

#pragma mark -
- (UIImage* )_convertWithColors:(NSArray<UIColor* >* )colors{
    if (!colors || colors.count == 0) return nil;
    
    UIColor* startColor , *endColor ;
    if (colors.count == 1) {
        startColor = endColor = colors.firstObject;
    }else{
        startColor = colors.firstObject;
        endColor   = colors.lastObject;
    }
    
    CAGradientLayer* layer = [CAGradientLayer new];
    layer.colors = @[
                     (__bridge id)startColor.CGColor,
                     (__bridge id)endColor.CGColor,
                     ];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint   = CGPointMake(0, 0.7);
    layer.frame      = (CGRect){{0,0},{20,20}};
    
    UIGraphicsBeginImageContext(layer.bounds.size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark -  default Value
- (UIColor* )_gradientLayerStartColor{
    return [UIColor colorWithRed:((float)((0x000000 & 0xFF0000) >> 16))/255.0
                           green:((float)((0x000000 & 0xFF00) >> 8))/255.0
                            blue:((float)(0x000000 & 0xFF))/255.0
                           alpha:0.0];
}
- (UIColor* )_gradientLayerEndColor{
    return [UIColor colorWithRed:((float)((0x000000 & 0xFF0000) >> 16))/255.0
                           green:((float)((0x000000 & 0xFF00) >> 8))/255.0
                            blue:((float)(0x000000 & 0xFF))/255.0
                           alpha:0.35];
}

@end


