//
//  VEFSViewController.h
//  Veespo
//
//  Created by Alessio Roberto on 24/09/13.
//  Copyright (c) 2013 Veespo Ltd. All rights reserved.
//

#import "VERootViewController.h"
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class FSVenue;

@interface VEFSViewController : VERootViewController <MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MBProgressHUDDelegate> {
    CLLocationManager *_locationManager;
    MKMapView* mapView;
    UICollectionView *venuesCollection;
    MBProgressHUD *HUD;
    
    FSVenue* selected;
    NSMutableArray* nearbyVenues;
}

@end