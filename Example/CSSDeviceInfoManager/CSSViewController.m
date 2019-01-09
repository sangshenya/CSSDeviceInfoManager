//
//  CSSViewController.m
//  CSSDeviceInfoManager
//
//  Created by sangshenya on 12/10/2018.
//  Copyright (c) 2018 sangshenya. All rights reserved.
//

#import "CSSViewController.h"
#import "CSSDeviceInfoManager.h"

@interface CSSViewController ()

@end

@implementation CSSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //获取iOS idfa
    NSString *idfa = [CSSDeviceInfoManager sharedInstance].idfa;
    NSLog(@"idfa:%@",idfa);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
