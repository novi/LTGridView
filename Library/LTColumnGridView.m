//
//  LTColumnGridView.m
//  LTGridView
//
//  Created by Yusuke Ito on 12/01/17.
//  Copyright 2012-13 Yusuke Ito
//  http://www.opensource.org/licenses/MIT
//

#import "LTColumnGridView.h"

@interface LTColumnGridView()
{
    NSUInteger _colCount;
    //UIEdgeInsets _displayInset; // only bottom and right
}

@end

@implementation LTColumnGridView

@synthesize columnCount = _colCount;

-(void)setColumnCount:(NSUInteger)columnCount
{
    _colCount = columnCount;
    [self setNeedsLayout];
}

-(void)gridViewInit
{
    _colCount = 3;
    _itemSize = CGSizeMake(160, 100);
    _ySpace = 50;
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
    
    CGRect f = CGRectMake(xOffs + _itemSize.width*colIndex + _xSpace * colIndex , rowIndex*(_itemSize.height+_ySpace), _itemSize.width, _itemSize.height);
    
    return CGRectIntegral(CGRectOffset(f, contentFrame.origin.x, contentFrame.origin.y));
}



- (NSArray*)gridViewToShowIndexes
{
    CGPoint offs = self.contentOffset;
    CGFloat pageHeight = self.bounds.size.height;
    
    CGRect visibleFrame = CGRectMake(offs.x, offs.y, self.bounds.size.width, self.bounds.size.height);
    
    NSInteger row = floor((offs.y - pageHeight / 2) / pageHeight) + 1;
    NSInteger itemRow = floor((offs.y - (_itemSize.height+_ySpace) / 2) / (_itemSize.height+_ySpace)) + 1;
    NSInteger itemIndex = itemRow*_colCount;
    
    //NSLog(@"page=%d, row=%d, item=%d", row, itemRow, itemIndex);
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
    
    NSUInteger yCount = (pageHeight+_ySpace)/(_itemSize.height+_ySpace);
    yCount += _colCount;
    
    if (itemIndex >= _colCount) {
        itemIndex -= _colCount;
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
    NSUInteger rowIndex = itemCount == 0 ? 0 : (itemCount-1) / _colCount;
    
    return CGSizeMake(self.frame.size.width, (rowIndex+1)*(_itemSize.height+_ySpace) - _ySpace);
}

-(NSUInteger)gridViewReuseableViewMaxCount
{
    return 20;
}

@end
