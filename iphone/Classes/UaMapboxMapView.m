/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "UaMapboxAnnotationProxy.h"
#import "UaMapboxMapView.h"
#import "TiUtils.h"
#import "Mapbox.h"

@implementation UaMapboxMapView

#pragma mark Lifecycle

-(void)initializeState
{
    // This method is called right after allocating the view and
    // is useful for initializing anything specific to the view
    
    [self addMap];
    
    [super initializeState];
    
    NSLog(@"[MapboxMapView] [VIEW LIFECYCLE EVENT] initializeState");
}

-(void)configurationSet
{
    // This method is called right after all view properties have
    // been initialized from the view proxy. If the view is dependent
    // upon any properties being initialized then this is the method
    // to implement the dependent functionality.
    
    [super configurationSet];
    
    NSLog(@"[MapboxMapView] [VIEW LIFECYCLE EVENT] configurationSet");
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    NSLog(@"[MapboxMapView] [VIEW LIFECYCLE EVENT] willMoveToSuperview");
}


#pragma mark private

-(void)addMap
{
    if(_mapView == nil) {
		
        NSLog(@"[MapboxMapView] [VIEW LIFECYCLE EVENT] addMap");
        
        NSString *mapPath = [TiUtils stringValue:[self.proxy valueForKey:@"map"]];
		
		id mapSource;
        
        //check if file exists, otherwise try to add remote map
        NSString *mapInResourcesFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[mapPath stringByAppendingString:@".mbtiles"]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mapInResourcesFolder];
        
        NSLog(@"[MapboxMapView] mapFile exists: %i", fileExists);
        
        if(fileExists)
        {
            mapSource = [[RMMBTilesSource alloc] initWithTileSetResource:mapPath ofType:@"mbtiles"];
            
        } else
        {
            mapSource = [[RMMapboxSource alloc] initWithMapID:mapPath];
            
        }
        
        /*create the mapView with CGRectMake upon initialization because we won't know frame size
         until frameSizeChanged is fired after loading view. If we wait until then, we can't add annotations.*/
        _mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) andTilesource:mapSource];
        
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        _mapView.adjustTilesForRetinaDisplay = [TiUtils boolValue:[self.proxy valueForKey:@"adjustTilesForRetinaDisplay"] def:YES];
		
		_mapView.bouncingEnabled = [TiUtils boolValue:[self.proxy valueForKey:@"bouncingEnabled"] def:YES];

		_mapView.userTrackingMode = [TiUtils intValue:[self.proxy valueForKey:@"userTrackingMode" ] def:RMUserTrackingModeNone];
		
        [self addSubview:_mapView];
        
        _mapView.delegate = self;
    }
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    NSLog(@"[MapboxMapView] [VIEW LIFECYCLE EVENT] frameSizeChanged");
	
    if (_mapView!=nil) {
		
		[TiUtils setView:_mapView positionRect:bounds];
    }
    else {
		
		[self addMap];
    }
}

#pragma mark Property Setters

-(void)setBackgroundColor_:(id)value
{
    [_mapView setBackgroundColor:[[TiUtils colorValue:value] _color]];
}

-(void)setCenterLatLng_:(id)value
{
    [_mapView setCenterCoordinate: CLLocationCoordinate2DMake([TiUtils floatValue:[value objectAtIndex:0]],[TiUtils floatValue:[value objectAtIndex:1]]) animated:YES];
}

-(void)setDebugTiles_:(id)value
{
    [_mapView setDebugTiles:[TiUtils boolValue:value]];
}

-(void)setHideAttribution_:(id)value
{
    _mapView.hideAttribution = [TiUtils boolValue:value];
}

-(void)setMinZoom_:(id)value
{
    [_mapView setMinZoom:[TiUtils floatValue:value]];
}

-(void)setMaxZoom_:(id)value
{
    [_mapView setMaxZoom:[TiUtils floatValue:value]];
}

-(void)setUserLocation_:(id)value
{
    _mapView.showsUserLocation = [TiUtils boolValue:value];
}

