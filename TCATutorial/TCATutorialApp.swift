//
//  TCATutorialApp.swift
//  TCATutorial
//
//  Created by Greed on 7/23/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCATutorialApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: TCATutorialApp.store)
        }
    }
}
