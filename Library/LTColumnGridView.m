//
//  LTColumnGridView.m
//  YomimonoApp1
//
//  Created by 伊藤 祐輔 on 12/01/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LTColumnGridView.h"

@interface LTColumnGridView()
{
    NSUInteger _colCount;
    CGSize _itemSize;
    CGFloat _vSpace;
    CGFloat _xSpace;
    //UIEdgeInsets _displayInset; // only bottom and right
}

@end

@implementation LTColumnGridView

@synthesize itemSize = _itemSize;
@synthesize columnCount = _colCount;
@synthesize xSpace = _xSpace;
@synthesize ySpace = _vSpace;

-(void)gridViewInit
{
    _colCount = 3;
    _itemSize = CGSizeMake(160, 100);
    _vSpace = 50;
    _xSpace = 30;
    //_displayInset = UIEdgeInsetsMake(0, 50, 0, 50);
}


- (CGRect)gridViewFrameWithIndex:(NSUInteger)index
{
    NSUInteger colIndex = index % _colCount;
    NSUInteger rowIndex = index / _colCount;
    
    CGRect bounds = self.bounds; // self.bounds contains scroll offset
    bounds.origin = CGPointZero;
    
    CGRect contentFrame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsZero);
    
    //CGFloat xspace = (contentFrame.size.width-(_itemSize.width*_colCount))/(_colCount-1);
    CGFloat widthAll = _itemSize.width*_colCount + _xSpace * (_colCount-1);
    CGFloat xOffs = (bounds.size.width - widthAll) * 0.5;
    
    CGRect f = CGRectMake(xOffs + _itemSize.width*colIndex + _xSpace * colIndex , rowIndex*(_itemSize.height+_vSpace), _itemSize.width, _itemSize.height);
    
    return CGRectIntegral(CGRectOffset(f, contentFrame.origin.x, contentFrame.origin.y));
}



- (NSArray*)gridViewToShowIndexes
{
    CGPoint offs = self.contentOffset;
    CGFloat pageHeight = self.bounds.size.height;
    
    CGRect visibleFrame = CGRectMake(offs.x, offs.y, self.bounds.size.width, self.bounds.size.height);
    
    NSInteger row = floor((offs.y - pageHeight / 2) / pageHeight) + 1;
    NSInteger itemRow = floor((offs.y - (_itemSize.height+_vSpace) / 2) / (_itemSize.height+_vSpace)) + 1;
    NSInteger itemIndex = itemRow*_colCount;
    
    NSLog(@"row=%d, %d,%d", row, itemRow, itemIndex);
    if (itemIndex < 0) {
        itemIndex = 0;
    }
    
    NSMutableArray* indexes = [NSMutableArray arrayWithCapacity:self.gridViewReuseableViewMaxCount];
    /*for (int i = 0; i < _itemCount; i++) {
     CGRect f = [self _viewFrameWithIndex:i];
     if (CGRectIntersectsRect(f, visibleFrame)) {
     [indexes addObject:[NSNumber numberWithUnsignedInteger:i]];
     }
     }*/
    
    NSUInteger yCount = (pageHeight+_vSpace)/(_itemSize.height+_vSpace);
    yCount += _colCount;
    
    if (itemIndex >= 3) {
        itemIndex -= 3;
    }
    
    for (int i = itemIndex; i < itemIndex + (_colCount*yCount); i++) {
        CGRect f = [self gridViewFrameWithIndex:i];
        if (self.itemCount > i && CGRectIntersectsRect(f, visibleFrame)) {
            [indexes addObject:[NSNumber numberWithUnsignedInteger:i]];
        }
    }
    
    return indexes;
}

-(CGSize)gridViewContentSize
{
    NSUInteger itemCount = self.itemCount;
    NSUInteger rowIndex = itemCount == 0 ? 0 : itemCount / _colCount;
    
    return CGSizeMake(self.frame.size.width, (rowIndex+1)*(_itemSize.height+_vSpace) - _vSpace);
}

-(NSUInteger)gridViewReuseableViewMaxCount
{
    return 20;
}

@end
