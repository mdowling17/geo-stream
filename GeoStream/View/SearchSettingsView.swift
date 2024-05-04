//
//  SearchSettingsView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import SwiftUI

struct SearchSettingsView: View {
    @EnvironmentObject var mapVM: MapViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Distance")) {
                    Toggle("Enable Distance", isOn: $mapVM.distanceSettingEnabled)
                    if mapVM.distanceSettingEnabled {
                        Stepper(value: $mapVM.distanceSetting, in: 5...25000, step: 5) {
                            Text("\(mapVM.distanceSetting) miles")
                        }
                    }
                }
                
                Section(header: Text("Timeframe")) {
                    Toggle("Enable Timeframe", isOn: $mapVM.timeframeSettingEnabled)
                    if mapVM.timeframeSettingEnabled {
                        Stepper(value: $mapVM.timeframeSetting, in: 1...168) {
                            Text("\(mapVM.timeframeSetting) hours")
                        }
                    }
                }
            }
            .navigationTitle("Search Settings")
        }
    }
}

struct SearchSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchSettingsView().environmentObject(MapViewModel())
    }
}
