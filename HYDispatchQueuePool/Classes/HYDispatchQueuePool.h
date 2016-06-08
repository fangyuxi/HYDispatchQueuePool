//
//  HYDispatchQueuePool.h
//  Pods
//
//  Created by fangyuxi on 16/6/8.
//
//

/**
 *  GCD QUEUE 的线程池，根据CPU核心数量，创建合适的串行队列，替代系统的并发队列，
 
    解决了当有大量的并发队列的时候，抢夺主线程的的资源，导致界面卡顿
 */

#import <Foundation/Foundation.h>

@interface HYDispatchQueuePool : NSObject

@property (nonatomic, copy, readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name;

/**
*  Get A Serial Queue
*
*  @param priority
                    DISPATCH_QUEUE_PRIORITY_HIGH
                    DISPATCH_QUEUE_PRIORITY_DEFAULT
                    DISPATCH_QUEUE_PRIORITY_LOW
                    DISPATCH_QUEUE_PRIORITY_BACKGROUND
*
*  @return
*/

- (dispatch_queue_t) queueWithPriority:(NSInteger)priority;

@end
