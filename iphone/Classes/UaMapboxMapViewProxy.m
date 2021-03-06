/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "UaMapboxMapViewProxy.h"
#import "UaMapboxMapView.h"
#import "TiUtils.h"

@implementation UaMapboxMapViewProxy

-(UaMapboxAnnotationProxy *)annotationFromArg:(id)arg
{
    NSLog(@"[MapboxMapViewProxy] annotationFromArg");
    
    if ([arg isKindOfClass:[UaMapboxAnnotationProxy class]])
    {
        [(UaMapboxAnnotationProxy *)arg setDelegate:(UaMapboxMapView *)[self view]];
        [arg setPlaced:NO];
        return arg;
    }
    
    ENSURE_TYPE(arg, NSDictionary);
    UaMapboxAnnotationProxy *proxy = [[UaMapboxAnnotationProxy alloc] _initWithPageContext:[self pageContext] args:[NSArray arrayWithObject:arg]];
    
    [proxy setDelegate:(UaMapboxMapView *)[self view]];
    return proxy;
}


-(void)addAnnotation:(id)arg
{
    NSLog(@"[MapboxMapViewProxy] addAnnotation");
    
    ENSURE_SINGLE_ARG(arg, UaMapboxAnnotationProxy);
    TiThreadPerformOnMainThread(^{
        [(UaMapboxMapView *)[self view] addAnnotation:arg];
    }, NO);
}


-(void)setAnnotation:(id)args {
    
    NSLog(@"[MapboxMapViewProxy] setAnnotation");
    
    TiThreadPerformOnMainThread(^{
        [(UaMapboxMapView *)[self view] addAnnotation:args];
    }, NO);
}


-(void)addAnnotations:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);
    TiThreadPerformOnMainThread(^{
        for (NSObject *annotation in (NSArray *)args) {
            [(UaMapboxMapView *)[self view] addAnnotation:annotation];
        }
    }, NO);
}


-(void)addShape:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    TiThreadPerformOnMainThread(^{
        [(UaMapboxMapView *)[self view] addShape:arg];
    }, NO);
}


-(void)removeAnnotation:(id)arg
{
    ENSURE_SINGLE_ARG(arg, UaMapboxAnnotationProxy);
    TiThreadPerformOnMainThread(^{
        [(UaMapboxMapView *)[self view] removeAnnotation:arg];
    }, NO);
}


-(void)removeAnnotations:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);
    TiThreadPerformOnMainThread(^{
        for (NSObject *annotation in (NSArray *)args) {
            [(UaMapboxMapView *)[self view] removeAnnotation:annotation];
        }
    }, NO);
}


-(void)removeAllAnnotations:(id)unused
{
    TiThreadPerformOnMainThread(^{
        [(UaMapboxMapView *)[self view] removeAllAnnotations];
    }, NO);
}


- (void)selectAnnotation:(id)arg
{
    ENSURE_SINGLE_ARG(arg, UaMapboxAnnotationProxy);
	TiThreadPerformOnMainThread(^{
        RMMapView *map = [(UaMapboxMapView *)[self view] mapView];
        if (map != nil) {
            [map selectAnnotation:[(UaMapboxAnnotationProxy *)arg annotationForMapView:map] animated:YES];
        }
    }, NO);
}


- (void)deselectAnnotation:(id)arg
{
    ENSURE_SINGLE_ARG(arg, UaMapboxAnnotationProxy);
    TiThreadPerformOnMainThread(^{
        RMMapView *map = [(UaMapboxMapView *)[self view] mapView];
        if (map != nil) {
            [map deselectAnnotation:[(UaMapboxAnnotationProxy *)arg annotationForMapView:map] animated:NO];
        }
    }, NO);
}


-(id)coordinateFromPoint:(id)args
{
    NSNumber *x;
    NSNumber *y;

    ENSURE_ARG_AT_INDEX(x, args, 0, NSNumber);
    ENSURE_ARG_AT_INDEX(y, args, 1, NSNumber);

    return [(UaMapboxMapView *)[self view] coordinateFromPoint:CGPointMake([x floatValue], [y floatValue])];
}


- (void)setBounds:(id)args {
	
	NSDictionary *southWest;
	NSDictionary *northEast;
	
	ENSURE_ARG_AT_INDEX(southWest, args, 0, NSDictionary);
	ENSURE_ARG_AT_INDEX(northEast, args, 1, NSDictionary);
	
	TiThreadPerformOnMainThread(^{
		UaMapboxMapView *map = (UaMapboxMapView *)[self view];
		if (map != nil) {
			[(UaMapboxMapView *)[self view] setBoundariesSouthWest:southWest northEast:northEast];
		}
	}, NO);
}


- (void)zoomToBounds:(id)args {
	
	NSDictionary *southWest;
	NSDictionary *northEast;
	
	ENSURE_ARG_AT_INDEX(southWest, args, 0, NSDictionary);
	ENSURE_ARG_AT_INDEX(northEast, args, 1, NSDictionary);
	
	TiThreadPerformOnMainThread(^{
		UaMapboxMapView *map = (UaMapboxMapView *)[self view];
		if (map != nil) {
			[(UaMapboxMapView *)[self view] zoomToLatitudeLongitudeBoundsSouthWest:southWest northEast:northEast];
		}
	}, NO);
}


@end
