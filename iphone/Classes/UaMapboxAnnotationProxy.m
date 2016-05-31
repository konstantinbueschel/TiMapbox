/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "UaMapboxAnnotationProxy.h"
#import "TiUtils.h"
#import "TiViewProxy.h"

NSInteger * const UaMapboxAnnotationAccessoryTagLeft = 1;
NSInteger * const UaMapboxAnnotationAccessoryTagRight = 2;

@implementation UaMapboxAnnotationProxy

@synthesize delegate;
@synthesize needsRefreshingWithSelection;
@synthesize placed;
@synthesize offset;


#pragma mark Internal


-(void)_configure {

	needsRefreshingWithSelection = YES;

	[super _configure];
}


-(NSString*)apiName
{
    return @"ua.mapbox.Annotation";
}


#pragma mark Public APIs

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D result;
    result.latitude = [TiUtils doubleValue:[self valueForUndefinedKey:@"latitude"]];
    result.longitude = [TiUtils doubleValue:[self valueForUndefinedKey:@"longitude"]];
    return result;
}

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self setValue:[NSNumber numberWithDouble:coordinate.latitude] forUndefinedKey:@"latitude"];
    [self setValue:[NSNumber numberWithDouble:coordinate.longitude] forUndefinedKey:@"longitude"];
}

-(void)setLatitude:(id)latitude
{
    double curValue = [TiUtils doubleValue:[self valueForUndefinedKey:@"latitude"]];
    double newValue = [TiUtils doubleValue:latitude];
    [self replaceValue:latitude forKey:@"latitude" notification:NO];
}

-(void)setLongitude:(id)longitude
{
    double curValue = [TiUtils doubleValue:[self valueForUndefinedKey:@"longitude"]];
    double newValue = [TiUtils doubleValue:longitude];
    [self replaceValue:longitude forKey:@"longitude" notification:NO];
}

-(void)setImage:(id)image
{
    id current = [self valueForUndefinedKey:@"image"];
    [self replaceValue:image forKey:@"image" notification:NO];

    if (marker) {
        [marker replaceUIImage:[TiUtils image:image proxy:self]];
    }
}


-(id)userInfo {

	return [self valueForUndefinedKey:@"userInfo"];
}


-(void)setUserInfo:(id)args {

	ENSURE_TYPE(args, NSDictionary);

	NSDictionary *userInfo = @{
							@"args": args,
							@"type": @"annotation"
							};

	[self replaceValue:userInfo forKey:@"userInfo" notification:NO];
}


- (NSString *)title {
	
    return [self valueForUndefinedKey:@"title"];
}

-(void)setTitle:(id)title {
	
    title = [TiUtils replaceString:[TiUtils stringValue:title]
                        characters:[NSCharacterSet newlineCharacterSet] withString:@" "];
	
	//The label will strip out these newlines anyways (Technically, replace them with spaces)
    
    id current = [self valueForUndefinedKey:@"title"];
    [self replaceValue:title forKey:@"title" notification:NO];
}


- (NSString *)subtitle {
	
    return [self valueForUndefinedKey:@"subtitle"];
}


-(void)setSubtitle:(id)subtitle {
	
    subtitle = [TiUtils replaceString:[TiUtils stringValue:subtitle]
                           characters:[NSCharacterSet newlineCharacterSet] withString:@" "];
	
	//The label will strip out these newlines anyways (Technically, replace them with spaces)
    
    id current = [self valueForUndefinedKey:@"subtitle"];
	
	[self replaceValue:subtitle forKey:@"subtitle" notification:NO];
}


- (UIView*)leftAccessoryView {
	
    TiViewProxy* viewProxy = [self valueForUndefinedKey:@"leftView"];
	
	if (viewProxy!=nil && [viewProxy isKindOfClass:[TiViewProxy class]]) {
		
		return [viewProxy view];
    }
	
    return nil;
}


- (UIView*)rightAccessoryView {
	
	TiViewProxy* viewProxy = [self valueForUndefinedKey:@"rightView"];
	
	if (viewProxy!=nil && [viewProxy isKindOfClass:[TiViewProxy class]]) {
		
		return [viewProxy view];
    }
	
    return nil;
}


- (void)setRightView:(id)rightview {
	
	id current = [self valueForUndefinedKey:@"rightView"];
	[self replaceValue:rightview forKey:@"rightView" notification:NO];
}


- (void)setLeftView:(id)leftview {
	
	id current = [self valueForUndefinedKey:@"leftView"];
	[self replaceValue:leftview forKey:@"leftView" notification:NO];
}