-(void)setZoom_:(id)value
{
    [_mapView setZoom:[TiUtils floatValue:value] animated:YES];
}


-(void)setUserTrackingMode_:(id)value {
	
	[_mapView setUserTrackingMode:[TiUtils intValue:value] animated:YES];
}


-(id)getUserTrackingMode_ {
	
	return NUMINTEGER(_mapView.userTrackingMode);
}


-(void)setBouncingEnabled_:(id)value {
	
	[_mapView setBouncingEnabled:[TiUtils boolValue:value]];
}


-(void)setAdjustTilesForRetinaDisplay_:(id)value {
	
	[_mapView setAdjustTilesForRetinaDisplay:[TiUtils boolValue:value]];
}


-(void)setRegion_:(id)args
{
    ENSURE_DICT(args);
    NSDictionary *region = (NSDictionary *) args;
    
    NSLog(@"[MapboxMapView] setRegion with args %@", args);
    
    CLLocationDegrees latitude = [(NSString *)[region valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude = [(NSString *)[region valueForKey:@"longitude"] doubleValue];
    CLLocationDegrees latitudeDelta = [(NSString *)[region valueForKey:@"longitudeDelta"] doubleValue];
    CLLocationDegrees longitudeDelta = [(NSString *)[region valueForKey:@"latitudeDelta"] doubleValue];

    RMSphericalTrapezium bounds;
    bounds.northEast.latitude = latitude + latitudeDelta / 2;
    bounds.northEast.longitude = longitude + longitudeDelta / 2;
    bounds.southWest.latitude = latitude - latitudeDelta / 2;
    bounds.southWest.longitude = longitude - longitudeDelta / 2;
    
    [_mapView zoomWithLatitudeLongitudeBoundsSouthWest:bounds.southWest
                                            northEast:bounds.northEast
                                             animated:[TiUtils boolValue:@"animated"
                                                              properties:region
                                                                     def:YES]];
}


-(id)getRegion_
{
    RMSphericalTrapezium bounds = [_mapView latitudeLongitudeBoundingBox];
    
    CLLocationDegrees latitude = _mapView.centerCoordinate.latitude;
    CLLocationDegrees longitude = _mapView.centerCoordinate.longitude;
    CLLocationDegrees latitudeDelta = fabs(bounds.northEast.latitude - bounds.southWest.latitude);
    CLLocationDegrees longitudeDelta = fabs(bounds.northEast.longitude - bounds.southWest.longitude);
    
    return @{
             @"longitude":      [NSNumber numberWithDouble:longitude],
             @"latitude":       [NSNumber numberWithDouble:latitude],
             @"longitudeDelta": [NSNumber numberWithDouble:longitudeDelta],
             @"latitudeDelta":  [NSNumber numberWithDouble:latitudeDelta],
             };
}


-(BOOL)getUserLocationVisible_ {
	
	return _mapView.isUserLocationVisible;
}


-(void)setBoundariesSouthWest:(id)southWest northEast:(id)northEast {
	
	NSDictionary *southWestBounds = (NSDictionary *) southWest;
	NSDictionary *northEastBounds = (NSDictionary *) northEast;
	
	
	RMSphericalTrapezium bounds;
	
	bounds.southWest.latitude = [(NSString *) [southWestBounds valueForKey:@"latitude"] doubleValue];
	bounds.southWest.longitude = [(NSString *) [southWestBounds valueForKey:@"longitude"] doubleValue];
	
	bounds.northEast.latitude = [(NSString *) [northEastBounds valueForKey:@"latitude"] doubleValue];
	bounds.northEast.longitude = [(NSString *) [northEastBounds valueForKey:@"longitude"] doubleValue];
	
	[_mapView setConstraintsSouthWest:bounds.southWest northEast:bounds.northEast];
}


-(NSDictionary *)coordinateFromPoint:(CGPoint)point
{
    CLLocationCoordinate2D coordinate = [_mapView pixelToCoordinate:point];
	
	return @{
             @"latitude": [NSNumber numberWithDouble:coordinate.latitude],
             @"longitude": [NSNumber numberWithDouble:coordinate.longitude]
             };
}

#pragma mark Annotations

// add annotation via setter
-(UaMapboxAnnotationProxy *)annotationFromArg:(id)arg
{
    NSLog(@"[MapboxMapView] annotationFromArg");
    
    return [(UaMapboxMapView *)[self proxy] annotationFromArg:arg];
}

// add annotation via public api
-(void)addAnnotation:(id)args
{
    NSLog(@"[MapboxMapView] addAnnotation");
    
    UaMapboxAnnotationProxy *annotationProxy = [self annotationFromArg:args];
    
    [_mapView addAnnotation:[annotationProxy annotationForMapView:_mapView]];
}


//parts of addShape from https://github.com/benbahrenburg/benCoding.Map addPolygon method Apache License 2.0
-(void)addShape:(id)args
{
    ENSURE_TYPE(args,NSDictionary);
    ENSURE_UI_THREAD(addShape,args);
    
    id pointsValue = [args objectForKey:@"points"];
    
    //remove points from args since they are no longer needed
    //and we are passing args along to the annotation userInfo
    NSMutableDictionary *mutableArgs = [args mutableCopy];
    [mutableArgs removeObjectForKey:@"points"];
    
    if(pointsValue==nil) {
		
        NSLog(@"[MapboxMapView] points value is missing, cannot add polygon");
		
		return;
    }
	
    NSArray *inputPoints = [NSArray arrayWithArray:pointsValue];
    //Get our counter
    NSUInteger pointsCount = [inputPoints count];
    
    //We need at least one point to do anything
    if(pointsCount==0){
        return;
    }
    
    //Create the number of points provided
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    //loop through and add coordinates
    for (int iLoop = 0; iLoop < pointsCount; iLoop++) {
        [points addObject:
         [[CLLocation alloc] initWithLatitude:[TiUtils floatValue:@"latitude" properties:[inputPoints objectAtIndex:iLoop] def:0]
                                    longitude:[TiUtils floatValue:@"longitude" properties:[inputPoints objectAtIndex:iLoop] def:0] ]];
    }
    
    RMAnnotation *annotation = [[RMAnnotation alloc]
                                initWithMapView:_mapView
                                coordinate:((CLLocation *)[points objectAtIndex:0]).coordinate
                                andTitle:[TiUtils stringValue:@"title" properties:mutableArgs]];
    
    //Attach all data for use when creating the layer for the annotation
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              mutableArgs, @"args",
                              points, @"points",
                              @"Shape", @"type", nil];
    
    annotation.userInfo = userInfo;
    
    [_mapView addAnnotation:annotation];
}


- (RMMapLayer *)shapeLayer:(RMMapView *)__mapView userInfo:(NSDictionary *)userInfo
{
    RMShape *shape = [[RMShape alloc] initWithView:__mapView];
    NSDictionary *args = [userInfo objectForKey:@"args"];
    
    // FILL
    float fillOpacity = [TiUtils floatValue:@"fillOpacity" properties:args];
    UIColor *fillColor =  [[TiUtils colorValue:@"fillColor" properties:[userInfo objectForKey:@"args"]] _color];
    
    if (fillColor != nil)
    {
        if(fillOpacity)
        {
            fillColor = [fillColor colorWithAlphaComponent:fillOpacity];
        }
        shape.fillColor = fillColor;
    }
    
    //Line Properties
    float lineOpacity = [TiUtils floatValue:@"lineOpacity" properties:args];
    UIColor *lineColor =  [[TiUtils colorValue:@"lineColor" properties:[userInfo objectForKey:@"args"]] _color];
    if (lineColor != nil)
    {
        if(lineOpacity)
        {
            lineColor = [lineColor colorWithAlphaComponent:lineOpacity];
        }
        shape.lineColor = lineColor;
    }
    shape.lineWidth = [TiUtils floatValue:@"lineWidth" properties:args def: 1.0];
    
    shape.lineDashLengths = [args objectForKey:@"lineDashLengths" ];
    shape.lineDashPhase = [TiUtils floatValue:@"lineDashPhase" properties:args def: 0.0];
    shape.scaleLineDash = [TiUtils boolValue:@"scaleLineDash" properties:args def: NO];
    shape.lineJoin = [TiUtils stringValue:@"lineJoin" properties:args def:kCALineJoinMiter];
    
    //Add shape with coordinates
    for (CLLocation *location in (NSArray *)[userInfo objectForKey:@"points"])
        [shape addLineToCoordinate:location.coordinate];
    
    return shape;
}


-(void)removeAnnotation:(id)proxy
{
    ENSURE_SINGLE_ARG(proxy, UaMapboxAnnotationProxy);
    [_mapView removeAnnotation:[(UaMapboxAnnotationProxy *)proxy annotationForMapView:_mapView]];
}

-(void)removeAllAnnotations
{
    [_mapView removeAllAnnotations];
}


#pragma mark Events

- (void)longPressOnMap:(RMMapView *)map at:(CGPoint)point {
	
    if ([self.proxy _hasListeners:@"longPressOnMap"]) {
		
		CLLocationCoordinate2D location = [_mapView pixelToCoordinate:point];
        
        NSDictionary *event = @{
                                @"annotation": [NSNull null],
                                @"latitude": NUMDOUBLE([_mapView pixelToCoordinate:point].latitude),
                                @"longitude": NUMDOUBLE([_mapView pixelToCoordinate:point].longitude),
                                };
        
        [self.proxy fireEvent:@"longPressOnMap" withObject:event];
    }
}


- (void)beforeMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction {
	
	if ([self.proxy _hasListeners:@"beforeMapMove"]) {
		
		NSDictionary *event = @{
								@"wasUserAction": NUMBOOL(wasUserAction)
								};
		
		[self.proxy fireEvent:@"beforeMapMove" withObject:event];
	}
}


- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction {
	
    if ([self.proxy _hasListeners:@"afterMapMove"]) {
        
		NSDictionary *event = @{
								@"wasUserAction": NUMBOOL(wasUserAction)
								};
        
        [self.proxy fireEvent:@"afterMapMove" withObject:event];
    }
}


- (void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point {
	
    // The event listeners for a view are actually attached to the view proxy.
    // You must reference 'self.proxy' to get the proxy for this view
    
    // It is a good idea to check if there are listeners for the event that
    // is about to fired. There could be zero or multiple listeners for the
    // specified event.
    if ([self.proxy _hasListeners:@"singleTapOnMap"]) {
        
        CLLocationCoordinate2D location = [_mapView pixelToCoordinate:point];
        
        NSDictionary *event = @{
                                @"annotation": [NSNull null],
                                @"latitude": NUMDOUBLE([_mapView pixelToCoordinate:point].latitude),
                                @"longitude": NUMDOUBLE([_mapView pixelToCoordinate:point].longitude),
                                };
        
        [self.proxy fireEvent:@"singleTapOnMap" withObject:event];
    }
}


- (void)doubleTapOnMap:(RMMapView *)map at:(CGPoint)point {
	
	// The event listeners for a view are actually attached to the view proxy.
	// You must reference 'self.proxy' to get the proxy for this view
	
	// It is a good idea to check if there are listeners for the event that
	// is about to fired. There could be zero or multiple listeners for the
	// specified event.
	if ([self.proxy _hasListeners:@"doubleTapOnMap"]) {
		
		CLLocationCoordinate2D location = [_mapView pixelToCoordinate:point];
		
		NSDictionary *event = @{
								@"annotation": [NSNull null],
								@"latitude": NUMDOUBLE([_mapView pixelToCoordinate:point].latitude),
								@"longitude": NUMDOUBLE([_mapView pixelToCoordinate:point].longitude),
								};
		
		[self.proxy fireEvent:@"doubleTapOnMap" withObject:event];
	}
}


-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
	
    if ([self.proxy _hasListeners:@"tapOnAnnotation"] && !annotation.isUserLocationAnnotation) {

        if ([annotation isKindOfClass:[UaMapboxAnnotation class]]) {
            
            UaMapboxAnnotationProxy *annotationProxy = [(UaMapboxAnnotation *)annotation proxy];
			
			NSDictionary *event;
				
			event = @{
				@"annotation": annotationProxy != nil ? annotationProxy : [NSNull null],
				@"userInfo": annotation.userInfo,
				@"latitude": NUMDOUBLE(annotation.coordinate.latitude),
				@"longitude": NUMDOUBLE(annotation.coordinate.longitude),
				};
            
            [self.proxy fireEvent:@"tapOnAnnotation" withObject:event];
        }
        else {
            
            NSLog(@"[MapboxMapView] tapOnAnnotation: unknown annotation type");
        }
    }
}



- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
	
    if ([self.proxy _hasListeners:@"tapOnCalloutAccessoryControl"]) {
            
        UaMapboxAnnotationProxy *annotationProxy = [(UaMapboxAnnotation *)annotation proxy];
            
		NSDictionary *event;
			
			event = @{
				@"annotation": annotationProxy != nil ? annotationProxy : [NSNull null],
				@"userInfo": annotation.userInfo,
				@"latitude": NUMDOUBLE(annotation.coordinate.latitude),
				@"longitude": NUMDOUBLE(annotation.coordinate.longitude),
				@"accessoryTag": [NSNumber numberWithInteger:control.tag],
				};
            
        [self.proxy fireEvent:@"tapOnCalloutAccessoryControl" withObject:event];
    }
}


