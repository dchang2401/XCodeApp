//
//  ContentView.swift
//  AACAPP
//
//  Created by Daniel Chang on 7/6/25.
//

import SwiftUI
import AVFoundation
import Foundation
import Speech



struct ContentView: View {
    var body: some View {
        NavigationStack {
            MainMenuView()
        }
    }
}




struct MainMenuView: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("AAC App")
                .font(.largeTitle)
                .bold()

            NavigationLink("Core Vocabulary") {
                CoreVocabView()
            }
            .font(.title2)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            NavigationLink(" Make Your Own") {
                CustomWordsView()
            }
            .font(.title2)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            NavigationLink("Speech to Text") {
                SpeechToTextView()
            }
            .font(.title2)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            NavigationLink("Therapy") {
                TherapySessionView()
            }
            .font(.title2)
            .padding()
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(12)

            Spacer()
        }
        .padding()
    }
}





struct CoreVocabView: View {
    @State private var sentence: [String] = []

    let basicNeeds = ["yes", "no", "you", "want", "don't", "need", "like", "go", "come", "to"]
    let pronouns = ["I", "they", "he", "she", "we", "it"]
    let people = ["mom", "dad", "teacher", "friend", "baby", "nurse", "doctor"]
    let actions = ["eat", "go", "play", "sleep", "read", "draw", "write", "sing", "talk", "jump", "sit", "stand", "open", "close"]
    let food = ["pizza", "apple", "banana", "cookie", "juice", "water", "milk", "cereal", "sandwich"]
    let adjectives = ["big", "small", "hot", "cold", "loud", "quiet", "fast", "slow", "clean", "dirty", "fun", "boring"]
    let feelings = ["happy", "sad", "mad", "scared", "tired", "excited", "bored", "sick", "okay"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Sentence Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(sentence, id: \.self) { word in
                            Text(word)
                                .padding(8)
                                .background(Color.yellow.opacity(0.7))
                                .cornerRadius(10)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                }

                // Sentence Controls
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

                // Word Panels
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
        .navigationTitle("Core Vocabulary")
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        AVSpeechSynthesizer().speak(utterance)
    }
}







struct CustomWordsView: View {
    @State private var sentence: [String] = []
    @State private var newWord: String = ""
    @State private var customWords: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            // Sentence Display
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

            // Sentence Controls
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

            // Add Word
            HStack {
                TextField("Enter new word", text: $newWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    let trimmed = newWord.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        customWords.append(trimmed)
                        newWord = ""
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            // Custom Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(customWords, id: \.self) { word in
                        Button(action: {
                            sentence.append(word)
                        }) {
                            Text(word)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Make Your Own")
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        AVSpeechSynthesizer().speak(utterance)
    }
}






class SpeechRecognizerManager: NSObject, ObservableObject {
    @Published var transcribedText: String = ""
    @Published var isRecording = false

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer()

    override init() {
        super.init()
        requestAuthorization()
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition not authorized")
            }
        }
    }
    /*
    func startRecording() {
        transcribedText = ""
        isRecording = true

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                DispatchQueue.main.async {
                    self.isRecording = false
                }
                // Do NOT call stopRecording() here
            }
        }


        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }
    */
    
    func startRecording() {
        transcribedText = ""
        isRecording = true

        // 1. Configure AVAudioSession
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            isRecording = false
            return
        }

        // 2. Prepare recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false // try this as a fallback

        // 3. Cancel any previous task
        recognitionTask?.cancel()
        recognitionTask = nil

        // 4. Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }

        // 5. Start capturing microphone audio
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error.localizedDescription)")
            isRecording = false
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
    }
}








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






struct TherapySessionView: View {
    @ObservedObject var speechManager = SpeechRecognizerManager()

    // List of prompts for this session
    let prompts = [
        "I want some juice.",
        "Can I go outside?",
        "The weather is nice today.",
        "I need help, please.",
        "Where is my phone?"
    ]

    @State private var currentIndex = 0
    @State private var userTranscription = ""
    @State private var feedback = ""
    @State private var score: Int? = nil
    @State private var isFinished = false

    var body: some View {
        VStack(spacing: 20) {
            if isFinished {
                Text("✅ Practice Complete!")
                    .font(.largeTitle)
                    .bold()
                Text("You completed all \(prompts.count) prompts.")
                Spacer()
            } else {
                Text("Prompt \(currentIndex + 1) of \(prompts.count)")
                    .font(.headline)

                Text("Say this:")
                Text("“\(prompts[currentIndex])”")
                    .font(.title2)
                    .padding()
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(10)

                Divider()

                Text("Your Transcription:")
                Text(userTranscription)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                if let score = score {
                    Text("🟢 Score: \(score)/10")
                        .font(.title3)
                }

                Text(feedback)
                    .italic()
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)

                HStack {
                    Button(speechManager.isRecording ? "Stop Recording" : "Start Recording") {
                        if speechManager.isRecording {
                            let transcription = speechManager.transcribedText
                            userTranscription = transcription
                            speechManager.stopRecording()
                            print("calling evaluateResponse")
                            evaluateResponse(userSpeech: transcription, expected: prompts[currentIndex])
                        } else {
                            feedback = ""
                            score = nil
                            userTranscription = ""
                            speechManager.startRecording()
                        }
                    }
                    .padding()
                    .background(speechManager.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    if !speechManager.isRecording && score != nil {
                        Button("Next") {
                            advanceToNextPrompt()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Therapy Session")
    }

    func advanceToNextPrompt() {
        userTranscription = ""
        feedback = ""
        score = nil

        if currentIndex + 1 < prompts.count {
            currentIndex += 1
        } else {
            isFinished = true
        }
    }

    func evaluateResponse(userSpeech: String, expected: String) {
        guard let apiKey = loadOpenAIKeyFromInfoPlist() else {
            feedback = "Missing API key."
            return
        }
        print("API key "+apiKey)
        let prompt = """
        A person with aphasia is practicing speaking. The correct sentence was:
        "\(expected)"

        They said:
        "\(userSpeech)"

        Please give helpful feedback and a score out of 10 based on how close their speech was to the correct sentence. Be kind and constructive.
        """

        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a kind and supportive speech therapist for aphasia patients."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.5
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
              let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            feedback = "Failed to prepare GPT request."
            return
        }

        print("apiKey: "+apiKey)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                DispatchQueue.main.async {
                    feedback = "Unable to evaluate response."
                }
                return
            }

            DispatchQueue.main.async {
                feedback = content

                // Extract score from GPT response
                if let match = content.range(of: #"([0-9]{1,2})\/10"#, options: .regularExpression) {
                    let scoreStr = content[match].prefix(while: { $0.isNumber })
                    if let s = Int(scoreStr) {
                        score = s
                    }
                }
            }
        }.resume()
    }

    func loadOpenAIKeyFromInfoPlist() -> String? {
        Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String
    }
}





struct WordPanel: View {
    let title: String
    let words: [String]
    @Binding var sentence: [String]
    var showImages: Bool = true

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
                                    Image(word)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                }
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
