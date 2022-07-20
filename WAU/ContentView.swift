//
//  ContentView.swift
//  ToP
//
//  Created by Y3SUNG on 2022/07/20.
//

import SwiftUI
import CoreData
import MapKit

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.order, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Item>
    
    @State private var addItemView = false

    var body: some View {
        TabView() {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                .ignoresSafeArea()
                .onAppear {
                    viewModel.checkIfLocationServicesIsEnabled()
                }
                .tabItem() {
                    Image(systemName: "map")
                    Text("Map")
                }.tag(0)
            
            NavigationView {
                List {
                    ForEach(items) { item in
                        HStack {
                            Text(item.title ?? "")
                        }
                    }
                    .onMove(perform: moveItem)
                    .onDelete(perform: deleteItem)
                }
                .navigationTitle("오늘의 약속")
                .sheet(isPresented: $addItemView) {
                    AdditemView()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {
                            addItemView.toggle()
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                Text("Select an item")
            }
            .tabItem {
                Image(systemName: "checkmark.circle.fill")
                Text("to")
            }.tag(1)
        }
    }
    
    private func moveItem(at sets:IndexSet, destination: Int) {
        let itemToMove = sets.first!
        
        if itemToMove < destination {
            var startIndex = itemToMove + 1
            let endIndex = destination - 1
            var startOrder = items[itemToMove].order
            while startIndex <= endIndex {
                items[startIndex].order = startOrder
                startOrder = startOrder + 1
                startIndex = startIndex + 1
            }
            items[itemToMove].order = startOrder
        }
        else if destination < itemToMove {
            var startIndex = destination
            let endIndex = itemToMove - 1
            var startOrder = items[destination].order + 1
            let newOrder = items[destination].order
            while startIndex <= endIndex {
                items[startIndex].order = startOrder
                startOrder = startOrder + 1
                startIndex = startIndex + 1
            }
            items[itemToMove].order = newOrder
        }
        do {
            try viewContext.save()
        }
        catch {
            print(error.localizedDescription )
        }
    }
    
    private func deleteItem(at offset:IndexSet) {
        withAnimation {
            offset.map{ items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    final class ContentViewModel: NSObject ,ObservableObject, CLLocationManagerDelegate {
        
        @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.55174722580922, longitude: 126.95206213671459), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        var locationManager: CLLocationManager?
        
        func checkIfLocationServicesIsEnabled() {
            if CLLocationManager.locationServicesEnabled() {
                locationManager = CLLocationManager()
                locationManager!.delegate = self
            } else {
                print("No agree or error")
            }
        }
        
        private func checkLocationAuthorization() {
            guard let locationManager = locationManager else { return }
            
            switch locationManager.authorizationStatus {
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                case .restricted:
                    print("restricted")
                case .denied:
                    print("denied")
                case .authorizedAlways, .authorizedWhenInUse:
                region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                @unknown default:
                    break
            }
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            checkLocationAuthorization()
        }
    }
}