- (void)mapView:(RMMapView *)mapView didSelectAnnotation:(RMAnnotation *)annotation {
	
	if ([self.proxy _hasListeners:@"selectAnnotation"]) {
		
		UaMapboxAnnotationProxy *annotationProxy = [(UaMapboxAnnotation *)annotation proxy];
		
		NSDictionary *event;
		
		event = @{
				  @"annotation": annotationProxy != nil ? annotationProxy : [NSNull null],
				  @"userInfo": annotation.userInfo,
				  @"latitude": NUMDOUBLE(annotation.coordinate.latitude),
				  @"longitude": NUMDOUBLE(annotation.coordinate.longitude),
				  };
		
		[self.proxy fireEvent:@"selectAnnotation" withObject:event];
	}
}


- (void)mapView:(RMMapView *)mapView didDeselectAnnotation:(RMAnnotation *)annotation {
	
	if ([self.proxy _hasListeners:@"deselectAnnotation"]) {
		
		UaMapboxAnnotationProxy *annotationProxy = [(UaMapboxAnnotation *)annotation proxy];
		
		NSDictionary *event;
		
		event = @{
				  @"annotation": annotationProxy != nil ? annotationProxy : [NSNull null],
				  @"userInfo": annotation.userInfo,
				  @"latitude": NUMDOUBLE(annotation.coordinate.latitude),
				  @"longitude": NUMDOUBLE(annotation.coordinate.longitude),
				  };
		
		[self.proxy fireEvent:@"deselectAnnotation" withObject:event];
	}
}


