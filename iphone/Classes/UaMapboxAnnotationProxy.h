/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "UaMapboxMapView.h"
#import "UaMapboxAnnotation.h"
#import "UaMapboxMarker.h"

@interface UaMapboxAnnotationProxy : TiProxy {
@private
    UaMapboxMapView *__weak delegate;
    UaMapboxAnnotation *annotation;
    UaMapboxMarker *marker;
    BOOL placed;
    CGPoint offset;
}

// Center latitude and longitude of the annotion view.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite, weak) UaMapboxMapView *delegate;
@property (nonatomic, readonly)	BOOL needsRefreshingWithSelection;
@property (nonatomic, readwrite, assign) BOOL placed;
@property (nonatomic, readonly) CGPoint offset;

@property (nonatomic, copy) NSString *rightButtonImage;
@property (nonatomic, copy) NSString *leftButtonImage;

@property (nonatomic, copy) NSString *rightButtonColor;
@property (nonatomic, copy) NSString *leftButtonColor;

@property (nonatomic, copy) NSString *leftButtonBackgroundColor;
@property (nonatomic, copy) NSString *rightButtonBackgroundColor;

@property (nonatomic, copy) NSString *pinColor;
@property (nonatomic, copy) NSString *icon;

-(UaMapboxMarker *)marker;
-(UaMapboxAnnotation *)annotationForMapView:(RMMapView *)map;

- (NSString *)title;
- (NSString *)subtitle;

- (UIView *)leftAccessoryView;
- (UIView *)rightAccessoryView;

- (id)userInfo;

extern NSInteger * const UaMapboxAnnotationAccessoryTagLeft;
extern NSInteger * const UaMapboxAnnotationAccessoryTagRight;

@end