#import <UIKit/UIKit.h>


@protocol SGScrollWheelDelegate <NSObject>
@optional
- (void)wheelDidTurnClockwise:(BOOL)didTurnClockwise;
@end


@interface SGScrollWheel : UIControl
@property (weak) id <SGScrollWheelDelegate> delegate;
@property (nonatomic, strong) UIView *containerView;
@property NSInteger sectionCount;

- (id)initWithFrame:(CGRect)frame delegate:(id<SGScrollWheelDelegate>)delegate numberOfSections:(NSInteger)numberOfSections image:(UIImage *)image;
- (void)setupImage:(UIImage *)image;
@end
