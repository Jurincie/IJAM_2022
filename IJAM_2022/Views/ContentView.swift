//
//  ContentView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/13/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var contentVM = ContentViewModel(context:coreDataManager.shared.PersistentStoreController.viewContext)
     
    var body: some View {
        GeometryReader { geo in
            let height      = min(geo.size.height, 1100.0)
            let width       = min(geo.size.width, 500.0)
            let xOffset     = max( 0.0, geo.size.width - width)
            let yOffset     = max( 0.0, geo.size.height - height)
            let centered    = CGPoint(x:(width + xOffset) / 2, y:(height + yOffset) / 2)

            VStack(spacing: 0) {
                HeaderView(width: width, height: height * 0.20 )
                    .aspectRatio(contentMode: .fit)
                    .background(Color.black)
                
                TopView(width:width, height:height * 0.30)
                    .aspectRatio(contentMode: .fit)
                
                StringsAndFretsAreaView(width:width, height:height * 0.40, dragOffset:xOffset / 2)
                    .aspectRatio(contentMode: .fit)

                BottomView(width: width, height:height * 0.10)
                    .aspectRatio(contentMode: .fit)
                    .background(Color.black)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white, lineWidth: 5))
    
            .frame(width:width, height:height)
            .position(centered)
        }
        // this injects the contentVM into the environment for all to use
        .environmentObject(contentVM)
        .background(Color.black)
        .onChange(of: scenePhase) { newPhase in
            switch(newPhase) {
                case .inactive: print("Inactive")
                case .active: print("Active")
                case .background: print("Background")
                default: print("UNKNOWN")
            }
        }
        .onAppear {
//            print("ContentView appeared!")
        }
        .onDisappear {
//            print("ContentView disappeared!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = coreDataManager.shared.PersistentStoreController.viewContext
        
        ContentView()
            .environmentObject(ContentViewModel(context: viewContext))
    }
}
