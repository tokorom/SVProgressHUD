//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark -
#pragma mark ----- SVProgressMask -----

@interface SVProgressMask : UIView
- (id)initForView:(UIView*)view;
@end 

#pragma mark -
#pragma mark ----- SVProgressHUD -----

@interface SVProgressHUD ()

@property (nonatomic, retain) NSTimer *fadeOutTimer;
@property (nonatomic, retain) UILabel *stringLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *spinnerView;
@property (nonatomic, retain) SVProgressMask *maskView;

- (void)showInView:(UIView *)view status:(NSString *)string posY:(CGFloat)posY mask:(BOOL)mask;
- (void)setStatus:(NSString *)string;
- (void)dismiss;
- (void)dismissWithStatus:(NSString *)string error:(BOOL)error;

- (void)memoryWarning:(NSNotification*) notification;

@end


@implementation SVProgressHUD

@synthesize fadeOutTimer, stringLabel, imageView, spinnerView, maskView;

static SVProgressHUD *sharedView = nil;

+ (SVProgressHUD*)sharedView {
	
	if(sharedView == nil)
		sharedView = [[SVProgressHUD alloc] initWithFrame:CGRectZero];
	
	return sharedView;
}

+ (void)setStatus:(NSString *)string {
	[[SVProgressHUD sharedView] setStatus:string];
}

#pragma mark -
#pragma mark Show Methods


+ (void)show {
	[SVProgressHUD showInView:nil status:nil];
}


+ (void)showInView:(UIView*)view {
	[SVProgressHUD showInView:view status:nil];
}


+ (void)showInView:(UIView*)view status:(NSString*)string {
  [SVProgressHUD showInView:view status:string posY:-1 mask:YES];
}


+ (void)showInView:(UIView*)view status:(NSString*)string posY:(CGFloat)posY {
  [SVProgressHUD showInView:view status:string posY:posY mask:YES];
}

+ (void)showInView:(UIView*)view status:(NSString*)string mask:(BOOL)mask {
  [SVProgressHUD showInView:view status:string posY:-1 mask:mask];
}

+ (void)showInView:(UIView*)view status:(NSString*)string posY:(CGFloat)posY mask:(BOOL)mask {
	
    if(!view) {
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        
        if ([keyWindow respondsToSelector:@selector(rootViewController)]) {
            //Use the rootViewController to reflect the device orientation
            view = keyWindow.rootViewController.view;
        }
        
        if (view == nil) view = keyWindow;
    }
	
	if(posY == -1)
		posY = floor(CGRectGetHeight(view.bounds)/2)-100;

  [[SVProgressHUD sharedView] showInView:view status:string posY:posY mask:mask];
}


#pragma mark -
#pragma mark Dismiss Methods

+ (void)dismiss {
	[[SVProgressHUD sharedView] dismiss];
}


+ (void)dismissWithSuccess:(NSString*)successString {
	[[SVProgressHUD sharedView] dismissWithStatus:successString error:NO];
}


+ (void)dismissWithError:(NSString*)errorString {
	[[SVProgressHUD sharedView] dismissWithStatus:errorString error:YES];
}

#pragma mark -
#pragma mark Instance Methods

- (void)dealloc {
  self.maskView = nil; 
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.layer.cornerRadius = 10;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
		self.userInteractionEnabled = NO;
		self.layer.opacity = 0;
        self.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(memoryWarning:) 
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
	
    return self;
}

- (void)setStatus:(NSString *)string {
	
    CGFloat hudWidth = 100;
    
	CGFloat stringWidth = [string sizeWithFont:self.stringLabel.font].width+28;
	
	if(stringWidth > hudWidth)
		hudWidth = ceil(stringWidth/2)*2;
	
  UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
	self.bounds = CGRectMake(0, 0, MIN( hudWidth, keyWindow.bounds.size.width ), 100);
	
	self.imageView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, 36);
	
	self.stringLabel.hidden = NO;
	self.stringLabel.text = string;
	self.stringLabel.frame = CGRectMake(0, 66, CGRectGetWidth(self.bounds), 20);
	
	if(string)
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.bounds)/2)+0.5, 40.5);
	else
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.bounds)/2)+0.5, ceil(self.bounds.size.height/2)+0.5);
}


- (void)showInView:(UIView*)view status:(NSString*)string posY:(CGFloat)posY mask:(BOOL)mask {
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	self.imageView.hidden = YES;
	
	[self setStatus:string];
	[spinnerView startAnimating];
	
	if(![sharedView isDescendantOfView:view]) {
		sharedView.layer.opacity = 0;
		[view addSubview:sharedView];
    if ( mask ) {
      self.maskView = [[[SVProgressMask alloc] initForView:view] autorelease];
      [view addSubview:self.maskView];
    }
	}
	
	if(sharedView.layer.opacity != 1) {
		
		posY+=(CGRectGetHeight(self.bounds)/2);
		self.center = CGPointMake(CGRectGetWidth(self.superview.bounds)/2, posY);
		
		self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1.3, 1.3, 1);
		self.layer.opacity = 0.3;
		
		[UIView animateWithDuration:0.15
							  delay:0
							options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut
						 animations:^{	
							 self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 1, 1);
							 self.layer.opacity = 1;
						 }
						 completion:NULL];
	}
}


- (void)dismiss {
	
	[UIView animateWithDuration:0.15
						  delay:0
						options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{	
						 self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 0.8, 0.8, 1.0);
						 self.layer.opacity = 0;
					 }
					 completion:^(BOOL finished){
             if(self.layer.opacity == 0){
               [self.maskView removeFromSuperview];
               [self removeFromSuperview]; 
             }
           }
  ];
}


- (void)dismissWithStatus:(NSString*)string error:(BOOL)error {
	
  CGFloat displayTime = 0.9;
	if(error) {
		self.imageView.image = [UIImage imageNamed:@"SVProgressHUD.bundle/error.png"];
    displayTime *= 2;
  } else {
		self.imageView.image = [UIImage imageNamed:@"SVProgressHUD.bundle/success.png"];
  }
	
	self.imageView.hidden = NO;
	
	[self setStatus:string];
	
	[self.spinnerView stopAnimating];

	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	fadeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:displayTime target:self selector:@selector(dismiss) userInfo:nil repeats:NO] retain];
}

#pragma mark -
#pragma mark Getters

- (UILabel *)stringLabel {
    
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor whiteColor];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
		stringLabel.textAlignment = UITextAlignmentCenter;
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont boldSystemFontOfSize:16];
		stringLabel.shadowColor = [UIColor blackColor];
		stringLabel.shadowOffset = CGSizeMake(0, -1);
		[self addSubview:stringLabel];
		[stringLabel release];
    }
    
    return stringLabel;
}

- (UIImageView *)imageView {
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
		[self addSubview:imageView];
		[imageView release];
    }
    
    return imageView;
}

- (UIActivityIndicatorView *)spinnerView {
    
    if (spinnerView == nil) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinnerView.hidesWhenStopped = YES;
		spinnerView.bounds = CGRectMake(0, 0, 37, 37);
		[self addSubview:spinnerView];
		[spinnerView release];
    }
    
    return spinnerView;
}

#pragma mark -
#pragma mark MemoryWarning

- (void)memoryWarning:(NSNotification *)notification {
	
    if (sharedView.superview == nil) {
        [sharedView release];
        sharedView = nil;
    }
}

@end

#pragma mark -
#pragma mark ----- SVProgressMask -----

@implementation SVProgressMask

- (id)initForView:(UIView*)view {
  if ( (self = [super init]) ) {
    self.frame = view.bounds;
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  }
  return self;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  // mask
}
@end 
