//
//  ViewController.m
//  TestAnimation
//
//  Created by 银星智能 on 2021/1/12.
//

#import "ViewController.h"
#import "AnimationView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AnimationView * view = [[AnimationView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:view];
}


@end
