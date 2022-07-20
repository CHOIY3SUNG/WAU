//
//  AdditemView.swift
//  ToP
//
//  Created by Y3SUNG on 2022/07/20.
//

import SwiftUI

struct AdditemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemTitle = ""
    
    @FetchRequest(sortDescriptors: []) private var item: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            Form {
                TextField("", text: $itemTitle)
                Button(action: {
                    saveItem()
                    dismiss()
                }, label: {
                    Text("Save Item").frame(minWidth: 0, maxWidth: .infinity)
                })
            }
            .navigationTitle("글쓰기")
        }
    }
    
    private func saveItem() {
        let newItem = Item(context: viewContext)
        newItem.title = itemTitle
        newItem.order = (item.last?.order ?? 0) + 1
        newItem.timestamp = Date()
        do {
            try viewContext.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

struct AdditemView_Previews: PreviewProvider {
    static var previews: some View {
        AdditemView()
    }
}