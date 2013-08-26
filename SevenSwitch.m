//
//  SevenSwitch
//
//  Created by Benjamin Vogelzang on 6/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "SevenSwitch.h"
#import <QuartzCore/QuartzCore.h>

@interface SevenSwitch ()  {
    UIView *_background;
    UIView *_fillView;
    UIView *_knob;
    BOOL _isAnimating;
    BOOL _valueTrackingChanged;
    BOOL _tempOnValue;
    
//    CAShapeLayer *_fillLayer;
//    CAShapeLayer *_backLayer;
}

@property (nonatomic, assign) BOOL editing;

- (void)setup;

@end

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kActiveThumbleWidthDifference = 7.0f;

@implementation SevenSwitch

#pragma mark init Methods

- (id)init {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 51.0f, 31.0f)];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    // use the default values if CGRectZero frame is set
    CGRect initialFrame;
    if (CGRectIsEmpty(frame)) {
        initialFrame = CGRectMake(0.0f, 0.0f, 51.0f, 31.0f);
    }
    else {
        initialFrame = frame;
    }
    self = [super initWithFrame:initialFrame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self setup];
}

/**
 *	Setup the individual elements of the switch and set default values
 */
- (void)setup {
    _isAnimating = NO;
    _borderLineWidth = 1.0f;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    // default values
    self.on = NO;
    self.isRounded = YES;
    self.inactiveColor = [UIColor clearColor];
    self.activeColor = [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    self.onTintColor = [UIColor colorWithRed:74.0f/255.0f green:213.0f/255.0f blue:98.0f/255.0f alpha:1.0f];
    self.borderColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1.0f];
    self.thumbTintColor = [UIColor whiteColor];
    self.shadowColor = [UIColor grayColor];

    // background
    _background = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    _background.backgroundColor = [self backgroundViewBackgroundColorForOnValue:[self isOn]];
    _background.layer.cornerRadius = height * 0.5f;
    _background.userInteractionEnabled = NO;
    [self addSubview:_background];
    
    CGFloat offset = _borderLineWidth + _borderLineWidth / 2.0f;
    CGRect fillRect = CGRectInset(_background.bounds, offset, offset);
    _fillView = [[UIView alloc] initWithFrame:fillRect];
    _fillView.backgroundColor = [UIColor whiteColor];
    _fillView.layer.cornerRadius = fillRect.size.height * 0.5f;
    _fillView.userInteractionEnabled = NO;
    [self addSubview:_fillView];

    // knob
    _knob = [[UIView alloc] initWithFrame:CGRectMake(_borderLineWidth, _borderLineWidth, height - 2 * _borderLineWidth, height - 2 * _borderLineWidth)];
    _knob.backgroundColor = self.thumbTintColor;
    _knob.layer.cornerRadius = (height * 0.5f) - 1.0f;
    _knob.layer.shadowColor = self.shadowColor.CGColor;
    _knob.layer.shadowRadius = 2.0f;
    _knob.layer.shadowOpacity = 0.45f;
    _knob.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    _knob.layer.masksToBounds = NO;
//    _knob.layer.borderWidth = 0.5f;
//    _knob.layer.borderColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor;
    _knob.userInteractionEnabled = NO;
    [self addSubview:_knob];
    
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
    
    [self addTarget:self action:@selector(dragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    
    [self addTarget:self action:@selector(dragExit:) forControlEvents:UIControlEventTouchDragExit];
    
    self.editing = NO;
}

#pragma mark - Control Events
- (void)touchUpInside:(id)sender {
//    BOOL previousValue = self.on;
    
    [self setEditing:NO animated:YES];
    
//    if (previousValue != self.on) {
//        [self sendActionsForControlEvents:UIControlEventValueChanged];
//    }
}

- (void)dragEnter:(id)sender {
    [self setEditing:YES animated:YES];
}

- (void)dragExit:(id)sender {
    _valueTrackingChanged = YES;
    [self setEditing:NO animated:YES];
}

- (void)touchCancel:(id)sender {
    _valueTrackingChanged = YES;
    [self setEditing:NO animated:YES];
}


#pragma mark Touch Tracking
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    [self setEditing:YES animated:YES];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    if (self.editing) {
        // Get touch location
        CGPoint lastPoint = [touch locationInView:self];
        
        // update the switch to the correct visuals depending on if
        // they moved their touch to the right or left side of the switch
        if (lastPoint.x > self.bounds.size.width * 0.5f) {
            if (!_isAnimating && !_tempOnValue) {
                _valueTrackingChanged = YES;
                [self setTempOnValue:YES animated:YES];
            }
        }
        else {
            if (!_isAnimating && _tempOnValue) {
                _valueTrackingChanged = YES;
                [self setTempOnValue:NO animated:YES];
            }
        }
    }
    
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}


#pragma mark - Knob size changing Animation
- (CGRect)knobFrameEditinig:(BOOL)editing onValue:(BOOL)onValue {
    // make the knob larger and animate to the correct color
    CGRect knobFrame = CGRectZero;
    
    CGFloat normalKnobWidth = self.bounds.size.height - 3.0f;//(2 * _borderLineWidth);
    if (editing) {
        CGFloat activeKnobWidth = normalKnobWidth + kActiveThumbleWidthDifference;
        if (onValue) {
            knobFrame.origin.x = self.bounds.size.width - (activeKnobWidth + _borderLineWidth);
            knobFrame.origin.y = _borderLineWidth + _borderLineWidth / 2;
            knobFrame.size.width = activeKnobWidth;
            knobFrame.size.height = normalKnobWidth;
        }
        else {
            knobFrame.origin.x = _borderLineWidth;
            knobFrame.origin.y = _borderLineWidth + _borderLineWidth / 2;
            knobFrame.size.width = activeKnobWidth;
            knobFrame.size.height = normalKnobWidth;
        }
    }
    else {
        if (onValue) {
            knobFrame.origin.x = self.bounds.size.width - (normalKnobWidth + _borderLineWidth);
            knobFrame.origin.y = _borderLineWidth + _borderLineWidth / 2;
            knobFrame.size.width = normalKnobWidth;
            knobFrame.size.height = normalKnobWidth;
        }
        else {
            knobFrame.origin.x = _borderLineWidth;
            knobFrame.origin.y = _borderLineWidth + _borderLineWidth / 2;
            knobFrame.size.width = normalKnobWidth;
            knobFrame.size.height = normalKnobWidth;
        }
    }
   
    return knobFrame;
}

- (void)setEditing:(BOOL)editing {
    if (_editing != editing) {
        _editing = editing;
        
        if (editing) {
            _valueTrackingChanged = NO;
            _tempOnValue = [self isOn];
        }
        else {
            BOOL previousValue = [self isOn];
            
            if (_valueTrackingChanged) {
                _on = _tempOnValue;
            }
            else {
                _on = !_tempOnValue;
            }
            
            if (previousValue != [self isOn]) {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
        
        [self setupInterfaceForOnValue:[self isOn]];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (animated) {
        _isAnimating = YES;
        if (!editing && !_valueTrackingChanged) {
            // custom animation
//            NSLog(@"custom animation");
            [UIView animateWithDuration:0.16f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 BOOL onValue = !_tempOnValue;
                                 _background.backgroundColor = [self backgroundViewBackgroundColorForOnValue:onValue];
                                 CGRect knobFrame = [self knobFrameEditinig:NO onValue:onValue];
                                 
                                 CGAffineTransform transform = CGAffineTransformIdentity;
                                 CGFloat scale = 0.6f;
                                 if (onValue) {
                                     scale = 0.3f;
                                     knobFrame.origin.x = knobFrame.origin.x + 1.0f;

                                     transform = CGAffineTransformTranslate(transform, 8.0f, 0.0f);
                                     transform = CGAffineTransformScale(transform, scale, scale);
                                     transform = CGAffineTransformTranslate(transform, -8.0f, 0.0f);
                                 }
                                 else {
                                     knobFrame.origin.x = knobFrame.origin.x - 1.0f;
                                     transform = CGAffineTransformTranslate(transform, 8.0f, 0.0f);
                                     transform = CGAffineTransformScale(transform, scale, scale);
                                     transform = CGAffineTransformTranslate(transform, -8.0f, 0.0f);
                                 }
                                 
                                 _knob.frame = knobFrame;
                                 _fillView.transform = transform;
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.16f
                                                       delay:0.0f
                                                     options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                                                  animations:^{
                                                      self.editing = editing;
                                                  } completion:^(BOOL finished) {
                                                      _isAnimating = NO;
                                                  }];
                             }];
        }
        else {
            [UIView animateWithDuration:kAnimationDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.editing = editing;
                             } completion:^(BOOL finished) {
                                 _isAnimating = NO;
                             }];
        }
    }
    else {
        self.editing = editing;
    }
}


#pragma mark Setters

/*
 *	Sets the knob color. Defaults to white.
 */
- (void)setThumbTintColor:(UIColor *)color {
    _thumbTintColor = color;
    _knob.backgroundColor = color;
}

/*
 *	Sets the shadow color of the knob. Defaults to gray.
 */
- (void)setShadowColor:(UIColor *)color {
    _shadowColor = color;
    _knob.layer.shadowColor = color.CGColor;
}


/*
 *	Sets whether or not the switch edges are rounded.
 *  Set to NO to get a stylish square switch.
 *  Defaults to YES.
 */
- (void)setIsRounded:(BOOL)rounded {
    _isRounded = rounded;
    _background.layer.cornerRadius = self.bounds.size.height * 0.5f;
    _knob.layer.cornerRadius = (_knob.bounds.size.height * 0.5f) - 1.0f;
}


/*
 * Set (without animation) whether the switch is on or off
 */
- (void)setOn:(BOOL)isOn {
    [self setOn:isOn animated:NO];
}

/*
 * Set the state of the switch to on or off, optionally animating the transition.
 */
- (void)setTempOnValue:(BOOL)tempOnValue animated:(BOOL)animated {
    _tempOnValue = tempOnValue;
    if (animated) {
        _isAnimating = YES;
        [UIView animateWithDuration:kAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self setupInterfaceForOnValue:tempOnValue];
                         }
                         completion:^(BOOL finished){
                             _isAnimating = NO;
                         }];
    }
    else {
        [self setupInterfaceForOnValue:tempOnValue];
    }
}

