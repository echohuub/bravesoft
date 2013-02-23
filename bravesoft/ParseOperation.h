//
//  ParseOperation.h
//  bravesoft
//
//  Created by And.He on 13-1-28.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ArrayBlock)(NSMutableArray *);

@class Photo;
@interface ParseOperation : NSOperation<NSXMLParserDelegate>
{
    ArrayBlock _completionHandler;
    NSData *_parseToData;
    NSArray *_elementsToParse;
    Photo *_photo;
    BOOL _storingCharacterData;
    NSMutableArray *_resultArray;
    NSMutableString *_workingPropertyString;
}

@property (nonatomic, copy) ArrayBlock completionHandler;
@property (nonatomic, retain) NSData *parseToData;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, assign) BOOL storingCharacterData;
@property (nonatomic, retain) NSMutableArray *resultArray;
@property (nonatomic, retain) NSMutableString *workingPropertyString;

- (id)initWithData:(NSData *)parseToData completionHandler:(ArrayBlock)completionHandler;
@end
