//
//  UIAppearance+Swift.h
//  Stepic
//
//  Created by Alexander Karpov on 12.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIAppearance_Swift)
/// @param containers An array of Class<UIAppearanceContainer>
+ (instancetype)appearanceWhenContainedWithin: (NSArray *)containers;
@end
