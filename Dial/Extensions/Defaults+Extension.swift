//
//  Defaults+Extension.swift
//  Dial
//
//  Created by KrLite on 2024/3/21.
//

import Defaults
import Foundation

extension Defaults.Keys {
    static let globalHapticsEnabled = Key<Bool>("hapticsEnabled", default: true)
    static let menuBarItemEnabled = Key<Bool>("menuBarItemEnabled", default: true)
    static let menuBarItemAutoHidden = Key<Bool>("menuBarItemAutoHidden", default: false)
    
    static let globalSensitivity = Key<Sensitivity>("globalSensitivity", default: .natural)
    static let globalDirection = Key<Direction>("globalDirection", default: .clockwise)
    
    static let activatedControllerIDs: Key<[ControllerID]> = {
        Task { @MainActor in
            notifyTaskStart("validate controller indexes")
            
            for await controllers in Defaults.updates(.activatedControllerIDs) {
                if controllers.isEmpty {
                    // No controller is activated
                    Defaults[.currentControllerID] = nil
                } else {
                    if let index = Defaults.currentControllerIndex {
                        // Make sure the index is valid
                        Defaults.currentControllerIndex = max(0, min(controllers.count, index))
                    } else {
                        // The index is `nil`, reset it
                        Defaults.currentControllerIndex = 0
                    }
                }
            }
        }
        
        return .init("activatedControllerIDs", default: [
            .builtin(.scroll),
            .builtin(.playback),
            .builtin(.brightness),
            .builtin(.mission)
        ])
    }()
    static let nonactivatedControllerIDs: Key<[ControllerID]> = .init("nonactivatedControllerIDs", default: [])
    static let currentControllerID = Key<ControllerID?>("currentControllerID", default: nil)
    
    // MARK: - Constants
    
    static let maxControllers = Key<Int>("maxControllers", default: 10)
}

extension Defaults {
    static func saveController(settings: ShortcutsController.Settings) {
        let id = ControllerID.shortcuts(settings)
        print(id.controller.name)
        
        if let activatedIndex = Defaults[.activatedControllerIDs].firstIndex(of: id) {
            Defaults[.activatedControllerIDs][activatedIndex] = id
        }
        
        if let nonactivatedIndex = Defaults[.nonactivatedControllerIDs].firstIndex(of: id) {
            Defaults[.nonactivatedControllerIDs][nonactivatedIndex] = id
        }
    }
    
    static func appendBuiltinController(id: ControllerID.Builtin) {
        Defaults[.nonactivatedControllerIDs].append(.builtin(id))
    }
    
    static func appendNewController() {
        Defaults[.nonactivatedControllerIDs].append(.shortcuts(.init()))
    }
    
    static func removeController(id: ControllerID) {
        Defaults[.activatedControllerIDs].replace([id], with: [])
        Defaults[.nonactivatedControllerIDs].replace([id], with: [])
    }
    
    static var allControllerIDs: [ControllerID] {
        Array(Set(Defaults[.activatedControllerIDs] + Defaults[.nonactivatedControllerIDs]))
    }
    
    static var currentController: Controller? {
        Defaults[.currentControllerID]?.controller
    }
    
    static var currentControllerIndex: Int? {
        get {
            Defaults[.currentControllerID]
                .flatMap { Defaults[.activatedControllerIDs].firstIndex(of: $0) }
        }
        
        set(index) {
            guard
                let index,
                (0..<Defaults[.activatedControllerIDs].count).contains(index)
            else {
                Defaults[.currentControllerID] = nil
                return
            }
            
            let id = Defaults[.activatedControllerIDs][index]
            Defaults[.currentControllerID] = id
        }
    }
    
    static func cycleControllers(_ sign: Int, wrap: Bool = false) {
        guard sign != 0 else { return }
        guard let index = currentControllerIndex else { return }
        
        let cycledIndex = index + sign.signum()
        let count = Defaults[.activatedControllerIDs].count
        let inRange = (0..<count).contains(cycledIndex)
        
        if wrap || inRange {
            let controller = Defaults[.activatedControllerIDs][(cycledIndex + count) % count]
            Defaults[.currentControllerID] = controller
            // TODO: Buzz
        }
    }
}
