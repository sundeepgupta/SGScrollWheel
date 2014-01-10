#import "SGViewController.h"
#import "SGScrollWheel.h"

@interface SGViewController () <SGScrollWheelDelegate>
@property (strong, nonatomic) SGScrollWheel *wheel;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property NSInteger value;
@end


@implementation SGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupScrollWheel];
    [self setupValue];
}

- (void)setupScrollWheel {
    CGRect frame = CGRectMake(0, 0, 250, 250);
    self.wheel = [[SGScrollWheel alloc] initWithFrame:frame delegate:self numberOfSections:12];
    [self.view addSubview:self.wheel];
}

- (void)setupValue {
    self.value = 0;
    [self updateLabel];
}

- (void)updateLabel {
    self.label.text = [NSString stringWithFormat:@"Value: %i", self.value];
}


#pragma mark - Wheel Delegate
- (void)wheelDidTurnClockwise:(BOOL)didTurnClockwise {
    [self updateValueToIncrease:didTurnClockwise];
    [self updateLabel];
}

- (void)updateValueToIncrease:(BOOL)toIncrease {
    if (toIncrease) {
        self.value++;
    } else {
        self.value--;
    }
}


@end
