//
//  SVProgressHUD.h
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

@interface SVProgressHUD : UIView 

/* 
showInView:(UIView*)	-> the view you're adding the HUD to. By default, it's added to the keyWindow rootViewController, or the keyWindow if the rootViewController is nil
status:(NSString*)		-> a loading status for the HUD (different from the success and error messages)
posY:(CGFloat)			-> the vertical position of the HUD (default is (viewHeight/2)-50)
*/
 
+ (void)show;
+ (void)showInView:(UIView*)view;
+ (void)showInView:(UIView*)view status:(NSString*)string;
+ (void)showInView:(UIView*)view status:(NSString*)string posY:(CGFloat)posY;
+ (void)showInView:(UIView*)view status:(NSString*)string mask:(BOOL)mask;
+ (void)showInView:(UIView*)view status:(NSString*)string posY:(CGFloat)posY mask:(BOOL)mask;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

+ (void)dismiss; // simply dismiss the HUD with a fade+scale out animation
+ (void)dismissWithSuccess:(NSString*)successString; // also displays the success icon image
+ (void)dismissWithError:(NSString*)errorString; // also displays the error icon image

@end
