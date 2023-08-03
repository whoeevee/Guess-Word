//
//  UIApplication+keyWindow.swift
//  Guess Word
//
//  Created by eevee on 03/08/2023.
//

import Foundation
import SwiftUI

extension UIApplication {
    var keyWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}
