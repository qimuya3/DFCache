/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Alexander Grebenyuk (github.com/kean).
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "DFTask.h"


/*! Regulates execution of DFTask objects. Similar to NSOperationQueue. However, it's much easier to implement your concurrent tasks using DFTask rather than NSOperation because of more comprehensive semantics.
 
 @discussion One of the main task queue features is a great performance (especially compared to NSOperationQueue). It is written entirely on top of grand central dispatch.
 @discussion In order to get absolute best performance from DFTaskQueue your tasks should implement  - (NSUInteger)hash and - (BOOL)isEqual: methods.
 @warning DFTaskQueue has an absolute minimum synchronization. All queue methods must be called from the main thread.
 */
@interface DFTaskQueue : NSObject

/*! The maximum number of concurrent tasks that the queue can execute. Setting the new value does not affect tasks that are already executing.
 */
@property (nonatomic) NSUInteger maxConcurrentTaskCount;

/*! Settings suspended property either suspends or resumes execution of tasks. Suspending a queue does not stop tasks that are already executing.
 */
@property (nonatomic, getter = isSuspended) BOOL suspended;

/*! Returns a new set of tasks currently in the queue.
 */
@property (nonatomic, readonly) NSOrderedSet *tasks;

/*! Adds the specified task to the queue. Queue holds strong reference to the task until task is finished and completion callback is called.
 */
- (void)addTask:(DFTask *)task;

/*! Sends cancel message to all tasks currently in the queue. 
 */
- (void)cancelAllTasks;

@end


@interface DFTaskQueue (Convenience)

- (void)addTaskWithBlock:(void (^)(DFTask *task))block;

@end