//
//  MenuBarIconView.swift
//  Dial
//
//  Created by KrLite on 2024/3/20.
//

import Defaults
import SFSafeSymbols
import SwiftUI

struct MenuBarIconView: View {
    @State var isConnected: Bool = false
    @State var controllerSymbol: SFSymbol?
    
    var body: some View {
        Image(systemSymbol: .hockeyPuckFill)
            .imageScale(.large)
            .opacity(isConnected ? 1 : 0.2)
            .animation(.easeInOut, value: isConnected)
            .task {
                // MARK: Update connection status
            
                for await _ in observationTrackingStream({ dial.hardware.connectionStatus }) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let connectionStatus = dial.hardware.connectionStatus
                        isConnected = connectionStatus.isConnected
                    }
                }
            
                // MARK: Update current controller
            
                for await _ in Defaults.updates(.currentControllerID) {
                    if let controller = Defaults.currentController {
                        controllerSymbol = controller.symbol
                    } else {
                        controllerSymbol = nil
                    }
                }
            }
    }
}
