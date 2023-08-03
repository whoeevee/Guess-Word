//
//  ContentView.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        RoomsView()
        
        .onAppear {
            if UserPreferences.shared.djangoSessionId() == nil {
                UserPreferences.shared.updateDjangoSessionId(
                    sessionId: UUID().uuidString
                )
            }
        }
    }
}
