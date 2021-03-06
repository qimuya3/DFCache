// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).

#import "DFCache+Tests.h"
#import <XCTest/XCTest.h>

@interface TDFCache_Extensions : XCTestCase

@end

@implementation TDFCache_Extensions {
    DFCache *_cache;
}

- (void)setUp {
    [super setUp];
    
    _cache = [[DFCache alloc] initWithName:[self _generateCacheName]];
}

- (void)tearDown {
    [super tearDown];
    
    [_cache removeAllObjects];
    _cache = nil;
}

#pragma mark - Read (Batch)

- (void)testBatchCachedDataForKeysAsynchronous {
    NSDictionary *strings;
    [_cache storeStringsWithCount:5 strings:&strings];
    [_cache.memoryCache removeAllObjects];
    NSArray *keys = [strings allKeys];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"read"];
    [_cache batchCachedDataForKeys:keys completion:^(NSDictionary *batch) {
        for (NSString *key in keys) {
            XCTAssertNotNil(batch[key]);
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testBatchCachedDataForKeysSynchronous {
    NSDictionary *strings;
    [_cache storeStringsWithCount:5 strings:&strings];
    [_cache.memoryCache removeAllObjects];
    NSArray *keys = [strings allKeys];
    
    NSDictionary *batch = [_cache batchCachedDataForKeys:keys];
    for (NSString *key in keys) {
        XCTAssertNotNil(batch[key]);
    }
}

- (void)testBatchCachedObjectsForKeysAsynchronous {
    NSDictionary *strings;
    [_cache storeStringsWithCount:5 strings:&strings];
    NSArray *keys = [strings allKeys];
    [_cache.memoryCache removeObjectForKey:keys[3]];
    [_cache.memoryCache removeObjectForKey:keys[4]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"read"];
    [_cache batchCachedObjectsForKeys:keys completion:^(NSDictionary *batch) {
        for (NSString *key in keys) {
            XCTAssertTrue([batch[key] isEqualToString:strings[key]]);
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testBatchCachedObjectsForKeysAsynchronousMemoryCacheEmpty {
    NSDictionary *strings;
    [_cache storeStringsWithCount:5 strings:&strings];
    NSArray *keys = [strings allKeys];
    [_cache.memoryCache removeAllObjects];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"read"];
    [_cache batchCachedObjectsForKeys:keys completion:^(NSDictionary *batch) {
        for (NSString *key in keys) {
            XCTAssertTrue([batch[key] isEqualToString:strings[key]]);
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testBatchCachedObjectsForKeysSynchronous {
    NSDictionary *strings;
    [_cache storeStringsWithCount:5 strings:&strings];
    NSArray *keys = [strings allKeys];
    [_cache.memoryCache removeObjectForKey:keys[3]];
    [_cache.memoryCache removeObjectForKey:keys[4]];
    
    NSDictionary *batch = [_cache batchCachedObjectsForKeys:keys];
    for (NSString *key in keys) {
        XCTAssertTrue([batch[key] isEqualToString:strings[key]]);
    }
}

- (void)testBatchCachedObjectsForKeysSynchronousMemoryCacheEmpty {
    NSDictionary *strings;
    [_cache storeStringsWithCount:5 strings:&strings];
    NSArray *keys = [strings allKeys];
    [_cache.memoryCache removeAllObjects];
    
    NSDictionary *batch = [_cache batchCachedObjectsForKeys:keys];
    for (NSString *key in keys) {
        XCTAssertTrue([batch[key] isEqualToString:strings[key]]);
    }
}

- (void)testFirstCachedObjectForKeys {
    NSDictionary *strings;
    [_cache storeStringsWithCount:5 strings:&strings];
    NSArray *keys = [strings allKeys];
    
    [_cache removeObjectForKey:keys[0]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"read"];
    [_cache firstCachedObjectForKeys:keys completion:^(id object, NSString *key) {
        XCTAssertTrue([key isEqualToString:keys[1]]);
        XCTAssertTrue([object isEqualToString:strings[keys[1]]]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testFirstCachedObjectForKeysFromDisk {
    NSDictionary *strings;
    NSArray *keys;
    [_cache storeStringsWithCount:5 strings:&strings];
    [_cache.memoryCache removeAllObjects];
    keys = [strings allKeys];

    [_cache removeObjectForKey:keys[0]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"read"];
    [_cache firstCachedObjectForKeys:keys completion:^(id object, NSString *key) {
        XCTAssertTrue([key isEqualToString:keys[1]]);
        XCTAssertTrue([object isEqualToString:strings[keys[1]]]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

#pragma mark - Helpers

- (NSString *)_generateCacheName {
    static NSUInteger index = 0;
    index++;
    return [NSString stringWithFormat:@"_df_test_cache_%lu", (unsigned long)index];
}

- (void)_assertContainsObjectsForKeys:(NSArray *)keys objects:(NSDictionary *)objects {
    for (NSString *key in keys) {
        {
            NSString *object = [_cache.memoryCache objectForKey:key];;
            XCTAssertNotNil(object, @"Memory cache: no object for key %@", key);
            XCTAssertEqualObjects(objects[key], object);
        }
        
        {
            id object = [_cache cachedObjectForKey:key];
            XCTAssertNotNil(object, @"Disk cache: no object for key %@", key);
            XCTAssertEqualObjects(objects[key], object);
        }
    }
}

- (void)_assertDoesntContainObjectsForKeys:(NSArray *)keys {
    for (NSString *key in keys) {
        {
            NSString *object = [_cache.memoryCache objectForKey:key];
            XCTAssertNil(object, @"Memory cache: contains object for key %@", key);
        }
        
        {
            id object = [_cache cachedObjectForKey:key];
            XCTAssertNil(object, @"Disk cache: contains object for key %@", key);
        }
    }
}
 
@end
