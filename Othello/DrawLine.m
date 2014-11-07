//
//  DrawLine.m
//  Othello
//
//  Created by USER on 2014/02/21.
//  Copyright (c) 2014年 USER. All rights reserved.
//

#import "DrawLine.h"

@implementation DrawLine

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
{
 NSLog(@"drawRect");
 //枠の色や太さの設定
 
    UIScreen *sc = [UIScreen mainScreen];
    CGRect rrr = sc.bounds;
    float xx = rrr.size.width/2;
    float yy = rrr.size.height/2-50;
    
 CGContextRef context = UIGraphicsGetCurrentContext();
 CGContextSetRGBFillColor(context,
 0,0.392,0, 1.0);
 CGContextSetRGBStrokeColor(context,
 0.0, 0.0, 0.0, 1.0);
 CGContextSetLineWidth(context, 1.0);
 
 //描画
 for (int x=0;x<=7;x++){
     for (int y=0;y<=7;y++){
         CGRect naka = CGRectMake(xx+30*(x-4) ,yy+30*(y-4),30, 30);
         CGContextAddRect(context,naka);
         CGContextFillPath(context);
 
 
         CGRect waku = CGRectMake(xx+30*(x-4) ,yy+30*(y-4),30, 30);
         CGContextAddRect(context,waku);
         CGContextStrokePath(context);
     }
 }
}
























@end
