//
//  HYDispatchQueuePool.m
//  Pods
//
//  Created by fangyuxi on 16/6/8.
//
//

#import "HYDispatchQueuePool.h"

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
    
    __unsafe_unretained _HYQueueItem *preItem;
    __unsafe_unretained _HYQueueItem *nextItem;
}


@end

@implementation _HYQueueItem

@end

@interface _HYQueueItemLinkMap : NSObject //not thread-safe
{
    @package
    __unsafe_unretained _HYQueueItem *_head;
    __unsafe_unretained _HYQueueItem *_tail;
    __unsafe_unretained _HYQueueItem *_current;
    
    CFMutableDictionaryRef _itemsDic;
}

- (void)_insertItemAtHead:(_HYQueueItem *)item;

- (void)_bringItemToHead:(_HYQueueItem *)item;

- (void)_removeItem:(_HYQueueItem *)item;

- (_HYQueueItem *)_removeTailItem;

- (void)_removeAllItem;

- (dispatch_queue_t) getQueue;

@end

@implementation _HYQueueItemLinkMap

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _itemsDic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0,&kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _head = nil;
        _tail = nil;
        _current = nil;
        
        return self;
    }
    return nil;
}

- (void)_insertItemAtHead:(_HYQueueItem *)item
{
    CFDictionarySetValue(_itemsDic, (__bridge const void *)item->key, (__bridge const void *)item);
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
}

- (void)_bringItemToHead:(_HYQueueItem *)item
{
    if (_head == item) return;
    
    if (_tail == item)
    {
        _tail = item->preItem;
        _tail->nextItem = nil;
    }
    else
    {
        item->nextItem->preItem = item->preItem;
        item->preItem->nextItem = item->nextItem;
    }
    
    item->nextItem = _head;
    item->preItem = nil;
    _head->preItem = item;
    _head = item;
}

- (void)_removeItem:(_HYQueueItem *)item
{
    if (item->nextItem)
        item->nextItem->preItem = item->preItem;
    if (item->preItem)
        item->preItem->nextItem = item->nextItem;
    
    if (_head == item)
        _head = item->preItem;
    if (_tail == item)
        _tail = item->preItem;
    
    CFDictionaryRemoveValue(_itemsDic, (__bridge const void *)item->key);
}

- (_HYQueueItem *)_removeTailItem
{
    _HYQueueItem *item = _tail;
    if (_head == _tail)
    {
        _head = _tail = nil;
    }
    else
    {
        _tail = _tail->preItem;
        _tail->nextItem = nil;
    }
    
    CFDictionaryRemoveValue(_itemsDic, (__bridge const void *)_tail->key);
    return item;
}

- (void)_removeAllItem
{
    _head = nil;
    _tail = nil;
    CFDictionaryRemoveAllValues(_itemsDic);
}

- (dispatch_queue_t) getQueue
{
    return nil;
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

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        
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
    if (!_highQueuePools) {
        _highQueuePools = [[_HYQueueItemLinkMap alloc] init];
    }
    return _highQueuePools;
}

- (_HYQueueItemLinkMap *)defaultQueuePools
{
    if (!_highQueuePools) {
        _highQueuePools = [[_HYQueueItemLinkMap alloc] init];
    }
    return _highQueuePools;
}

- (_HYQueueItemLinkMap *)lowQueuePools
{
    if (!_highQueuePools) {
        _highQueuePools = [[_HYQueueItemLinkMap alloc] init];
    }
    return _highQueuePools;
}

- (_HYQueueItemLinkMap *)backgroundQueuePools
{
    if (!_highQueuePools) {
        _highQueuePools = [[_HYQueueItemLinkMap alloc] init];
    }
    return _highQueuePools;
}

@end
