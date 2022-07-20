//
//  ToPApp.swift
//  ToP
//
//  Created by Y3SUNG on 2022/07/20.
//

import SwiftUI

@main
struct ToPApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
