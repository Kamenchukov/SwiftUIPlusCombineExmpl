//
//  ContentView.swift
//  SwiftUIPlusCombineExmpl
//
//  Created by Константин Каменчуков on 06.07.2022.
//

import SwiftUI
import Combine

class ViewModel: ObservableObject {
    @Published var running = false
    @Published var gameStarted = false
    @Published var emoji1 = "🍓"
    @Published var emoji2 = "🍏"
    @Published var emoji3 = "🍒"
    @Published var titleText = ""
    @Published var buttonText = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let emojiArray = ["🍓", "🍏", "🍒"]
    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init() {
        timer
            .receive(on: RunLoop.main)
            .sink { _ in self.randomizer() }
            .store(in: &cancellables)
        
        $running
            .receive(on: RunLoop.main)
            .map {
                guard !$0 && self.gameStarted else { return "Choose your destiny"}
                return self.emoji1 == self.emoji2 && self.emoji2 == self.emoji3 ? "Victory" : "Damn. Role it again!"
            }
            .assign(to: \.titleText, on: self)
            .store(in: &cancellables)
        
        $running
            .receive(on: RunLoop.main)
            .map { $0 == true ? "Stop!" : "Role it!" }
            .assign(to: \.buttonText, on: self)
            .store(in: &cancellables)
    }
    
    private func randomizer() {
        guard running else {return}
        emoji1 = emojiArray[Int.random(in: 0...emojiArray.count - 1)]
        emoji2 = emojiArray[Int.random(in: 0...emojiArray.count - 1)]
        emoji3 = emojiArray[Int.random(in: 0...emojiArray.count - 1)]
    }
}

struct GameView<Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .font(.system(size: 64.0))
            .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom)))
            .animation(.easeInOut, value: 0.03)
            .id(UUID())
    }
}
struct ContentView: View {
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        
        VStack {
            Spacer()
            Text(viewModel.titleText)
            Spacer()
            
            HStack {
                GameView { Text(viewModel.emoji1) }
                GameView { Text(viewModel.emoji2) }
                GameView { Text(viewModel.emoji3) }
            }
            
            Spacer()
            Button(action: { viewModel.running.toggle(); viewModel.gameStarted = true }, label: { Text(viewModel.buttonText) } )
            Spacer()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
