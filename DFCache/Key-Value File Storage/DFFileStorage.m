// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).

#import "DFCachePrivate.h"
#import "DFFileStorage.h"

@implementation DFFileStorage {
    NSFileManager *_fileManager;
}

- (instancetype)initWithPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    if (self = [super init]) {
        if (!path.length) {
            [NSException raise:NSInvalidArgumentException format:@"Attempting to initialize storage without directory path"];
        }
        _fileManager = [NSFileManager defaultManager];
        _path = path;
        if (![_fileManager fileExistsAtPath:_path]) {
            [_fileManager createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:error];
        }
    }
    return self;
}

- (instancetype)init {
    [NSException raise:NSInternalInconsistencyException format:@"Please use designated initialzier"];
    return nil;
}

- (NSData *)dataForKey:(NSString *)key {
    return key ? [_fileManager contentsAtPath:[self pathForKey:key]] : nil;
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
    if (data && key) {
        [_fileManager createFileAtPath:[self pathForKey:key] contents:data attributes:nil];
    }
}

- (void)removeDataForKey:(NSString *)key {
    if (key) {
        [_fileManager removeItemAtPath:[self pathForKey:key] error:nil];
    }
}

- (void)removeAllData {
    [_fileManager removeItemAtPath:_path error:nil];
    [_fileManager createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSString *)filenameForKey:(NSString *)key {
    const char *string = [key UTF8String];
    return _dwarf_cache_sha1(string, (uint32_t)strlen(string));
}

- (NSString *)pathForKey:(NSString *)key {
    return key ? [_path stringByAppendingPathComponent:[self filenameForKey:key]] : nil;
}

- (NSURL *)URLForKey:(NSString *)key {
    return key ? [NSURL fileURLWithPath:[self pathForKey:key]] : nil;
}

- (BOOL)containsDataForKey:(NSString *)key {
    return key ? [_fileManager fileExistsAtPath:[self pathForKey:key]] : NO;
}

- (_dwarf_cache_bytes)contentsSize {
    _dwarf_cache_bytes size = 0;
    NSArray *contents = [self contentsWithResourceKeys:@[NSURLFileAllocatedSizeKey]];
    for (NSURL *fileURL in contents) {
        NSNumber *fileSize;
        [fileURL getResourceValue:&fileSize forKey:NSURLFileAllocatedSizeKey error:nil];
        size += [fileSize unsignedLongLongValue];
    }
    return size;
}

- (NSArray *)contentsWithResourceKeys:(NSArray *)keys {
    NSURL *rootURL = [NSURL fileURLWithPath:_path isDirectory:YES];
    return [_fileManager contentsOfDirectoryAtURL:rootURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ %p> { usage: %@; files: %lu }", [self class], self, _dwarf_bytes_to_str(self.contentsSize), (unsigned long)[self contentsWithResourceKeys:nil].count];
}

@end
