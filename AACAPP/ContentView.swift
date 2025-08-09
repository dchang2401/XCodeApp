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
        NavigationStack {
            VStack(spacing: 40) {
                Text("AAC App")
                    .font(.largeTitle)
                    .bold()

                NavigationLink("Patient Mode") {
                    PatientMenuView()
                }
                .font(.title2)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)

                NavigationLink("Caregiver Mode") {
                    CaregiverMenuView()
                }
                .font(.title2)
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)

                Spacer()
            }
            .padding()
        }
    }
}

struct PatientMenuView: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("Patient Tools")
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

            NavigationLink("Make Your Own") {
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
        .navigationTitle("Patient Mode")
    }
}

struct CaregiverMenuView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Caregiver Mode")
                .font(.largeTitle)
                .bold()

            NavigationLink("Communication Mode Survey") {
                SurveyView()
            }
            .font(.title2)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)

            NavigationLink("Caregiver Journal") {
                JournalListView()
            }
            .font(.title2)
            .padding()
            .background(Color.blue)   // you can pick any color you want here
            .foregroundColor(.white)
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .navigationTitle("Caregiver Mode")
    }
}

/*
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
*/




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
        
        // Try to find your installed Siri Voice 4 or fallback to default
        if let siriVoice4 = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name.contains("Siri") && $0.language == "en-US" }) {
            utterance.voice = siriVoice4
            print("Using Siri Voice 4: \(siriVoice4.name)")
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            print("Using default en-US voice")
        }
        
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
        
        // Try to find your installed Siri Voice 4 or fallback to default
        if let siriVoice4 = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name.contains("Siri") && $0.language == "en-US" }) {
            utterance.voice = siriVoice4
            print("Using Siri Voice 4: \(siriVoice4.name)")
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            print("Using default en-US voice")
        }
        
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
        // Reset previous task if any
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Change category from `.record` to `.playAndRecord`
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            isRecording = false
            return
        }


        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
    
            return
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false  // you can try 'true' here as fallback

        let inputNode = audioEngine.inputNode

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }

            if let error = error {
                print("Recognition Error: \(error.localizedDescription)")
                self.stopRecording()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)  // <-- IMPORTANT: Remove old taps first
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            print("Recording started successfully")
        } catch {
            print("Audio Engine couldn't start: \(error.localizedDescription)")
            isRecording = false
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }

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
        
        // Try to find your installed Siri Voice 4 or fallback to default
        if let siriVoice4 = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name.contains("Siri") && $0.language == "en-US" }) {
            utterance.voice = siriVoice4
            print("Using Siri Voice 4: \(siriVoice4.name)")
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            print("Using default en-US voice")
        }
        
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

    // List of image prompts (use asset names)
    let prompts = ["apple", "basketball", "baseball", "banana", "donut"]

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

                Text("Describe this:")
                Image(prompts[currentIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
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
                            evaluateResponse(userSpeech: transcription, expectedImageName: prompts[currentIndex])
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

    func evaluateResponse(userSpeech: String, expectedImageName: String) {
        guard let apiKey = loadOpenAIKeyFromInfoPlist() else {
            feedback = "Missing API key."
            return
        }

        let prompt = """
        A person with aphasia is describing an object in an image. The image shows: \(expectedImageName).

        They said:
        "\(userSpeech)"

        Please give short and kind feedback (1-2 sentences max), and include a score from 0 to 10 written like 'Score: X/10' at the end.
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

            let trimmedFeedback = content.trimmingCharacters(in: .whitespacesAndNewlines)
            print("GPT returned: \(trimmedFeedback)")

            DispatchQueue.main.async {
                feedback = trimmedFeedback

                // Extract score (any number 0–10 with or without 'Score: ')
                if let match = trimmedFeedback.range(of: #"(?i)score[:\s]*([0-9]{1,2})\s*/\s*10"#, options: .regularExpression) {
                    let scoreStr = String(trimmedFeedback[match]).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    if let s = Int(scoreStr) {
                        score = s

                        // Auto-advance after 1.5s if score is 7+
                        if s >= 7 {
                            // Delay auto-advance to allow time for reading feedback
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                // Only auto-advance if user hasn’t manually tapped “Next”
                                if score == s && feedback == trimmedFeedback {
                                    advanceToNextPrompt()
                                }
                            }
                        }
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
import SwiftUI

import SwiftUI

struct SurveyView: View {
    @State private var q1Selection = ""
    @State private var q2Selection = ""
    @State private var q3Selection = ""
    @State private var q4Selection = ""
    @State private var q5Selection = ""
    @State private var showRecommendation = false
    @State private var recommendation = ""

    let q1Options = ["Fewer than 10", "10 to 50", "More than 50"]
    let q2Options = ["No – mostly single words or short phrases", "Yes – attempts full sentences, though they may be ungrammatical", "Yes – mostly fluent and complete sentences"]
    let q3Options = ["Rarely – often off-topic", "Sometimes – on-topic, but hard to follow", "Usually – stays on topic"]
    let q4Options = ["No – unaware of mistakes", "Sometimes – some awareness", "Yes – often tries to fix errors"]
    let q5Options = ["Most sentences are broken or telegraphic", "Somewhat ungrammatical but understandable", "Mostly complete and grammatically correct"]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Aphasia Communication Mode Survey")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)

                    QuestionCard(title: "1. How many different words does the person regularly use when speaking?", options: q1Options, selection: $q1Selection)
                    QuestionCard(title: "2. Does the person usually form sentences or combine words into longer utterances?", options: q2Options, selection: $q2Selection)
                    QuestionCard(title: "3. How often is what they say relevant and accurate to the conversation?", options: q3Options, selection: $q3Selection)
                    QuestionCard(title: "4. Does the person seem aware when their words don't make sense or aren't understood?", options: q4Options, selection: $q4Selection)
                    QuestionCard(title: "5. When the person speaks, how grammatically correct are their sentences?", options: q5Options, selection: $q5Selection)

                    Button("Get Recommendation") {
                        determineRecommendation()
                        withAnimation {
                            showRecommendation = true
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.top)

                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
            }

            // Full-Screen Modal for Recommendation
            if showRecommendation {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("Recommended Mode")
                        .font(.largeTitle)
                        .bold()

                    Text(recommendation)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(15)

                    Button("Close") {
                        withAnimation {
                            showRecommendation = false
                        }
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(25)
                .shadow(radius: 20)
                .padding(40)
            }
        }
        .navigationTitle("Survey")
    }

    func determineRecommendation() {
        if q1Selection == "Fewer than 10" || q2Selection.contains("single words") {
            recommendation = "Mode 1 (Symbol-Based Interface)"
            return
        }
        if q3Selection.contains("Rarely") || q4Selection.contains("No – unaware") {
            recommendation = "Mode 1 (Symbol-Based Interface)"
            return
        }
        if q5Selection.contains("telegraphic") {
            recommendation = "Mode 1 + Mode 2"
            return
        }
        if q2Selection.contains("full sentences") && q3Selection.contains("Usually") && q4Selection.contains("Yes – often tries to fix errors") {
            recommendation = "Mode 2 (Sentence Refining Tool)"
            return
        }
        recommendation = "Mode 1 + Mode 2"
    }
}

struct QuestionCard: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                    }) {
                        Text(option)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selection == option ? Color.blue : Color.gray.opacity(0.1))
                            .foregroundColor(selection == option ? .white : .primary)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))  // <-- Softer card background
        .cornerRadius(15)
        .shadow(radius: 3)
        .padding(.vertical, 4)
    }
}
import SwiftUI
import Foundation

// -----------------------------
// MARK: - Model
// -----------------------------
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var text: String
    var transcribedAudio: String?      // if entry created from voice and transcribed
    var includeInPatientLog: Bool      // caregiver can mark to include in patient quizzes/logs
    var sentimentScore: Double         // -1.0 (very negative) ... +1.0 (very positive)
    
    init(text: String,
         transcribedAudio: String? = nil,
         includeInPatientLog: Bool = false,
         date: Date = Date(),
         sentimentScore: Double = 0.0) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.transcribedAudio = transcribedAudio
        self.includeInPatientLog = includeInPatientLog
        self.sentimentScore = sentimentScore
    }
}

// -----------------------------
// MARK: - Journal Manager (Persistence + Analytics)
// -----------------------------
final class JournalManager: ObservableObject {
    @Published private(set) var entries: [JournalEntry] = []
    @Published var burnoutRisk: Bool = false
    @Published var averageSentimentLast30Days: Double = 0.0
    
    private let storeURL: URL
    private let fileName = "caregiver_journal.json"
    private let sentimentAnalyzer = SentimentAnalyzer()
    
    init() {
        // Documents directory
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        storeURL = docs.appendingPathComponent(fileName)
        load()
        computeAnalytics()
    }
    
    // CRUD
    func addEntry(text: String, transcribedAudio: String? = nil, includeInPatientLog: Bool = false) {
        let joinedText = [text, transcribedAudio ?? ""].joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        let score = sentimentAnalyzer.score(text: joinedText)
        var entry = JournalEntry(text: text, transcribedAudio: transcribedAudio, includeInPatientLog: includeInPatientLog, sentimentScore: score)
        entries.insert(entry, at: 0) // newest first
        save()
        computeAnalytics()
    }
    
    func updateEntry(_ entry: JournalEntry) {
        if let i = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[i] = entry
            save()
            computeAnalytics()
        }
    }
    
    func removeEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
        computeAnalytics()
    }
    
    // Persistence
    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: storeURL, options: [.atomicWrite])
        } catch {
            print("Failed to save journal: \(error)")
        }
    }
    
    private func load() {
        do {
            let data = try Data(contentsOf: storeURL)
            let loaded = try JSONDecoder().decode([JournalEntry].self, from: data)
            self.entries = loaded
        } catch {
            // no file yet is fine
            self.entries = []
        }
    }
    
    // Analytics: sentiment average and simple burnout risk detection
    private func computeAnalytics() {
        // compute average sentiment in last 30 days
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let recent = entries.filter { $0.date >= thirtyDaysAgo }
        if recent.isEmpty {
            averageSentimentLast30Days = 0.0
        } else {
            averageSentimentLast30Days = recent.map { $0.sentimentScore }.reduce(0.0, +) / Double(recent.count)
        }
        // Burnout rule: if average sentiment < -0.25 OR more than 3 strongly negative entries in last 30 days
        let veryNegativeCount = recent.filter { $0.sentimentScore <= -0.5 }.count
        burnoutRisk = averageSentimentLast30Days < -0.25 || veryNegativeCount >= 3
    }
    
    // Expose entries for patient logs
    func patientIncludedEntries() -> [JournalEntry] {
        entries.filter { $0.includeInPatientLog }
    }
}

// -----------------------------
// MARK: - Simple Sentiment Analyzer (On-device, rule-based)
// -----------------------------
// Lightweight, no external dependencies. Good for initial prototyping.
// It uses small positive/negative word lists to produce -1..+1 score.
struct SentimentAnalyzer {
    // Minimal seed lists — expand as needed
    private let positive: Set<String> = [
        "good","great","happy","well","better","improved","positive","ok","okay","fine","relieved","grateful","hopeful","satisfied","calm","content"
    ]
    private let negative: Set<String> = [
        "bad","sad","angry","upset","unhappy","frustrated","tired","exhausted","terrible","worse","pain","anxious","lonely","overwhelmed","stressed","burnout","scared","depressed"
    ]
    
    func score(text: String) -> Double {
        // Normalize and tokenize
        let tokens = text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        
        guard !tokens.isEmpty else { return 0.0 }
        
        var pos = 0
        var neg = 0
        for t in tokens {
            if positive.contains(t) { pos += 1 }
            if negative.contains(t) { neg += 1 }
        }
        // Score range -1..1
        let raw = Double(pos - neg) / Double(max(1, pos + neg))
        return max(-1.0, min(1.0, raw))
    }
}

// -----------------------------
// MARK: - Views
// -----------------------------

// Journal list + analytics
struct JournalListView: View {
    @StateObject var manager = JournalManager()
    @State private var showingAdd = false
    @State private var showingDetailsFor: JournalEntry? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                // Analytics header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Caregiver Journal")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Button(action: { showingAdd = true }) {
                            Label("New", systemImage: "plus")
                        }
                    }
                    
                    HStack {
                        Text("Avg Sentiment (30d):")
                        Text(String(format: "%.2f", manager.averageSentimentLast30Days))
                            .bold()
                            .foregroundColor(manager.averageSentimentLast30Days >= 0 ? .green : .red)
                        Spacer()
                        if manager.burnoutRisk {
                            Label("Burnout Risk", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .background(Color.red.opacity(0.12))
                                .cornerRadius(8)
                        }
                    }
                    .font(.subheadline)
                }
                .padding()
                
                List {
                    ForEach(manager.entries) { entry in
                        Button(action: { showingDetailsFor = entry }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.text)
                                        .lineLimit(2)
                                        .font(.body)
                                    Text(entry.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                // sentiment pill
                                Text(String(format: "%.2f", entry.sentimentScore))
                                    .font(.caption)
                                    .padding(8)
                                    .background(colorForScore(entry.sentimentScore))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .onDelete(perform: manager.removeEntry)
                }
            }
            .navigationTitle("Journal")
            .sheet(item: $showingDetailsFor, onDismiss: { showingDetailsFor = nil }) { entry in
                JournalDetailView(entry: entry, manager: manager)
            }
            .sheet(isPresented: $showingAdd) {
                AddJournalView(manager: manager)
            }
        }
    }
    
    func colorForScore(_ score: Double) -> Color {
        // red for negative, green for positive, gray near zero
        if score <= -0.5 { return .red }
        if score < 0 { return .orange }
        if score == 0 { return .gray }
        if score < 0.5 { return .green.opacity(0.7) }
        return .green
    }
}

// Add journal view with voice-record capability using SpeechRecognizerManager
struct AddJournalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: JournalManager
    @StateObject private var speechManager = SpeechRecognizerManager()
    
    @State private var text: String = ""
    @State private var includeInPatientLog: Bool = false
    @State private var transcribedAudio: String? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("New Journal Entry")
                    .font(.title2)
                    .bold()
                
                TextEditor(text: $text)
                    .frame(minHeight: 180)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2))
                    )
                
                HStack {
                    Button(action: {
                        if speechManager.isRecording {
                            // stop and capture transcription
                            speechManager.stopRecording()
                            transcribedAudio = speechManager.transcribedText
                            text += (text.isEmpty ? "" : "\n") + (transcribedAudio ?? "")
                        } else {
                            speechManager.transcribedText = ""
                            speechManager.startRecording()
                        }
                    }) {
                        HStack {
                            Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.title)
                            Text(speechManager.isRecording ? "Stop Recording" : "Record")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(speechManager.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                Toggle("Include in patient logs/quizzes", isOn: $includeInPatientLog)
                    .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Save Entry") {
                        manager.addEntry(text: text, transcribedAudio: transcribedAudio, includeInPatientLog: includeInPatientLog)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("New Entry")
        }
    }
}

// Detail view for editing and including in patient logs
struct JournalDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var entry: JournalEntry
    @ObservedObject var manager: JournalManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                TextEditor(text: $entry.text)
                    .frame(minHeight: 180)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                
                if let t = entry.transcribedAudio, !t.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Transcribed Audio:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(t)
                            .font(.body)
                    }
                    .padding(.vertical, 8)
                }
                
                Toggle("Include in patient logs/quizzes", isOn: $entry.includeInPatientLog)
                    .padding(.horizontal)
                
                HStack {
                    Button("Cancel") { dismiss() }
                    Spacer()
                    Button("Save") {
                        // re-run sentiment scoring on text change
                        var updated = entry
                        let analyzer = SentimentAnalyzer()
                        updated.sentimentScore = analyzer.score(text: updated.text + " " + (updated.transcribedAudio ?? ""))
                        manager.updateEntry(updated)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Entry")
        }
    }
}


