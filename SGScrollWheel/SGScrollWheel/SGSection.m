//
//  SGSector.m
//  Toastmasters Timer
//
//  Created by Sundeep Gupta on 12/9/2013.
//  Copyright (c) 2013 Sundeep Gupta. All rights reserved.
//

#import "SGSection.h"

@implementation SGSection

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%i  |  %f, %f, %f", self.sectionNumber, self.minValue, self.midValue, self.maxValue];
    return description;
}
@end
