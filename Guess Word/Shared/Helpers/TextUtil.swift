//
//  Util.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import Foundation
import SwiftUI

struct TextUtil {
    
    static func textColor(for score: Int) -> Color {
        let normalizedScore = Double(score) / 500
        let red = normalizedScore
        let green = 1.0 - normalizedScore
        return Color(red: red, green: green, blue: 0)
            .opacity(0.6)
    }
}
