//
//  RoomView.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import SwiftUI

struct RoomView: View {
    
    var roomCode: String
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var roomViewModel = RoomViewModel()
    
    @State private var roomLoadingState = RoomLoadingState.loading
    
    @State private var showWords = true
    
    @State private var inputWord = ""
    @State private var canInput = true
    
    @FocusState private var focusOnWordTextField: Bool
    
    var body: some View {
        
        VStack {
            
            switch roomLoadingState {
                
            case .loading:
                ProgressView("loading".localized)
                
            case .loaded:
                
                VStack {
                    
                    ZStack {
                        
                        Text(roomViewModel.roomModel?.name.uppercased() ?? "")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(
                                VStack {
                                    roomViewModel.roomModel != nil
                                    ? Color(hex: roomViewModel.roomModel!.theme)
                                    : Color.accentColor
                                }
                                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                                .edgesIgnoringSafeArea(.top)
                            )
                        
                        //
                        
                        HStack {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .modifier(SystemIcon())
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                        
                        //
                        
                        HStack(spacing: 15) {
                            
                            Spacer()
                            
                            Button {
                                withAnimation { showWords.toggle() }
                            } label: {
                                Image(systemName: showWords ? "eye" : "eye.slash")
                                    .modifier(SystemIcon())
                            }
                            
                            ShareLink(item: "share_room".localizeWithFormat(arguments: roomCode)) {
                                Image(systemName: "square.and.arrow.up")
                                    .modifier(SystemIcon())
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    
                    .padding(.bottom, 5)
                    
                    //
                    
                    WordTextField(
                        inputWord: $inputWord,
                        roomModel: roomViewModel.roomModel!,
                        isEnabled: canInput
                    )
                    
                    .padding(.horizontal, 10)
                    
                    .focused($focusOnWordTextField)
                    
                    .onSubmit {
                        Task {
                            if inputWord != "" {
                                withAnimation { canInput.toggle() }
                                await roomViewModel.submitGuess(guess: inputWord)
                                withAnimation { inputWord = ""; canInput.toggle() }
                                
                                if roomViewModel.isWordGuessed {
                                    withAnimation { showWords = false }
                                }
                                focusOnWordTextField = true
                            }
                        }
                    }
                    
                    //
    
                    ScrollView {
                        ForEach(
                            $roomViewModel.guesses
                            .sorted { $0.order.wrappedValue < $1.order.wrappedValue }
                        ) { guess in
                            WordRowView(guessData: guess, showWord: showWords)
                            .padding(.horizontal, 10)
                        }
                    }
                    .animation(.default, value: roomViewModel.guesses)
                    .padding(.top, 10)
                }
                
            }
        }
        
        .onTapGesture {
            focusOnWordTextField = false
        }
        
        .navigationBarHidden(true)
        
        .onAppear {
            Task {
                roomViewModel.setup(roomCode: roomCode)
                await roomViewModel.loadRoomAndHistory()
                
                if roomViewModel.errorCode == nil {
                    withAnimation { roomLoadingState = .loaded }
                }
            }
        }
        
        .alert(
            "error_occurred".localized,
            isPresented: Binding<Bool>(
                get: { roomViewModel.errorCode != nil },
                set: { _ in }
            ),
            actions: {
                roomViewModel.errorCode == "loading_room_error"
                ? Button("go_back".localized) {
                    dismiss()
                    roomViewModel.errorCode = nil
                    roomViewModel.errorDetail = nil
                }
                : Button("OK") {
                    roomViewModel.errorCode = nil
                    roomViewModel.errorDetail = nil
                }
            },
            message: { Text(roomViewModel.errorDetail ?? "") }
        )
        
        .alert(
            "congratulations".localized,
            isPresented: $roomViewModel.isWordGuessed,
            actions: {
                Button("OK") {
                    withAnimation(.easeInOut(duration: 0.2)) { showWords = true }
                }
            },
            message: {
                Text(
                    "\("attempts_count".localizeWithFormat(arguments: String(roomViewModel.attemptsCount)))"
                    + "\n"
                    + "\("you_guessed_faster_than".localizeWithFormat(arguments: String(roomViewModel.fasterThan)))"
                 )
            }
        )
    }
}
