//
//  SpeechToTextView.swift
//  AACAPP
//
//  Created by Daniel Chang on 8/3/25.
//

import SwiftUI
import AVFoundation
import Foundation
import Speech

struct SpeechToTextView: View {
    @ObservedObject var speechManager = SpeechRecognizerManager()
    @State private var sentence: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(sentence, id: \.self) { word in
                        Text(word)
                            .padding(8)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(10)
                            .font(.title2)
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
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(10)
            
            Divider()
            
            Text(speechManager.transcribedText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            HStack {
                Button(speechManager.isRecording ? "Stop Recording" : "Start Recording") {
                    print("button created")
                    if speechManager.isRecording {
                        // Capture the text BEFORE stopping
                        let textToCorrect = speechManager.transcribedText
                        
                        speechManager.stopRecording()
                        print("Input:  "+textToCorrect)

                        // Use captured text with GPT
                        correctSentenceWithGPT(textToCorrect) { correctedText in
                            print("Got something")
                            if let fixed = correctedText {
                                print("Fixed sentence "+fixed)
                                DispatchQueue.main.async {
                                    speechManager.transcribedText = fixed
                                }
                            }
                        }
                    } else {
                        speechManager.startRecording()
                    }
                }
                .font(.title2)
                .padding()
                .background(speechManager.isRecording ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                Button("Add to Sentence") {
                    let words = speechManager.transcribedText.split(separator: " ").map { String($0) }
                    sentence.append(contentsOf: words)
                    speechManager.transcribedText = ""
                }
                .disabled(speechManager.transcribedText.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
        
        .navigationTitle("Speech to Text")
        .padding()
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        AVSpeechSynthesizer().speak(utterance)
    }
    
    func loadOpenAIKeyFromInfoPlist() -> String? {
        Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String
    }
    
    func correctSentenceWithGPT(_ sentence: String, completion: @escaping (String?) -> Void) {
        guard let apiKey = loadOpenAIKeyFromInfoPlist() else {
            print("API key missing in Info.plist")
            completion(nil)
            return
        }
        
        let prompt = """
        A user with speech impairments said: "\(sentence)". Please rewrite the sentence with proper grammar, punctuation, and add missing words if needed. Keep it natural and polite.
        """
        
        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that fixes and completes sentences spoken by AAC users."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.4
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
              let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        print("request ready: "+apiKey)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error from GPT request: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status code: \(httpResponse.statusCode)")
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                completion(nil)
                return
            }
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            print("GPT response content: '\(trimmed)'")
            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
        print("Corrected sentence")
    }
}
