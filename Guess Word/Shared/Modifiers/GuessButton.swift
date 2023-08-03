//
//  GuessButton.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import Foundation
import SwiftUI

struct GuessButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .foregroundColor(.accentColor)
            )
    }
}
