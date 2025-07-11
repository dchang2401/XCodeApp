//
//  ContentView.swift
//  AACAPP
//
//  Created by Hyunseok Chang on 7/6/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    // Current sentence being built
    @State private var sentence: [String] = []
    
    // Example word panels
    let basicNeeds = ["yes", "no", "you", "want", "don't", "need", "like", "go", "come", "to"]
    let pronouns = ["I", "they", "he", "she", "we", "it"]
    let people = ["mom", "dad", "teacher", "friend", "baby", "nurse", "doctor"]
    let actions = ["eat", "go", "play", "sleep", "read", "draw", "write", "sing", "talk", "jump", "sit", "stand", "open", "close"]
    let food = ["pizza", "apple", "banana", "cookie", "juice", "water", "milk", "cereal", "sandwich"]
    let adjectives = ["big", "small", "hot", "cold", "loud", "quiet", "fast", "slow", "clean", "dirty", "fun", "boring"]
    let feelings = ["happy", "sad", "mad", "scared", "tired", "excited", "bored", "sick", "okay"]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 20) {
                // Display current sentence
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(sentence, id: \.self) { word in
                            Text(word)
                                .padding(8)
                                .background(Color.yellow.opacity(0.7))
                                .cornerRadius(10)
                                .font(.title2)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .padding(.horizontal)
                }
                
                HStack {
                    Button("Clear") {
                        sentence.removeAll()
                    }
                    
                    Button("Undo") {
                        if !sentence.isEmpty {
                            sentence.removeLast()
                        }
                    }
                    
                    Button("Speak") {
                        let fullSentence = sentence.joined(separator: " ")
                        if !fullSentence.isEmpty {
                            speak(fullSentence)
                        }
                    }
                }
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
                
                Divider()
                
                // Word panels
                WordPanel(title: "Basic", words: basicNeeds, sentence: $sentence, showImages: false)
                WordPanel(title: "Pronouns", words: pronouns, sentence: $sentence, showImages: false)
                WordPanel(title: "People", words: people, sentence: $sentence)
                WordPanel(title: "Actions", words: actions, sentence: $sentence)
                WordPanel(title: "Food", words: food, sentence: $sentence)
                WordPanel(title: "Adjectives", words: adjectives, sentence: $sentence)
                WordPanel(title: "Feelings", words: feelings, sentence: $sentence)
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - WordPanel Reusable View
    struct WordPanel: View {
        let title: String
        let words: [String]
        @Binding var sentence: [String]
        var showImages: Bool = true  // default is true
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(words, id: \.self) { word in
                            Button(action: {
                                sentence.append(word)
                            }) {
                                VStack {
                                    if showImages {
                                        // Only show image if enabled
                                        Image(word)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    }
                                    
                                    // Always show text
                                    Text(word)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    let synthesizer = AVSpeechSynthesizer()
    
    func speak(_ text: String) {
        // Stop anything still speaking before starting a new one
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Use the correct voice (if needed)
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-US.Samantha") {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        synthesizer.speak(utterance)
    }
    
    
}
