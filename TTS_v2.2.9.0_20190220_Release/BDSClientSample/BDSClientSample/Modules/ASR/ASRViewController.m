//
//  ASRViewController.m
//  BDSClientSample
//
//  Created by baidu on 16/6/24.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "ASRViewController.h"

@interface ASRViewController ()

@end

@implementation ASRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)dismissASR:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
