/*
 *  Copyright (c) 2014, Parse, LLC. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Parse.
 *
 *  As with any software that integrates with the Parse platform, your use of
 *  this software is subject to the Parse Terms of Service
 *  [https://www.parse.com/about/terms]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */
//
//  CustomPFLoadingView.m
//  Conversa
//
//  BASED ON
//  PFLoadingView.m by Parse
//
//  Created by Edgar Gomez on 3/5/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "Colors.h"
#import "CustomPFLoadingView.h"
#import "../Pods/ParseUI/ParseUI/Classes/Internal/Extensions/PFRect.h"

@interface CustomPFLoadingView ()

@end

@implementation CustomPFLoadingView

#pragma mark -
#pragma mark Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotatePulse
                                                                 tintColor:[Colors greenSearchAnimationColor]
                                                                      size:35.0f];
        [self addSubview:_activityIndicator];
    }
    return self;
}

#pragma mark -
#pragma mark UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGRect bounds = self.bounds;
    
    CGFloat viewsInset = 4.0f;
    CGFloat startX = floorf((CGRectGetMaxX(bounds)
                             - CGRectGetWidth(_activityIndicator.frame)
                             - viewsInset)
                            / 2.0f);
    
    CGRect activityIndicatorFrame = PFRectMakeWithSizeCenteredInRect(_activityIndicator.frame.size, bounds);
    activityIndicatorFrame.origin.x = startX;
    _activityIndicator.frame = activityIndicatorFrame;
}

@end