- (void)doubleTapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
	
	if ([self.proxy _hasListeners:@"doubleTapOnAnnotation"]) {
		
		UaMapboxAnnotationProxy *annotationProxy = [(UaMapboxAnnotation *)annotation proxy];
		
		NSDictionary *event;
		
		event = @{
				  @"annotation": annotationProxy != nil ? annotationProxy : [NSNull null],
				  @"userInfo": annotation.userInfo,
				  @"latitude": NUMDOUBLE(annotation.coordinate.latitude),
				  @"longitude": NUMDOUBLE(annotation.coordinate.longitude),
				  };
		
		[self.proxy fireEvent:@"doubleTapOnAnnotation" withObject:event];
	}
}


- (void)longPressOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
	
	if ([self.proxy _hasListeners:@"longPressOnAnnotation"]) {
		
		UaMapboxAnnotationProxy *annotationProxy = [(UaMapboxAnnotation *)annotation proxy];
		
		NSDictionary *event = @{
				  @"annotation": annotationProxy != nil ? annotationProxy : [NSNull null],
				  @"userInfo": annotation.userInfo,
				  @"latitude": NUMDOUBLE(annotation.coordinate.latitude),
				  @"longitude": NUMDOUBLE(annotation.coordinate.longitude),
				  };
		
		[self.proxy fireEvent:@"longPressOnAnnotation" withObject:event];
	}
}


