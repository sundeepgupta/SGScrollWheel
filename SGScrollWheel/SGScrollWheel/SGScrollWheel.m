#import "SGScrollWheel.h"
#import <QuartzCore/QuartzCore.h>
#import "SGSection.h"


#define kRadiansOffset M_PI/2 //put 0th section on top instead of on left
#define kTouchTrackWidth 50


static CGFloat deltaAngle;


@interface SGScrollWheel ()
@property CGAffineTransform startTransform;
@property (nonatomic) CGFloat sectionAngleSize;
@property (nonatomic, strong) NSMutableArray *sections;
@property NSInteger previousSectionNumber;
@property NSInteger currentSectionNumber;
@property CGFloat minTouchDistanceFromCenter;
@property CGFloat maxTouchDistanceFromCenter;
@end


@implementation SGScrollWheel

#pragma mark - Initialize

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate numberOfSections:(NSInteger)numberOfSections image:(UIImage *)image {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        self.alpha = 0.3;
        
        self.sectionCount = numberOfSections;
        self.delegate = delegate;
        [self setupAngleSize];
        [self drawWheel];
        [self setupTouchDistanceRange];
        [self setupSections];
        [self setupImage:image];
    }
    return self;
}

- (void)setupAngleSize {
    self.sectionAngleSize = 2*M_PI/self.sectionCount;
}

- (void)drawWheel {
    [self setupContainerView];
    [self addSubview:self.containerView];
}

- (void)setupTouchDistanceRange {
    CGFloat width = self.bounds.size.width;
    self.maxTouchDistanceFromCenter = width/2;
    self.minTouchDistanceFromCenter = self.maxTouchDistanceFromCenter - kTouchTrackWidth;
}


- (void)setupContainerView {
    self.containerView = [[UIView alloc] initWithFrame:self.bounds];
    self.containerView.userInteractionEnabled = NO;
    self.containerView.transform = CGAffineTransformMakeRotation(kRadiansOffset);
    
    self.containerView.backgroundColor = [UIColor lightGrayColor];
    self.containerView.alpha = 0.5;
}


- (void)setupImage:(UIImage *)image {
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.containerView.bounds];
        imageView.image = image;
        [self.containerView addSubview:imageView];
    }
}




#pragma mark - Begin Tracking
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    CGPoint touchPoint = [touch locationInView:self];
    CGFloat distanceFromCenter = [self distanceFromCenterForPoint:touchPoint];
    BOOL shouldTrack = [self shouldTrackForDistanceFromCenter:distanceFromCenter];
    if (shouldTrack) {
        [self updateStartTransformWithPoint:touchPoint];
    }
    return shouldTrack;
}
- (CGFloat)distanceFromCenterForPoint:(CGPoint)point {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat dx = point.x - center.x;
    CGFloat dy = point.y - center.y;
    CGFloat distance = sqrt(dx*dx + dy*dy);
    return distance;
}
- (BOOL)shouldTrackForDistanceFromCenter:(CGFloat)distanceFromCenter {
    BOOL shouldTrack = NO;
    if (distanceFromCenter > self.minTouchDistanceFromCenter  &&  distanceFromCenter < self.maxTouchDistanceFromCenter) {
        shouldTrack = YES;
    }
    return shouldTrack;
}
- (void)updateStartTransformWithPoint:(CGPoint)point {
    CGFloat dx = point.x - self.containerView.center.x;
    CGFloat dy = point.y - self.containerView.center.y;
    deltaAngle = atan2f(dy, dx);
    self.startTransform = self.containerView.transform;
}



#pragma mark - Continue Tracking
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint touchPoint = [touch locationInView:self];
    [self transformToPoint:touchPoint];
    [self updateCurrentSectionNumber];
    return YES;
}


- (void)transformToPoint:(CGPoint)point {
    CGFloat dx = point.x - self.containerView.center.x;
    CGFloat dy = point.y - self.containerView.center.y;
    CGFloat angle = atan2(dy, dx);
    CGFloat angleDifference = angle - deltaAngle;
    self.containerView.transform = CGAffineTransformRotate(self.startTransform, angleDifference);
}

- (void)updateCurrentSectionNumber {
    NSInteger newSectionNumber = [self sectionNumberForCurrentRadians];
    if (newSectionNumber != self.currentSectionNumber) {
        [self updateCurrentSectionNumberWithNewSectionNumber:newSectionNumber];
    }
}


- (NSInteger)sectionNumberForCurrentRadians {
    CGFloat radians = [self currentRadians];
    NSInteger sectionNumber;
    for (NSInteger i = 0; i < self.sections.count; i++) {
        SGSection *section = self.sections[i];
        if ([self radians:radians isInSection:section]) {
            sectionNumber = i;
        }
    }
    
//    NSLog(@"Radians: %f, Section: %i", radians, self.currentSectionNumber);
    return sectionNumber;
}

- (void)updateCurrentSectionNumberWithNewSectionNumber:(NSInteger)newSectionNumber {
    NSInteger sectionNumberDifference = newSectionNumber - self.currentSectionNumber;
    BOOL didTurnClockWise;
    if (sectionNumberDifference == 1  ||  sectionNumberDifference < -1) {
        didTurnClockWise = YES;
    } else {
        didTurnClockWise = NO;
    }
    
    [self updateDelegateDidTurnClockWise:didTurnClockWise];
    
    self.currentSectionNumber = newSectionNumber;
}

- (void)updateDelegateDidTurnClockWise:(BOOL)didTurnClockWise {
    if ([self.delegate respondsToSelector:@selector(wheelDidTurnClockwise:)]) {
        [self.delegate wheelDidTurnClockwise:didTurnClockWise];
    }
}



- (BOOL)radians:(CGFloat)radians isInSection:(SGSection *)section {
    BOOL isInSection = NO;
    
    if (section.minValue > 0  &&  section.maxValue < 0) { //anomaly case
        if (radians > section.minValue  ||  radians < section.maxValue) {
            isInSection = YES;
        }
    } else if (radians > section.minValue  &&  radians < section.maxValue) {
        isInSection = YES;
    }
    return isInSection;
}

- (CGFloat)currentRadians {
    CGFloat radians = atan2f(self.containerView.transform.b, self.containerView.transform.a);
    return radians;
}



#pragma mark - Sections
- (void)setupSections {
    self.sections = [NSMutableArray arrayWithCapacity:self.sectionCount];
    if (self.sectionCount%2 == 0) {
        [self buildEvenNumberOfSections];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Odd number of wheel sections not supported yet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)buildEvenNumberOfSections {
    CGFloat midValue = kRadiansOffset;
    for (NSInteger i = 0; i < self.sectionCount; i++) {
        SGSection *section = [self sectionWithMidValue:midValue andSectionNumber:i];
        
        if (section.maxValue > M_PI) {
            midValue = -M_PI;
            section.midValue = midValue;
            section.maxValue = -section.minValue;
        }
        midValue += self.sectionAngleSize;
        
        [self.sections addObject:section];
        NSLog(@"Created section: %@", section);
    }
}


- (SGSection *)sectionWithMidValue:(CGFloat)midValue andSectionNumber:(NSInteger)sectionNumber {
    SGSection *section = [SGSection new];
    section.midValue = midValue;
    section.minValue = midValue - self.sectionAngleSize/2;
    section.maxValue = midValue + self.sectionAngleSize/2;
    section.sectionNumber = sectionNumber;
    return section;
}



@end
