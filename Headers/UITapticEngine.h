static int const UITapticEngineFeedbackPeek = 1001;
static int const UITapticEngineFeedbackPop = 1002;

#include <UIKit/UIKit.h>

@interface UITapticEngine : NSObject

- (void)actuateFeedback:(int)arg1;
- (void)endUsingFeedback:(int)arg1;
- (void)prepareUsingFeedback:(int)arg1;

@end