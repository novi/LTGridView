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
    BOOL _editing;
    BOOL _editingAnimation;
}

- (UIView*)_prepareViewWithIndex:(NSUInteger)index;

@end

@implementation LTGridViewBase

@synthesize viewClass = _viewClass;
@synthesize layoutSubviewsEnabled;
@synthesize gridViewDelegate;
@synthesize itemCount = _itemCount;

@synthesize editing = _editing;

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

-(void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if ((_editing && !editing) || (!_editing && editing)) {
        _editing = editing;
        _editingAnimation = animated;
        [self setNeedsLayout];
    }
}


-(void)reloadData
{
    _itemCount = [self.gridViewDelegate gridViewItemCount:self];
    _contentsUpdated = YES;
    [self setNeedsLayout];
}

-(void)reloadDataWithIndex:(NSUInteger)index
{
    for (UIView* view in self.visibleViews) {
        if (view.tag == index) {
            // has view of index
            // remove current view
            [self enQueueReuseableView:view];
            // create new view updated
            UIView* newone = [self _prepareViewWithIndex:index];
            newone.frame = view.frame;
            [self insertSubview:newone aboveSubview:view];
            [view removeFromSuperview];
            break;
        }
    }
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

	//view.frame = CGRectZero;
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

- (UIButton*)_prepareDeleteButtonWithIndex:(NSUInteger)index
{
    UIButton* button;
    
    for (UIButton* btn in [self.subviews reverseObjectEnumerator]) {
        if ([btn isKindOfClass:[UIButton class]]) {
            if (btn.tag == index) {
                [btn removeFromSuperview];
                button = btn;
                break;
            }
        }
    }
    
    if (!button) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"grid_deletebutton.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(_deleteButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, 32, 32);
    }
    
    button.tag = index;
    //[button setTitle:[NSString stringWithFormat:@"%d", index] forState:UIControlStateNormal];
    
    if (_editingAnimation) {
        button.alpha = 0.0;
    } else {
        button.alpha = 1.0;
    }
    
    return button;
}

- (void)_removeDeleteButtonWithIndex:(NSUInteger)index
{
    // remove delete buttons
    for (UIButton* button in [self.subviews reverseObjectEnumerator]) {
        if ([button isKindOfClass:[UIButton class]]) {
            if (button.tag == index) {
                [button removeFromSuperview];
#if kLTGridViewLogDebug
                NSLog(@"Delete button removed: %d", index);
#endif
                break;
            }
        }
    }
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
        [self _removeDeleteButtonWithIndex:removeView.tag];
        [removeView removeFromSuperview];
    }
    
    if (_contentsUpdated) {
        for (UIButton* button in [self.subviews reverseObjectEnumerator]) {
            if ([button isKindOfClass:[UIButton class]]) {
                [button removeFromSuperview];
            }
        }
    }
    
    /*
    // Editing support (delete buttons)
    NSMutableArray* removeDeleteButtonIndexes = [NSMutableArray array];
    for (UIButton* button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            NSNumber* index = [NSNumber numberWithUnsignedInteger:button.tag];
            if (! [toShowIndexes containsObject:index]) {
                [removeDeleteButtonIndexes addObject:index];
            }
        }
    }
    for (NSNumber* index in removeDeleteButtonIndexes) {
        [self _removeDeleteButtonWithIndex:[index unsignedIntegerValue]];
    }
    */
    
    
    for (NSNumber* indexObj in toShowIndexes) {
        NSUInteger index = [indexObj unsignedIntegerValue];
        UIView* view = [self _prepareViewWithIndex:index];
        [self addSubview:view];
        [self bringSubviewToFront:view];
    }
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:_viewClass]) {
            view.frame = [self gridViewFrameWithIndex:view.tag];
            
            if (self.editing) {
                UIButton* button = [self _prepareDeleteButtonWithIndex:view.tag];
                [self insertSubview:button aboveSubview:view];
                button.center = view.frame.origin;
            }
        }
    }
    
    // Editing support
    if (self.editing && _editingAnimation) {
        [UIView animateWithDuration:0.3 animations:^{
            for (UIButton* button in self.subviews) {
                if ([button isKindOfClass:[UIButton class]]) {
                    button.alpha = 1.0;
                    _editingAnimation = NO;
                }
            }
        }];
    } else if (!self.editing && _editingAnimation) {
        [UIView animateWithDuration:0.3 animations:^{
            for (UIButton* button in self.subviews) {
                if ([button isKindOfClass:[UIButton class]]) {
                    button.alpha = 0.0;
                    _editingAnimation = NO;
                }
            }
        } completion:^(BOOL finished) {
            for (UIButton* button in self.subviews) {
                if ([button isKindOfClass:[UIButton class]]) {
                    [button removeFromSuperview];
                }
            }
        }];
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

- (void)_deleteButtonSelected:(UIButton*)button
{
    if ([self.gridViewDelegate respondsToSelector:@selector(gridView:deleteButtonTappedWithIndex:)]) {
        [self.gridViewDelegate gridView:self deleteButtonTappedWithIndex:button.tag];
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
