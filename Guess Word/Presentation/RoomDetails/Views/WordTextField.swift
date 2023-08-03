//
//  WordTextField.swift
//  Guess Word
//
//  Created by eevee on 03/08/2023.
//

import SwiftUI

struct WordTextField: View {
    
    @Binding var inputWord: String
    var roomModel: RoomModel
    var isEnabled: Bool
    
    var body: some View {
        TextField("enter_word".localized, text: $inputWord)
            .accentColor(.white)
            .padding(12)
            .font(.system(size: 18, weight: .medium))
            .frame(maxWidth: .infinity)
            .background(
                 RoundedRectangle(cornerRadius: 15, style: .continuous)
                     .stroke(
                        Color(hex: roomModel.theme)
                            .opacity(isEnabled ? 1 : 0.5),
                         lineWidth: 5
                     )
            )
            .disabled(!isEnabled)
    }
}
