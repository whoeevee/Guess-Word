//
//  RoomView.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import SwiftUI

struct RoomView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State var roomCode: String
    
    @State private var room: Room? = nil
    @State private var roomLoadingState = RoomLoadingState.loading
    
    @State private var inputWord = ""
    @State private var canInput = true
    
    @State private var showErrorAlert = false
    @State private var errorCode = ""
    @State private var errorDetail = ""
    
    @State private var guessApi = GuessApi(
        djangoSessionId: UserPreferences.shared.djangoSessionId() ?? ""
    )
    @State private var guesses: [GuessData] = []
    
    @State private var showCongratsAlert = false
    @State private var tryCount = 0
    @State private var fasterThan = 0
    
    @State private var showWords = true
    
    //
    
    private func loadRoom() async throws {
        room = try await guessApi.getRoomInfo(code: roomCode)
    }
    
    private func loadHistory() async throws {
        guesses = try await guessApi.getHistory(roomCode: roomCode).map {
            GuessData(word: $0.word, order: $0.order)
        }
    }
    
    private func back() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func shareRoom() {
        
        let activityController = UIActivityViewController(
            activityItems: ["share_room".localizeWithFormat(arguments: roomCode)],
            applicationActivities: nil
        )
        
        UIApplication.shared.keyWindow!.rootViewController!.present(
            activityController,
            animated: true,
            completion: nil
        )
    }
    
    //
    
    var body: some View {
        
        VStack {
            
            switch roomLoadingState {
                
            case .loading:
                ProgressView("loading".localized)
                
            case .loaded:
                
                VStack {
                    
                    ZStack {
                        
                        Text(room!.name.uppercased())
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(
                                 Color(hex: room!.theme)
                                     .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                                     .edgesIgnoringSafeArea(.top)
                            )
                        
                        //
                        
                        HStack {
                            Button { back() } label: {
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
                            
                            Button { shareRoom() } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .modifier(SystemIcon())
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .padding(.bottom, 5)
                    
                    //
    
                    TextField("enter_word".localized, text: $inputWord)
                    
                        .accentColor(.white)
                        .padding(12)
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity)
    
                        .background(
                             RoundedRectangle(cornerRadius: 15, style: .continuous)
                                 .stroke(
                                     Color(hex: room!.theme)
                                         .opacity(canInput ? 1 : 0.5),
                                     lineWidth: 5
                                 )
                        )
                        .padding(.horizontal, 10)
                    
                        .disabled(!canInput)
                    
                        .onSubmit {
                            
                            Task {
                                withAnimation { canInput.toggle() }
    
                                let word = inputWord
                                inputWord = ""
    
                                do {
                                    
                                    let data = try await guessApi.submitGuess(
                                        roomCode: roomCode,
                                        word: word
                                    )
                                    
                                    if (!data.already_guessed!) {
                                        
                                        withAnimation {
                                            guesses.append(GuessData(word: data.word, order: data.order))
                                        }
                                        
                                        if (data.finish_stat != nil) {
                                            
                                            showCongratsAlert.toggle()
                                            tryCount = data.finish_stat!.try_count
    
                                            fasterThan = Int(
                                                (data.finish_stat!.faster * 100).rounded()
                                            )
    
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                showWords.toggle()
                                            }
                                        }
                                    }
    
                                }
                                catch GuessException.requestException(let code, let detail) {
                                    
                                    let localizedDetail = code.localized
                                    
                                    showErrorAlert = true
                                    
                                    errorCode = code
                                    errorDetail = localizedDetail == code ? detail : localizedDetail
                                }
    
                                withAnimation { canInput.toggle() }
                            }
                        }
    
                    ScrollView {
                        
                        ForEach(
                         $guesses
                         .sorted { $0.order.wrappedValue < $1.order.wrappedValue }
                        ) { guess in
    
                            LazyVStack {
                                
                                HStack {
                                    
                                    Text(
                                        showWords
                                        ? guess.word.wrappedValue
                                        : "•••••"
                                    )
                                    .font(
                                        .system(
                                            size: showWords ? 18 : 28,
                                            weight: showWords ? .medium : .heavy
                                        )
                                    )
    
                                    Spacer()
    
                                    Text("\(guess.order.wrappedValue)")
                                        .font(.system(size: 20, weight: .heavy))
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, showWords ? 12 : 6)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                             RoundedRectangle(cornerRadius: 15, style: .continuous)
                                 .foregroundColor(
                                    Util.textColor(for: guess.order.wrappedValue)
                                 )
                            )
                            .padding(.horizontal, 10)
                        }
                    }
                    .padding(.top, 10)
                }
                
            }
        }
        
        .onAppear {
            Task {
                do {
                    try await loadRoom()
                    try await loadHistory()
                    withAnimation { roomLoadingState = .loaded }
                }
                catch {
                    errorCode = "loading_room_error"
                    errorDetail = "loading_room_error".localized
                    
                    showErrorAlert = true
                }
            }
        }
        
        .navigationBarHidden(true)
        
        .alert(
            "error_occurred".localized,
            isPresented: $showErrorAlert,
            actions: {
                if (errorCode == "loading_room_error") {
                    Button("go_back".localized) { back() }
                }
            },
            message: {
                Text(errorDetail)
            }
        )
        
        .alert(
            "congratulations".localized,
            isPresented: $showCongratsAlert,
            actions: {
                Button("OK") {
                    withAnimation(.easeInOut(duration: 0.2)) { showWords.toggle() }
                }
            },
            message: {
                Text(
                    "\("attempts_count".localizeWithFormat(arguments: String(tryCount)))"
                     + "\n"
                     + "\("you_guessed_faster_than".localizeWithFormat(arguments: String(fasterThan)))"
                 )
            }
        )
        
    }
}
