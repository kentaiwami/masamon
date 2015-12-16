//
//  BRAComment.m
//  XlsxReaderWriter
//
//  Created by René BIGOT on 23/09/2015.
//  Copyright © 2015 BRAE. All rights reserved.
//

#import "BRAComment.h"

@implementation BRAComment

- (void)loadAttributes {
    NSDictionary *dictionaryRepresentation = [super dictionaryRepresentation];
    
    _reference = dictionaryRepresentation[@"_ref"];
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionaryRepresentation = [super dictionaryRepresentation].mutableCopy;
    
    dictionaryRepresentation[@"_r"] = _reference;
    
    [super setDictionaryRepresentation:dictionaryRepresentation];
    
    return dictionaryRepresentation;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> : %@", [self class], self, _reference];
}

@end