- (void)mapViewWillStartLocatingUser:(RMMapView *)mapView {
	
	if ([self.proxy _hasListeners:@"startLocatingUser"]) {
		
		[self.proxy fireEvent:@"startLocatingUser"];
	}
}


- (void)mapViewDidStopLocatingUser:(RMMapView *)mapView {
	
	if ([self.proxy _hasListeners:@"stopLocatingUser"]) {
		
		[self.proxy fireEvent:@"stopLocatingUser"];
	}
}


- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation {
	
	if ([self.proxy _hasListeners:@"updateUserLocation"]) {
		
		NSDictionary *head = @{
							   @"headingAccuracy": NUMDOUBLE(userLocation.heading.headingAccuracy),
							   @"magneticHeading": NUMDOUBLE(userLocation.heading.magneticHeading),
							   @"trueHeading": NUMDOUBLE(userLocation.heading.trueHeading),
							   };
		
		NSDictionary *coords = @{
								 @"latitude": NUMDOUBLE(userLocation.location.coordinate.latitude),
								 @"longitude": NUMDOUBLE(userLocation.location.coordinate.longitude),
								 @"course": NUMDOUBLE(userLocation.location.course),
								 @"horizontalAccuracy": NUMDOUBLE(userLocation.location.horizontalAccuracy),
								 @"speed": NUMDOUBLE(userLocation.location.speed),
								 @"verticalAccuracy": NUMDOUBLE(userLocation.location.verticalAccuracy),
								 @"altitude": NUMDOUBLE(userLocation.location.altitude),
								 };
		
		NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];
		
		[tiEvent setObject:head forKey:@"heading"];
		[tiEvent setValue:NUMBOOL(userLocation.isUpdating) forKey:@"isUpdating"];
		[tiEvent setObject:coords forKey:@"coords"];
		
		[self.proxy fireEvent:@"updateUserLocation" withObject:tiEvent];
	}
}


