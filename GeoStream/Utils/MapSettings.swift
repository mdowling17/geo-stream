//
//  MapSettings.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/5/24.
//

import SwiftUI
import MapKit

struct MapSettings {
    enum BaseMapStyle: CaseIterable, Codable {
        case standard, hybrid, imagery
        var label: String {
            switch self {
            case .standard:
                "Standard"
            case .hybrid:
                "Satellite with roads"
            case .imagery:
                "Satellite only"
            }
        }
    }
    
    enum MapElevation: Codable {
        case flat, realistic
        var selection: MapStyle.Elevation {
            switch self {
            case .flat:
                    .flat
            case .realistic:
                    .realistic
            }
        }
    }
    
    enum MapPOI: Codable {
        case all, excludingAll
        var selection: PointOfInterestCategories {
            switch self {
            case .all:
                    .all
            case .excludingAll:
                    .excludingAll
            }
        }
    }
    
    var baseStyle = BaseMapStyle.standard
    var elevation = MapElevation.flat
    var pointsOfInterest = MapPOI.excludingAll
    var showTraffic = false
    

    var mapStyle: MapStyle {
        switch baseStyle {
        case .standard:
            MapStyle.standard(elevation: elevation.selection, pointsOfInterest: pointsOfInterest.selection, showsTraffic: showTraffic)
        case .hybrid:
            MapStyle.hybrid(elevation: elevation.selection, pointsOfInterest: pointsOfInterest.selection, showsTraffic: showTraffic)
        case .imagery:
            MapStyle.imagery(elevation: elevation.selection)
        }
    }
}

extension MapSettings: Codable {
    private enum CodingKeys: String, CodingKey {
        case baseStyle, 
             elevation,
             pointsOfInterest,
             showTraffic
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        baseStyle = try container.decode(BaseMapStyle.self, forKey: .baseStyle)
        elevation = try container.decode(MapElevation.self, forKey: .elevation)
        pointsOfInterest = try container.decode(MapPOI.self, forKey: .pointsOfInterest)
        showTraffic = try container.decode(Bool.self, forKey: .showTraffic)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(baseStyle, forKey: .baseStyle)
        try container.encode(elevation, forKey: .elevation)
        try container.encode(pointsOfInterest, forKey: .pointsOfInterest)
        try container.encode(showTraffic, forKey: .showTraffic)
    }
}
