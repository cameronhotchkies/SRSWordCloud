//
//  SRSWordCloudView.m
//  SRSWordCloud
//
//  Created by Cameron Hotchkies on 4/30/12.
//  Copyright 2012 Srs Biznas. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SRSWordCloudView.h"
#import "SRSRankedWord.h"
@implementation SRSWordCloudView

@synthesize wordList;

- (void)setWordList:(NSMutableArray *)wl
{
    if (wordList != nil)
    {
        [wordList release];
    }
    
    wordList = [wl retain];
    ldRect = CGRectZero;
    [self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        ldRect = CGRectZero;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (CGRectEqualToRect(self.frame, ldRect) == YES)
    {
        return;
    }
    else 
    {
        ldRect = self.frame;
    }
    
    CGFloat startY = self.frame.size.height - 18;
    CGFloat runningX = 0;
    CGFloat runningY = startY;
    
    // Remove all subviews
    [self setSubviews:[NSArray array]];
    
    NSInteger min, max;
    min = INTMAX_MAX;
    max = 0;
    
    CGFloat FONTMIN = 10;
    CGFloat FONTMAX = 30;
    CGFloat FONTSCALE = FONTMAX - FONTMIN;
    
    for (SRSRankedWord* rw in self.wordList)
    {
        if (rw.rank > max)
        {
            max = rw.rank;
        }
        
        if (rw.rank < min)
        {
            min = rw.rank;
        }
    }
    
    NSInteger denom = (FONTMAX - FONTMIN) != 0 ? (FONTMAX - FONTMIN) : 1;
    
    CGFloat constant = log(max - (min - 1))/ denom;
    
    NSInteger scale = max - min;
    NSInteger nextLine = 18;
    
    NSInteger i = 0;
    
    CGRect dr = dirtyRect;
    
    NSMutableArray* fs = nil;
    
    if (wordSizes == nil)
    {
        fs = [NSMutableArray array];
    }
    else 
    {
        fs = wordSizes;
    }
    
    // Drawing code here.
    for (SRSRankedWord* rw in self.wordList)
    {
        
        CGFloat fSize = 0;
        
        //fSize = (((rw.rank - min) /scale) * FONTSCALE) + FONTMIN;
        
        if (wordSizes == nil)
        {
            CGFloat s = log(rw.rank - (min - 1))/constant + FONTMIN;
            NSNumber* n = [NSNumber numberWithFloat:s];
            [fs addObject:n];
        }
        
        fSize = [[fs objectAtIndex:i] floatValue];
        i++;
        
        if (fSize > nextLine)
        {
            nextLine = fSize;
        }
        
        CGFloat thisWidth = [self widthForText:rw.word andFontSize:fSize] + 10;
        if (runningX + thisWidth > self.frame.size.width)
        {
            runningX = 0;
            runningY -= nextLine;
        }
        CGRect rect = CGRectMake(runningX, runningY, 200, 18);
        
        NSTextView* rwv = [[NSTextView alloc] initWithFrame:rect];
        [rwv setString:rw.word];
        [rwv setBackgroundColor:[NSColor clearColor]];
        [rwv setTextColor:[NSColor whiteColor]];
       
        
        NSFont *f = [NSFont systemFontOfSize:fSize];
        
        [rwv setFont:f];
        
        [self addSubview:rwv];
        
        runningX += thisWidth;
    }
    
    if (self.wordList != nil && wordSizes == nil)
    {
        wordSizes = [fs retain];;
    }
    
}

- (CGFloat)widthForText:(NSString*) text andFontSize:(CGFloat)size
{
    NSFont *f = [NSFont systemFontOfSize:size];
    NSTextStorage *textStorage = [[[NSTextStorage alloc]
                                   initWithString:text] autorelease];
    NSTextContainer *textContainer = [[[NSTextContainer alloc]
                                       initWithContainerSize: NSMakeSize(200, FLT_MAX)] autorelease];
    NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init]
                                      autorelease];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    [textStorage addAttribute:NSFontAttributeName value:f
                        range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    (void) [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager
            usedRectForTextContainer:textContainer].size.width;
}

@end
