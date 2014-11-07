//
//  TitleViewController.h
//  Othello
//
//  Created by USER on 2014/02/21.
//  Copyright (c) 2014年 USER. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TitleViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *colSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *VSSeg;
- (IBAction)VSSeg:(id)sender;


@end
