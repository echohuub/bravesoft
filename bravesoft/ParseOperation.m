//
//  ParseOperation.m
//  bravesoft
//
//  Created by And.He on 13-1-28.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import "ParseOperation.h"
#import "Photo.h"

#define kUrl @"url"
#define kTitle @"title"
#define kAuthor @"author"
#define kEntry @"photo"

@implementation ParseOperation
@synthesize completionHandler=_completionHandler;
@synthesize parseToData=_parseToData;
@synthesize elementsToParse=_elementsToParse;
@synthesize photo=_photo;
@synthesize storingCharacterData=_storingCharacterData;
@synthesize resultArray=_resultArray;
@synthesize workingPropertyString=_workingPropertyString;


- (id)initWithData:(NSData *)parseToData completionHandler:(ArrayBlock)completionHandler;
{
    self = [super init];
    if (self) {
        self.parseToData = parseToData;
        self.completionHandler = completionHandler;
        self.elementsToParse = [NSArray arrayWithObjects:kUrl, kTitle, kAuthor, nil];
    }
    return self;
}

- (void)dealloc
{
    self.completionHandler = nil;
    self.parseToData = nil;
    self.elementsToParse = nil;
    self.photo = nil;
    self.resultArray = nil;
    self.workingPropertyString = nil;
    [super dealloc];
}

- (void)main
{
    self.resultArray = [NSMutableArray array];
    self.workingPropertyString = [NSMutableString string];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.parseToData];
    parser.delegate = self;
    [parser parse];
    if (![self isCancelled]) {
        self.completionHandler(self.resultArray);
    }
    [parser release];
    self.resultArray = nil;
    self.workingPropertyString = nil;
}

#pragma mark - NSXMLParserDelegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:kEntry]) {
        _photo = [[Photo alloc] init];
        if (attributeDict) {
            NSString *key = [[attributeDict keyEnumerator] nextObject];
            [_photo setPhotoId:[[attributeDict objectForKey:key] intValue]];
        }
    }
    self.storingCharacterData = [self.elementsToParse containsObject:elementName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.storingCharacterData) {
        [self.workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (self.photo) {
        if (self.storingCharacterData) {
            NSString *trimmedString = [self.workingPropertyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.workingPropertyString setString:@""];
            if ([elementName isEqualToString:kUrl]) {
                [self.photo setPhotoUrl:trimmedString];
            } else if ([elementName isEqualToString:kTitle]) {
                [self.photo setPhotoTitle:trimmedString];
            } else if ([elementName isEqualToString:kAuthor]) {
                [self.photo setPhotoAuthor:trimmedString];
            }
        }
        if ([elementName isEqualToString:kEntry]) {
            [self.resultArray addObject:self.photo];
            self.photo = nil;
        }
    }
}
@end
