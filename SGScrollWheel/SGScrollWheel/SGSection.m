#import "SGSection.h"

@implementation SGSection

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%i  |  %f, %f, %f", self.sectionNumber, self.minValue, self.midValue, self.maxValue];
    return description;
}
@end
