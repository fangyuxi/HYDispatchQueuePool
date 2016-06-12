//
//  HYDispatchQueuePool.m
//  Pods
//
//  Created by fangyuxi on 16/6/8.
//
//

#import "HYDispatchQueuePool.h"
#import <libkern/OSAtomic.h>

static OSSpinLock mutexLock;

#pragma mark lock

static inline void lock()
{
    OSSpinLockLock(&mutexLock);
}

static inline void unLock()
{
    OSSpinLockUnlock(&mutexLock);
}


///////////////////////////////////////////////////////////////////////////////
#pragma mark linked map used for store queue
///////////////////////////////////////////////////////////////////////////////

@interface _HYQueueItem : NSObject // not thread-safe
{
    @package
    NSString *key;
    NSDate *createDate;
    NSDate *lastAccessDate;
    dispatch_queue_t queue;
    
    _HYQueueItem *preItem;
    _HYQueueItem *nextItem;
}

- (instancetype)initWithPriority:(NSInteger)priority;

@end

@implementation _HYQueueItem

- (instancetype)initWithPriority:(NSInteger)priority
{
    self = [super init];
    if (self)
    {
        
        createDate = [NSDate date];
        lastAccessDate = createDate;
        NSString *name = [NSString stringWithFormat:@"com.HYDispatchQueuePool.%lu", (unsigned long)[self hash]];
        key = name;
        queue = dispatch_queue_create([name UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(priority, 0));
        preItem = nil;
        nextItem = nil;
        
        return self;
    }
    return nil;
}
@end

@interface _HYQueueItemLinkMap : NSObject //not thread-safe
{
    @package
     _HYQueueItem *_head;
     _HYQueueItem *_tail;
     _HYQueueItem *_current;
    
    NSUInteger _queueCount;
}

- (void)_insertItemAtHead:(_HYQueueItem *)item;

- (dispatch_queue_t) getQueue;

@end

@implementation _HYQueueItemLinkMap

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _head = nil;
        _tail = nil;
        _current = nil;
        _queueCount = 0;
        
        return self;
    }
    return nil;
}

- (void)_insertItemAtHead:(_HYQueueItem *)item
{
    if (_head)
    {
        _head->preItem = item;
        item->nextItem = _head;
        item->preItem = nil;
        _head = item;
    }
    else
    {
        _head = item;
        _tail = item;
        _head = _tail;
    }
    
    _queueCount += 1;
    
    _current = _head;
}

- (dispatch_queue_t) getQueue
{
    lock();
    
    _HYQueueItem *item = _current;
    _HYQueueItem *newOne = item->nextItem;
    if (!newOne)
    {
        _current = _head;
        item = _current;
    }
    else
    {
        _current = newOne;
        item = newOne;
    }
    
    unLock();
    return item->queue;
}

@end

@interface HYDispatchQueuePool ()

@property (nonatomic, strong) _HYQueueItemLinkMap *highQueuePools;
@property (nonatomic, strong) _HYQueueItemLinkMap *defaultQueuePools;
@property (nonatomic, strong) _HYQueueItemLinkMap *lowQueuePools;
@property (nonatomic, strong) _HYQueueItemLinkMap *backgroundQueuePools;

@end

@implementation HYDispatchQueuePool{

    
}

#pragma mark make a queue pool

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        mutexLock = OS_SPINLOCK_INIT;
    }
    return self;
}

#pragma mark get a queue

+ (dispatch_queue_t) queueWithPriority:(NSInteger)priority
{
    static dispatch_once_t onceToken;
    static HYDispatchQueuePool *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    switch (priority)
    {
        case DISPATCH_QUEUE_PRIORITY_HIGH:
        {
            return [sharedInstance.highQueuePools getQueue];
        }
        case DISPATCH_QUEUE_PRIORITY_DEFAULT:
        {
            return [sharedInstance.defaultQueuePools getQueue];
        }
        case DISPATCH_QUEUE_PRIORITY_LOW:
        {
            return [sharedInstance.lowQueuePools getQueue];
        }
        case DISPATCH_QUEUE_PRIORITY_BACKGROUND:
        {
            return [sharedInstance.backgroundQueuePools getQueue];
        }
        default:
            return [sharedInstance.defaultQueuePools getQueue];
    }
    
    return nil;
}

#pragma mark getter

- (_HYQueueItemLinkMap *)highQueuePools
{
    lock();
    if (!_highQueuePools) {
        _highQueuePools = [[_HYQueueItemLinkMap alloc] init];
        
        NSUInteger activityProcesserCount = [[NSProcessInfo processInfo] activeProcessorCount];
        for (NSUInteger index = 0; index < activityProcesserCount; ++index) {
            
            _HYQueueItem *item = [[_HYQueueItem alloc] initWithPriority:DISPATCH_QUEUE_PRIORITY_HIGH];
            [_highQueuePools _insertItemAtHead:item];
        }
    }
    unLock();
    
    return _highQueuePools;
}

- (_HYQueueItemLinkMap *)defaultQueuePools
{
    lock();
    if (!_defaultQueuePools) {
        _defaultQueuePools = [[_HYQueueItemLinkMap alloc] init];
        
        NSUInteger activityProcesserCount = [[NSProcessInfo processInfo] activeProcessorCount];
        for (NSUInteger index = 0; index < activityProcesserCount; ++index) {
            
            _HYQueueItem *item = [[_HYQueueItem alloc] initWithPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
            [_defaultQueuePools _insertItemAtHead:item];
        }
        
    }
    unLock();
    return _defaultQueuePools;
}

- (_HYQueueItemLinkMap *)lowQueuePools
{
    lock();
    if (!_lowQueuePools) {
        _lowQueuePools = [[_HYQueueItemLinkMap alloc] init];
    }
    unLock();
    return _lowQueuePools;
}

- (_HYQueueItemLinkMap *)backgroundQueuePools
{
    lock();
    if (!_backgroundQueuePools) {
        _backgroundQueuePools = [[_HYQueueItemLinkMap alloc] init];
    }
    unLock();
    return _backgroundQueuePools;
}

@end
