//
//  ContentView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/13/22.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var iJamVM = IjamViewModel(context:coreDataManager.shared.PersistentStoreController.viewContext)
    
    var body: some View {
        GeometryReader { geo in
            let height  = min(geo.size.height, 1100.0)
            let width   = min(geo.size.width, 500.0)
            let xOffset = max( 0.0, geo.size.width - width)
            let yOffset = max( 0,0, geo.size.height - height)
            
            let centered = CGPoint(x:(width + xOffset) / 2, y:(height + yOffset) / 2)

            VStack(spacing: 0) {
                HeaderView(width: width, height: height * 0.10 )
                    .aspectRatio(contentMode: .fit)
                
                TopView(width:width, height:height * 0.25)
                    .aspectRatio(contentMode: .fit)
                
                StringsAndFretsAreaView(width:width, height:height * 0.50)
                    .aspectRatio(contentMode: .fit)

                BottomView(width: width, height:height * 0.15)
                    .aspectRatio(contentMode: .fit)
            }
    
            .frame(width:width, height:height)
            .position(centered)
        }
        .environmentObject(iJamVM)  // inject viewManager into environment
        .background(Color.black)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white, lineWidth: 4)
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = coreDataManager.shared.PersistentStoreController.viewContext
        
        ContentView()
            .environmentObject(IjamViewModel(context: viewContext))
    }
}
