//
//  FirstViewController.h
//  LTGridView
//
//  Created by 伊藤 祐輔 on 12/01/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTColumnGridView.h"

@interface FirstViewController : UIViewController<LTGridViewDelegate>
{
    LTColumnGridView* _testView;
    NSUInteger _count;
}

- (IBAction)update:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *countSlider;


@end