- (void)setupInterfaceForOnValue:(BOOL)onValue {
    _background.backgroundColor = [self backgroundViewBackgroundColorForOnValue:onValue];
    _knob.frame = [self knobFrameEditinig:self.editing onValue:onValue];
    if (onValue) {
        _fillView.transform = CGAffineTransformScale(_fillView.transform, 0.0f, 0.0f);
    }
    else {
        if (self.editing) {
            _fillView.transform = CGAffineTransformScale(_fillView.transform, 0.0f, 0.0f);
        }
        else {
            _fillView.transform = CGAffineTransformIdentity;
        }
    }
}


#pragma mark - Getters
/*
 *	Detects whether the switch is on or off
 *
 *	@return	BOOL YES if switch is on. NO if switch is off
 */
- (BOOL)isOn {
    return self.on;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
//    NSLog(@"on: %d newON: %d", [self isOn], on);
    _tempOnValue = !on;
    if ([self isOn] != on) {
        if (animated) {
            _editing = YES;
            [self setEditing:NO animated:YES];
        }
        else {
            _editing = YES;
            [self setEditing:NO animated:NO];
        }
    }
}

- (UIColor *)onColor {
    return self.onTintColor;
}

- (UIColor *)backgroundViewBackgroundColorForOnValue:(BOOL)onValue {
    if (onValue) {
        return self.onTintColor;
    }
    
    return self.activeColor;
}

@end
