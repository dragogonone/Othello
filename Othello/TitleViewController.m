//
//  TitleViewController.m
//  Othello
//
//  Created by USER on 2014/02/21.
//  Copyright (c) 2014年 USER. All rights reserved.
//
#import "TitleViewController.h"
#import "OthelloViewController.h"

@interface TitleViewController ()

@end

@implementation TitleViewController

@synthesize VSSeg;
@synthesize colSeg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)VSSeg:(id)sender {
    switch(VSSeg.selectedSegmentIndex){
            case 0:
                [colSeg setEnabled:YES];
            break;
            case 1:
                [colSeg setEnabled:NO];
            break;
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OthelloViewController *othello = segue.destinationViewController;
    int _segm;
    switch (VSSeg.selectedSegmentIndex) {
            
        case 0:
            switch(colSeg.selectedSegmentIndex){
                case 0:
                    _segm = 0;//VSCPU　自分は黒
                    break;
                case 1:
                    _segm = 1;//VSCPU　自分は白
                    break;
            }
            break;
            
        case 1:
            _segm = 2;//VSPlayer
            break;
    }
    othello.segm = _segm;
}





















@end
