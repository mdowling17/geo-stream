//
//  MapSettingsView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/5/24.
//

import SwiftUI

struct MapSettingsView: View {
    @Binding var mapSettings: MapSettings 
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                LabeledContent("Base Style") {
                    Picker("Base Style", selection: $mapSettings.baseStyle) {
                        ForEach(MapSettings.BaseMapStyle.allCases, id: \.self) { type in
                            Text(type.label)
                        }
                    }
                }
                LabeledContent("Elevation") {
                    Picker("Elevation", selection: $mapSettings.elevation) {
                        Text("Flat").tag(MapSettings.MapElevation.flat)
                        Text("Realistic").tag(MapSettings.MapElevation.realistic)
                    }
                }
                if mapSettings.baseStyle != .imagery {
                    LabeledContent("Points of Interest") {
                        Picker("Points of Interest", selection: $mapSettings.pointsOfInterest) {
                            Text("None").tag(MapSettings.MapPOI.excludingAll)
                            Text("All").tag(MapSettings.MapPOI.all)
                        }
                    }
                    Toggle("Show Traffic", isOn: $mapSettings.showTraffic)
                }
            }
            .padding()
            .navigationTitle("Map Style")
            .navigationBarTitleDisplayMode(.inline)
            Spacer()
        }
    }
}


#Preview {
    MapSettingsView(mapSettings: .constant(MapSettings.init()))
}

