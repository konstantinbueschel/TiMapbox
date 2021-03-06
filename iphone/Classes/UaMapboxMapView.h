/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiUIView.h"
#import "Mapbox.h"

@interface UaMapboxMapView : TiUIView<RMMapViewDelegate> {}

-(NSDictionary *)coordinateFromPoint:(CGPoint)point;

-(void)addAnnotation:(id)args;
-(void)addShape:(id)args;
-(void)removeAnnotation:(id)args;
-(void)removeAllAnnotations;
-(void)setBoundariesSouthWest:(id)southWest northEast:(id)northEast;
-(void)zoomToLatitudeLongitudeBoundsSouthWest:(id)southWest northEast:(id)northEast;

@property (readonly) RMMapView* mapView;

@end