- (void)mapView:(RMMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
	
	if ([self.proxy _hasListeners:@"failToLocateUser"]) {
		
		NSDictionary *event = @{
								@"code": [NSNumber numberWithInteger:error.code],
								@"error": error.localizedDescription,
								@"reason": error.localizedFailureReason,
								@"userInfo": error.userInfo,
								};
		
		[self.proxy fireEvent:@"failToLocateUser" withObject:event];
	}
}


- (void)mapView:(RMMapView *)mapView didChangeUserTrackingMode:(RMUserTrackingMode)mode animated:(BOOL)animated {
	
	if ([self.proxy _hasListeners:@"userTrackingModeChange"]) {
		
		NSDictionary *event = @{
								@"mode": @(mode),
								@"animated": NUMBOOL(animated)
								};
		
		[self.proxy fireEvent:@"userTrackingModeChange" withObject:event];
	}
}


- (RMMapLayer *)mapView:(RMMapView *)map layerForAnnotation:(RMAnnotation *)annotation {
    
    NSLog(@"[MapboxMapView] mapViewWithLayerForAnnotation");
    
    
    // Check for user location annotation and other things we know nothing about
    if (![annotation isKindOfClass:[UaMapboxAnnotation class]]) {
        return nil;
    }
    
    UaMapboxMarker *marker = [[(UaMapboxAnnotation *)annotation proxy] marker];
    
    marker.canShowCallout = YES;
    
    return marker;
}

@end
