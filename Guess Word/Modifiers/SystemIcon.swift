//
//  SystemImageButton.swift
//  Guess Word
//
//  Created by eevee on 25/07/2023.
//

import Foundation
import SwiftUI

struct SystemIcon: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .medium))
    }
}

