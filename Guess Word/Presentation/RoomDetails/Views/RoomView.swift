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
    
    @StateObject private var viewModel = RoomViewModel()
    
    @State private var loadingState = LoadingState.loading
    
    @State private var showWords = true
    @State private var canInput = true
    @State private var inputWord = ""
    
    @FocusState private var focusOnWordTextField: Bool
    
    var body: some View {
        
        VStack {
            
            switch loadingState {
                
            case .loading:
                ProgressView("loading".localized)
                
            case .loaded:
                
                VStack {
                    
                    ZStack {
                        
                        Text(viewModel.roomModel?.name.uppercased() ?? "")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(
                                VStack {
                                    viewModel.roomModel != nil
                                    ? Color(hex: viewModel.roomModel!.theme)
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
                        roomModel: viewModel.roomModel!,
                        isEnabled: canInput
                    )
                    
                    .padding(.horizontal, 10)
                    
                    .focused($focusOnWordTextField)
                    
                    .onSubmit {
                        Task {
                            if !inputWord.isEmpty {
                                
                                canInput.toggle()
                    
                                await viewModel.submitGuess(guess: inputWord)
                                
                                inputWord = ""
                                canInput.toggle()
                                
                                if viewModel.isWordGuessed {
                                    showWords = false
                                }
                                
                                focusOnWordTextField = true
                            }
                        }
                    }
                    
                    //
    
                    ScrollView {
                        ForEach(
                            $viewModel.guesses
                            .sorted { $0.order.wrappedValue < $1.order.wrappedValue }
                        ) { guess in
                            LazyVStack {
                                WordRowView(guessData: guess, showWord: showWords)
                                    .padding(.horizontal, 10)
                            }
                        }
                    }
                    .animation(.default, value: viewModel.guesses)
                    .padding(.top, 10)
                }
                
            }
        }
        
        .animation(.easeInOut, value: canInput)
        .animation(.easeInOut, value: showWords)
        .animation(.easeInOut, value: loadingState)
        
        .onTapGesture {
            focusOnWordTextField = false
        }
        
        .navigationBarHidden(true)
        
        .onAppear {
            Task {
                viewModel.setup(roomCode: roomCode)
                await viewModel.loadRoom()
                await viewModel.loadHistory()
                
                if viewModel.errorDescription == nil {
                    loadingState = .loaded
                }
            }
        }
        
        .alert(
            "error_occurred".localized,
            isPresented: Binding<Bool>(
                get: { viewModel.errorDescription != nil },
                set: { _ in }
            ),
            actions: {
                viewModel.loadingRoomError
                ? Button("go_back".localized) {
                    dismiss()
                    viewModel.loadingRoomError = false
                    viewModel.errorDescription = nil
                }
                : Button("OK") {
                    viewModel.errorDescription = nil
                }
            },
            message: { Text(viewModel.errorDescription ?? "") }
        )
        
        .alert(
            "congratulations".localized,
            isPresented: $viewModel.isWordGuessed,
            actions: {
                Button("OK") {
                    showWords = true
                }
            },
            message: {
                Text(
                    "\("attempts_count".localizeWithFormat(arguments: String(viewModel.attemptsCount)))"
                    + "\n"
                    + "\("you_guessed_faster_than".localizeWithFormat(arguments: String(viewModel.fasterThan)))"
                 )
            }
        )
    }
}