-(RMMarker *)marker {
	
    if (marker == nil) {
		
		CGPoint anchorPoint;
		
		id image = [self valueForUndefinedKey:@"image"];
        id point = [self valueForUndefinedKey:@"anchorPoint"];
		
		UIColor *tintColor = [[TiUtils colorValue:self.pinColor] _color];
		
		
		// handle whole marker image
        if (image != nil) {
			
			ENSURE_TYPE_OR_NIL(point, NSDictionary);
            
            if (point != nil) {
				
				anchorPoint = CGPointMake([TiUtils floatValue:@"x" properties:point], [TiUtils floatValue:@"y" properties:point]);
            }
			else {
				
				anchorPoint = CGPointMake(0.5f, 0);
            }
            
            marker = [[UaMapboxMarker alloc] initWithUIImage:[TiUtils image:image proxy:self] anchorPoint:anchorPoint];
        }
		// handle marker icon and tint
		else if (self.icon != nil) {
			
			if (tintColor != nil) {
				
				marker = [[UaMapboxMarker alloc] initWithMapboxMarkerImage:[TiUtils stringValue:self.icon] tintColor:tintColor];
			}
			else {
				
				marker = [[UaMapboxMarker alloc] initWithMapboxMarkerImage:[TiUtils stringValue:self.icon]];
			}
		}
		// handle tint
		else if (tintColor != nil) {
			
            marker = [[UaMapboxMarker alloc] initWithMapboxMarkerImage:nil tintColor:tintColor];
        }
		// create marker
		else {
			
			marker = [[UaMapboxMarker alloc] initWithMapboxMarkerImage:nil tintColor:nil];
		}
		
		
		// handle left view/button
		if (self.leftAccessoryView != nil) {
			
			marker.leftCalloutAccessoryView = self.leftAccessoryView;
		}
		else if (self.leftButtonImage != nil) {
				
			UIButton *buttonLeft = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				
			[buttonLeft sizeToFit];
				
			[buttonLeft setFrame:CGRectMake(buttonLeft.frame.origin.x, buttonLeft.frame.origin.y, buttonLeft.frame.size.width + 20, 44.5)];
				
			[buttonLeft setImage:[self findImage:self.leftButtonImage] forState:UIControlStateNormal];
				
			buttonLeft.imageView.contentMode = UIViewContentModeScaleAspectFit;
				
			buttonLeft.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
			buttonLeft.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
				
			buttonLeft.tag = UaMapboxAnnotationAccessoryTagLeft;
				
				
			if (self.leftButtonColor != nil) {
					
				UIColor *tintColor = [[TiUtils colorValue:self.leftButtonColor] _color];
					
				buttonLeft.tintColor = tintColor;
			}
				
			if (self.leftButtonBackgroundColor != nil) {
					
				buttonLeft.backgroundColor = [[TiUtils colorValue:self.leftButtonBackgroundColor] _color];
			}
				
			marker.leftCalloutAccessoryView = buttonLeft;
		}
		
		
		// handle right view/button
		if (self.rightAccessoryView != nil) {
			
			marker.rightCalloutAccessoryView = self.rightAccessoryView;
		}
		else if (self.rightButtonImage != nil) {
				
			UIButton *buttonRight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				
			[buttonRight sizeToFit];
				
			[buttonRight setFrame:CGRectMake(buttonRight.frame.origin.x, buttonRight.frame.origin.y, buttonRight.frame.size.width + 20, 44.0)];
				
			[buttonRight setImage:[self findImage:self.rightButtonImage] forState:UIControlStateNormal];
				
			buttonRight.imageView.contentMode = UIViewContentModeScaleAspectFit;
				
			buttonRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
			buttonRight.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
				
			buttonRight.tag = UaMapboxAnnotationAccessoryTagRight;
				
				
			if (self.rightButtonColor != nil) {
					
				UIColor *tintColor = [[TiUtils colorValue:self.rightButtonColor] _color];
					
				buttonRight.tintColor = tintColor;
			}
				
			if (self.rightButtonBackgroundColor != nil) {
					
				buttonRight.backgroundColor = [[TiUtils colorValue:self.rightButtonBackgroundColor] _color];
			}
				
			marker.rightCalloutAccessoryView = buttonRight;
		}
    }
	
    return marker;
}


-(UaMapboxAnnotation *)annotationForMapView:(RMMapView *)map
{
    NSLog(@"[MapboxAnnotationProxy] annotationForMapView");
    
    if (!annotation) {
		
		annotation = [[UaMapboxAnnotation alloc] initWithMapView:map coordinate:self.coordinate andTitle:self.title];
		
		annotation.subtitle = self.subtitle;
		annotation.userInfo = self.userInfo;
		
        [annotation setProxy:self];
    }
	
    return annotation;
}


- (UIImage *)findImage:(NSString *)imagePath {
	
	if (imagePath != nil) {
		
		UIImage *image = nil;
		
		//image from URL
		image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]];
		
		if (image != nil) {
			return image;
		}
		
		//load remote image
		image = [UIImage imageWithContentsOfFile:imagePath];
		
		if (image != nil) {
			return image;
		}
		
		// Load the image from the application assets
		NSString *fileNamePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imagePath];;
		image = [UIImage imageWithContentsOfFile:fileNamePath];
		
		if (image != nil) {
			return image;
		}
		
		//Load local image by extracting the filename without extension
		NSString* newImagePath = [[imagePath lastPathComponent] stringByDeletingPathExtension];
		image = [UIImage imageNamed:newImagePath];
		
		if (image != nil) {
			
			return image;
		}
	}
	
	return nil;
}

@end