//
//  ViewController.h
//  Othello
//
//  Created by USER on 2014/02/21.
//  Copyright (c) 2014年 USER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OthelloViewController : UIViewController{
    NSInteger _segm;
}
@property (nonatomic) NSInteger segm;
@property (strong, nonatomic) UIButton *Titlebtn;
@property (strong, nonatomic) UIButton *Restartbtn;
@property (strong, nonatomic) UIButton *Passbtn;
@property (strong, nonatomic) UIButton *Animebtn;
@property (strong, nonatomic) UIButton *Kaihoubtn;
@property (strong, nonatomic) UIButton *Mattabtn;
@property (strong, nonatomic) UILabel *Blacklbl;
@property (strong, nonatomic) UILabel *Whitelbl;
@property (strong, nonatomic) UILabel *Tesuulbl;
@property (strong, nonatomic) UILabel *Maetelbl;

@end
