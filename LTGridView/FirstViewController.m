//
//  FirstViewController.m
//  LTGridView
//
//  Created by 伊藤 祐輔 on 12/01/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"

@implementation FirstViewController
@synthesize countSlider = _countSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _testView = [[LTColumnGridView alloc] initWithFrame:self.view.bounds];
    _testView.viewClass = [UILabel class];
    _testView.gridViewDelegate = self;
    [self.view insertSubview:_testView atIndex:0];
    
    [_testView reloadData];
    
    srandom(self);
    
}

- (void)viewDidUnload
{
    [self setCountSlider:nil];
    [super viewDidUnload];
    _testView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)update:(id)sender
{
    _count = self.countSlider.value;
    NSLog(@"count = %d", _count);
    
    [_testView reloadData];
}

#pragma mark -

-(UIView *)gridView:(LTGridViewBase *)gridView viewForItemIndex:(NSUInteger)index
{
    UILabel* label = (id)[_testView dequeueReuseableView];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:28.0f];
        label.backgroundColor = [UIColor colorWithHue:(random()%100)*1.0/100.0 saturation:.5 brightness:1 alpha:1];
    }
    
    label.text = [NSString stringWithFormat:@"%d", index];
    return label;
}

-(NSUInteger)gridViewItemCount:(LTGridViewBase *)gridView
{
    return _count;
}


@end
