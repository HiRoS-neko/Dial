//
//  DialApp.swift
//  Dial
//
//  Created by KrLite on 2024/3/20.
//

import SwiftUI
import SettingsAccess
import MenuBarExtraAccess

var dial: SurfaceDial = .init()

@main
struct DialApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var isStatusItemPresented: Bool = false
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
        
        MenuBarExtra("Dial", image: "None") {
            SettingsLink(
                label: {
                    Text("Settings…")
                },
                preAction: {
                    for window in NSApp.windows where window.toolbar?.items != nil {
                        window.close()
                    }
                },
                postAction: {
                    for window in NSApp.windows where window.toolbar?.items != nil {
                        window.orderFrontRegardless()
                        window.center()
                    }
                }
            )
            .keyboardShortcut(",", modifiers: .command)
            
            Button("About \(Bundle.main.appName)") {
                
            }
            .keyboardShortcut("i", modifiers: .command)
            
            Divider()
            
            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .menuBarExtraStyle(.menu)
        .menuBarExtraAccess(isPresented: $isStatusItemPresented) { statusItem in
            guard
                // Init once
                let button = statusItem.button,
                button.subviews.count == 0
            else { return }
            
            statusItem.length = 32
            
            let view = NSHostingView(rootView: StatusIconView())
            view.frame.size = .init(width: 32, height: NSStatusBar.system.thickness)
            button.addSubview(view)
        }
    }
}
