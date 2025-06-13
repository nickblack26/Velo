//
//  VeloApp.swift
//  Velo
//
//  Created by Nick Black on 6/9/25.
//

import SwiftUI

@main
struct VeloApp: App {
    @State private var veloManager = VeloManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(veloManager)
        }
    }
}
