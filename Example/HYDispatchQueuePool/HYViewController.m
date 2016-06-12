//
//  HYViewController.m
//  HYDispatchQueuePool
//
//  Created by fangyuxi on 06/08/2016.
//  Copyright (c) 2016 fangyuxi. All rights reserved.
//

#import "HYViewController.h"
#import "HYDispatchQueuePool.h"

@interface HYViewController ()

@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (NSInteger index = 0; index < 100000; ++index) {
     
        dispatch_queue_t queue = [HYDispatchQueuePool queueWithPriority:DISPATCH_QUEUE_PRIORITY_HIGH];
        dispatch_async(queue, ^{
            
            NSLog(@"%ld", index);
        });
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
