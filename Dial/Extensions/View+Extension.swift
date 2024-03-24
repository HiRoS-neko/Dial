//
//  View+Extension.swift
//  Dial
//
//  Created by KrLite on 2024/3/23.
//

import Foundation
import SwiftUI

extension View {
    func or(condition: Bool, _ another: () -> Self) -> Self {
        condition ? another() : self
    }
    
    @ViewBuilder
    func orSomeView(condition: Bool, _ another: () -> some View) -> some View {
        if condition {
            another()
        } else {
            self
        }
    }
}
