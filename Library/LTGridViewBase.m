//
//  LTGridView.m
//  YomimonoApp1
//
//  Created by 伊藤 祐輔 on 12/01/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LTGridViewBase.h"



@interface LTGridViewBase()
{
    NSUInteger _itemCount;
    
    NSMutableArray* _reuseableViews;
    BOOL _frameChanged;
    BOOL _contentsUpdated;
    Class _viewClass;
}

@end

@implementation LTGridViewBase

@synthesize viewClass = _viewClass;
@synthesize layoutSubviewsEnabled;
@synthesize gridViewDelegate;
@synthesize itemCount = _itemCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pagingEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = YES;
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.contentSize = frame.size;
        
        _reuseableViews = [[NSMutableArray alloc] initWithCapacity:5];
        _frameChanged = YES;
        _viewClass = NULL;
        self.layoutSubviewsEnabled = YES;
        
        [self gridViewInit];
        
#if kLTGridViewBackgroundDebug
        self.backgroundColor = [UIColor grayColor];
#endif
        
    }
    return self;
}

-(void)dealloc
{
    
}

#pragma mark -


-(void)itemCountUpdated
{
    _itemCount = [self.gridViewDelegate gridViewItemCount:self];
    _contentsUpdated = YES;
    [self setNeedsLayout];
}

#pragma mark - Reuseable View

-(UIView * )dequeueReuseableView
{
    UIView* view = [_reuseableViews lastObject];
	[_reuseableViews removeLastObject];
    
#if kLTGridViewLogDebug
    if (!view) {
        NSLog(@"queue is empty");
    }
#endif
	return view;
}

-(void)enQueueReuseableView:(UIView *)view
{
    
    
	if (_reuseableViews.count > [self gridViewReuseableViewMaxCount]) {
#if kLTGridViewLogDebug
        NSLog(@"queue is full, ignored, %d, max:%d", _reuseableViews.count, [self gridViewReuseableViewMaxCount]);
#endif
		return;
	}
    
#if kLTGridViewLogDebug
    NSLog(@"%s:%d", __func__, _reuseableViews.count);
#endif

	view.frame = CGRectZero;
	[_reuseableViews addObject:view];
}


-(NSArray *)visibleViews
{
    NSMutableArray* views = [[NSMutableArray alloc] initWithCapacity:self.subviews.count];
    
    for (UIView* view in self.subviews) {
        // Only specified view class
        if ([view isKindOfClass:_viewClass]) {
            [views addObject:view];
        }
    }
    return views;
}

#pragma mark - View preparation

- (UIView*)_prepareViewWithIndex:(NSUInteger)index
{
    UIView* view = [self.gridViewDelegate gridView:self viewForItemIndex:index];
    //view.frame = [self _viewFrameWithIndex:index];
    view.tag = index; // view's tag is the index
    
#if kLTGridViewBackgroundDebug
    view.backgroundColor = [UIColor colorWithHue:rand()%20/20.0 saturation:rand()%20/20.0 brightness:0.5 alpha:0.3];
#endif
    
    return view;
}


- (void)_createAndLayoutViews
{
    NSArray* showIndexes = [self gridViewToShowIndexes];
    NSMutableArray* toShowIndexes = [showIndexes mutableCopy];    
    NSMutableArray* remainViewIndexes = [NSMutableArray array];
    NSMutableArray* removeViews = [NSMutableArray array];
    
    if (_contentsUpdated) {
#if kLTGridViewLogDebug
        NSLog(@"contents updated");
#endif
        // remove all of views
        for (UIView* view in [self.subviews reverseObjectEnumerator]) {
            if ([view isKindOfClass:_viewClass]) {
                [self enQueueReuseableView:view];
                [view removeFromSuperview];
            }
        }
    }
    
#if kLTGridViewLogDebug
    NSMutableString* logStr = [NSMutableString stringWithFormat:@"\n\n"];
    for (NSNumber* numObj in toShowIndexes) {
        [logStr appendFormat:@"%d ", [numObj unsignedIntegerValue]];
    }
#endif
    
    for (UIView* view in self.subviews) {
        // Only specified view class
        if ([view isKindOfClass:_viewClass]) {
            NSNumber* viewIndex = [NSNumber numberWithUnsignedInteger:view.tag];
            if ([toShowIndexes containsObject:viewIndex]) {
                // already has a view, remain this view
                [remainViewIndexes addObject:viewIndex];
                [toShowIndexes removeObject:viewIndex]; // and remove
            } else {
                [removeViews addObject:view];
            }
        }
    }
    
    
#if kLTGridViewLogDebug
    [logStr appendFormat:@"\nwill create: "];
    for (NSNumber* numObj in toShowIndexes) {
        [logStr appendFormat:@"%d ", [numObj unsignedIntegerValue]];
    }
    [logStr appendFormat:@"\nremain: "];
    for (NSNumber* numObj in remainViewIndexes) {
        [logStr appendFormat:@"%d ", [numObj unsignedIntegerValue]];
    }
     [logStr appendFormat:@"\nremove: "];
    for (UIView* view in removeViews) {
        [logStr appendFormat:@"%d ", view.tag];
    }
    NSLog(@"%@", logStr);
#endif
    
    for (UIView* removeView in removeViews) {
        [self enQueueReuseableView:removeView];
        [removeView removeFromSuperview];
    }
    
    for (NSNumber* indexObj in toShowIndexes) {
        NSUInteger index = [indexObj unsignedIntegerValue];
        UIView* view = [self _prepareViewWithIndex:index];
        [self addSubview:view];
        [self bringSubviewToFront:view];
    }
    
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:_viewClass]) {
            view.frame = [self gridViewFrameWithIndex:view.tag];
        }
    }
}

- (void)_updatedContentSize
{
    self.contentSize = [self gridViewContentSize];
}

#pragma mark - Layouting

-(void)setFrame:(CGRect)frame
{
    CGPoint oldOffset = self.contentOffset;
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    
    if ( ! CGRectEqualToRect(frame, oldFrame)) {
        [self _updatedContentSize];
        _frameChanged = YES;
    }
    
    if (_frameChanged || _contentsUpdated) {
        _frameChanged = NO;
        [self _createAndLayoutViews];
    }
}


-(void)layoutSubviews
{
    //[super layoutSubviews];
    BOOL contentsUpdated = _contentsUpdated;
    
    if (!self.layoutSubviewsEnabled) {
        return;
    }
    
    if (_contentsUpdated) {
        [self _updatedContentSize];
    }
    
    [self _createAndLayoutViews];
    
    if (_contentsUpdated) {
        _contentsUpdated = NO;
    }
    
    /*if (_frameChanged || contentsUpdated) {
        _frameChanged = NO;
        [self _createAndLayoutViews];
    }*/
    
    if ([self.gridViewDelegate respondsToSelector:@selector(gridViewLayoutSubviews:)]) {
        [self.gridViewDelegate gridViewLayoutSubviews:self];
    }
}

#pragma mark - for subclass override

- (void)gridViewInit
{
    [self doesNotRecognizeSelector:_cmd];
}

- (CGSize)gridViewContentSize
{
    [self doesNotRecognizeSelector:_cmd];
    return CGSizeZero;
}

- (CGRect)gridViewFrameWithIndex:(NSUInteger)index
{
    [self doesNotRecognizeSelector:_cmd];
    return CGRectZero;
}

- (NSArray*)gridViewToShowIndexes
{
     [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSUInteger)gridViewReuseableViewMaxCount
{
    [self doesNotRecognizeSelector:_cmd];
    return 1;
}


@end
