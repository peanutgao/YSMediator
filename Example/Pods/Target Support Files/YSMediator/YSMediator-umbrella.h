#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "YSMapModel.h"
#import "YSMediator+Router.h"
#import "YSMediator+TargetAction.h"
#import "YSMediator+Tools.h"
#import "YSMediator+Transition.h"
#import "YSMediator.h"

FOUNDATION_EXPORT double YSMediatorVersionNumber;
FOUNDATION_EXPORT const unsigned char YSMediatorVersionString[];

