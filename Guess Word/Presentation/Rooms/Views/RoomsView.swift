//
//  RoomsView.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import SwiftUI

struct RoomsView: View {
    
    private let rooms = ["easy", "main", "hard"]
    @State private var selectedRoom: String = "main"
    @State private var roomCode: String = ""
    @State private var showInputRoomCodeAlert = false
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                    
                VStack {
                    Image("Logo")
                        .resizable()
                        .frame(maxWidth: 100, maxHeight: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    
                    Text("select_room".localized)
                        .font(.system(size: 24, weight: .bold))
                }
                .padding(.bottom, 45)
                
                HStack {
                    NavigationLink {
                        RoomView(roomCode: selectedRoom)
                    }
                    label: {
                        Text(
                            rooms.contains(selectedRoom)
                            ? selectedRoom.localized
                            : "custom".localizeWithFormat(arguments: selectedRoom)
                        )
                        .modifier(GuessButton())
                    }
                    
                    Menu {
                        ForEach(rooms, id: \.self) { room in
                            Button {
                                selectedRoom = room
                            } label: {
                                Text(room.localized)
                            }
                        }
                        
                        Button {
                            showInputRoomCodeAlert.toggle()
                        } label: {
                            Label("enter_code".localized, systemImage: "character.cursor.ibeam")
                        }
                    }
                    label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .padding(5)
                }
                .padding(.horizontal, 10)
            }
            
            .animation(.easeIn(duration: 0.2), value: selectedRoom)
            
            .alert("enter_room_code".localized, isPresented: $showInputRoomCodeAlert) {
                TextField("room_code".localized, text: $roomCode)
                Button("OK") { selectedRoom = roomCode }
            }
            
            .navigationBarHidden(true)
        }
        
    }
}
