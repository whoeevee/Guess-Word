//
//  WordRowView.swift
//  Guess Word
//
//  Created by eevee on 03/08/2023.
//

import SwiftUI

struct WordRowView: View {
    
    @Binding var guessData: GuessData
    var showWord: Bool
    
    var body: some View {
        LazyVStack {
            
            HStack {
                
                Text(
                    showWord
                    ? guessData.word
                    : "•••••"
                )
                .font(
                    .system(
                        size: showWord ? 18 : 28,
                        weight: showWord ? .medium : .heavy
                    )
                )

                Spacer()

                Text("\(guessData.order)")
                    .font(.system(size: 20, weight: .heavy))
            }
            .padding(.horizontal, 15)
            .padding(.vertical, showWord ? 12 : 6)
        }
        
        .frame(maxWidth: .infinity)
        .background(
         RoundedRectangle(cornerRadius: 15, style: .continuous)
             .foregroundColor(
                TextUtil.textColor(for: guessData.order)
             )
        )
    }
}
