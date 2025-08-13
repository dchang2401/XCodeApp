import SwiftUI
import AVFoundation

// MARK: - Data Models
struct TherapyProgress: Codable {
    var totalCoins: Int = 0
    var sessionsCompleted: Int = 0
    var totalScore: Int = 0
    var bestStreak: Int = 0
    var currentStreak: Int = 0
}

struct PetCustomization: Codable {
    var petName: String = ""
    var petType: String = "" // dog, cat, turtle, mouse, etc.
    var hatItem: String? = nil
    var accessoryItem: String? = nil
    var backgroundItem: String = "grass"
    var happiness: Int = 100 // 0-100 happiness level
    var lastPlayDate: Date = Date()
    var isSetup: Bool = false // Track if pet is initially set up
}

struct ShopItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let price: Int
    let category: ItemCategory
    let description: String
}

enum ItemCategory: String, CaseIterable {
    case hats = "Hats"
    case accessories = "Accessories"
    case backgrounds = "Backgrounds"
    case treats = "Treats"
}

// MARK: - Tutorial Components
struct TherapyTutorialStep {
    let title: String
    let description: String
    let highlightArea: TherapyTutorialArea
}

enum TherapyTutorialArea {
    case none, practiceTab, petTab, recordingArea, feedbackArea, petShop
}

// MARK: - Tutorial Overlay
struct TherapyTutorialOverlay: View {
    @Binding var currentStep: Int
    @Binding var showTutorial: Bool
    @Binding var selectedTab: Int
    let steps: [TherapyTutorialStep]
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Tutorial Card
                VStack(spacing: 15) {
                    // Icon based on step
                    Group {
                        switch steps[currentStep].highlightArea {
                        case .practiceTab:
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        case .petTab:
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.pink)
                        case .recordingArea:
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        case .feedbackArea:
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.yellow)
                        case .petShop:
                            Image(systemName: "cart.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.purple)
                        default:
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.bottom, 5)
                    
                    Text(steps[currentStep].title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text(steps[currentStep].description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Progress indicator
                    HStack {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentStep ? Color.green : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    // Navigation buttons
                    HStack(spacing: 15) {
                        if currentStep > 0 {
                            Button("Previous") {
                                withAnimation {
                                    currentStep -= 1
                                    updateTabForStep()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Spacer()
                        
                        if currentStep < steps.count - 1 {
                            Button("Next") {
                                withAnimation {
                                    currentStep += 1
                                    updateTabForStep()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Start Practicing!") {
                                finishTutorial()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    // Don't show again option
                    if currentStep == steps.count - 1 {
                        Button("Don't show again") {
                            markTutorialAsSeen()
                            showTutorial = false
                        }
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding(.top, 5)
                    }
                }
                .padding(20)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
    
    private func updateTabForStep() {
        // Switch to appropriate tab for certain steps
        switch steps[currentStep].highlightArea {
        case .practiceTab, .recordingArea, .feedbackArea:
            selectedTab = 0
        case .petTab, .petShop:
            selectedTab = 1
        default:
            break
        }
    }
    
    private func finishTutorial() {
        showTutorial = false
        selectedTab = 0 // Start on practice tab
    }
    
    private func markTutorialAsSeen() {
        UserDefaults.standard.set(true, forKey: "hasSeenTherapyTutorial")
    }
}

// MARK: - Pet Setup View
struct PetSetupView: View {
    @Binding var petCustomization: PetCustomization
    @Binding var showPetSetup: Bool
    @State private var selectedPetType = "dog"
    @State private var petName = ""
    
    let petOptions = [
        ("dog", "🐶 Dog"),
        ("cat", "🐱 Cat"),
        ("turtle", "🐢 Turtle"),
        ("mouse", "🐭 Mouse"),
        ("rabbit", "🐰 Rabbit"),
        ("bird", "🐦 Bird")
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Meet Your New Pet!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Choose a pet to be your practice buddy")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Pet selection
            VStack(spacing: 20) {
                Text("Choose Your Pet:")
                    .font(.title2)
                    .bold()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(petOptions, id: \.0) { petType, displayName in
                        Button(action: {
                            selectedPetType = petType
                        }) {
                            VStack {
                                // Show PNG image if available, fallback to emoji
                                Image(petType)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                
                                Text(displayName.replacingOccurrences(of: "🐶 ", with: "").replacingOccurrences(of: "🐱 ", with: "").replacingOccurrences(of: "🐢 ", with: "").replacingOccurrences(of: "🐭 ", with: "").replacingOccurrences(of: "🐰 ", with: "").replacingOccurrences(of: "🐦 ", with: ""))
                                    .font(.caption)
                                    .bold()
                            }
                            .padding()
                            .background(selectedPetType == petType ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedPetType == petType ? .white : .primary)
                            .cornerRadius(15)
                        }
                    }
                }
            }
            
            // Pet naming
            VStack(spacing: 15) {
                Text("Name Your Pet:")
                    .font(.title2)
                    .bold()
                
                TextField("Enter pet name", text: $petName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .multilineTextAlignment(.center)
            }
            
            // Preview
            VStack {
                Text("Preview:")
                    .font(.headline)
                
                VStack {
                    Image(selectedPetType)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    Text(petName.isEmpty ? "Your Pet" : petName)
                        .font(.title2)
                        .bold()
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
            }
            
            Button("Start Playing!") {
                setupPet()
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
            .disabled(petName.trimmingCharacters(in: .whitespaces).isEmpty)
            
            Spacer()
        }
        .padding()
    }
    
    private func setupPet() {
        petCustomization.petName = petName.trimmingCharacters(in: .whitespaces)
        petCustomization.petType = selectedPetType
        petCustomization.happiness = 100
        petCustomization.lastPlayDate = Date()
        petCustomization.isSetup = true
    }
}

// MARK: - Therapy Practice Tab
struct TherapyPracticeTab: View {
    @Binding var progress: TherapyProgress
    @Binding var petCustomization: PetCustomization
    @ObservedObject var speechManager = SpeechRecognizerManager()
    
    let prompts = ["apple", "basketball", "baseball", "banana", "donut", "car", "house", "tree", "book", "phone"]
    
    @State private var currentIndex = 0
    @State private var userTranscription = ""
    @State private var feedback = ""
    @State private var score: Int? = nil
    @State private var isFinished = false
    @State private var sessionCoins = 0
    @State private var showCoinAnimation = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with coins and progress
            HStack {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(progress.totalCoins)")
                        .font(.headline)
                        .bold()
                }
                
                Spacer()
                
                Text("Session: \(progress.sessionsCompleted)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            if isFinished {
                completionView
            } else {
                practiceView
            }
        }
        .overlay(
            // Coin animation
            coinAnimationOverlay
        )
    }
    
    private var practiceView: some View {
        VStack(spacing: 20) {
            Text("Prompt \(currentIndex + 1) of \(prompts.count)")
                .font(.headline)
            
            VStack {
                Text("Describe this:")
                    .font(.title2)
                Image(prompts[currentIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 3)
            
            Text("Your Transcription:")
                .font(.headline)
            Text(speechManager.isRecording ?
                 (speechManager.transcribedText.isEmpty ? "Listening..." : speechManager.transcribedText) :
                 (userTranscription.isEmpty ? "Tap to start recording..." : userTranscription))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .foregroundColor(speechManager.isRecording ? .blue : (userTranscription.isEmpty ? .gray : .primary))
                .animation(.easeInOut(duration: 0.2), value: speechManager.transcribedText)
            
            if let score = score {
                ScoreView(score: score)
            }
            
            if !feedback.isEmpty {
                Text(feedback)
                    .italic()
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
            }
            
            HStack(spacing: 20) {
                Button(speechManager.isRecording ? "Stop Recording" : "Start Recording") {
                    handleRecording()
                }
                .padding()
                .background(speechManager.isRecording ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                .scaleEffect(speechManager.isRecording ? 1.05 : 1.0)
                .animation(speechManager.isRecording ?
                          .easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                          .easeInOut(duration: 0.2),
                          value: speechManager.isRecording)
                
                if !speechManager.isRecording && score != nil {
                    Button("Next") {
                        advanceToNextPrompt()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            Spacer()
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Text("🎉 Great Job!")
                .font(.largeTitle)
                .bold()
            
            Text("You earned \(sessionCoins) coins!")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text("Go check on your pet!")
                .font(.headline)
                .foregroundColor(.blue)
            
            Button("Start New Session") {
                startNewSession()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            
            Spacer()
        }
    }
    
    private var coinAnimationOverlay: some View {
        Group {
            if showCoinAnimation {
                VStack {
                    HStack {
                        Spacer()
                        Text("+\(sessionCoins) coins!")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.orange)
                            .padding()
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(10)
                            .transition(.scale.combined(with: .opacity))
                        Spacer()
                    }
                    Spacer()
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCoinAnimation)
            }
        }
    }
    
    private func handleRecording() {
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
    
    private func advanceToNextPrompt() {
        userTranscription = ""
        feedback = ""
        score = nil
        
        if currentIndex + 1 < prompts.count {
            currentIndex += 1
        } else {
            finishSession()
        }
    }
    
    private func finishSession() {
        progress.sessionsCompleted += 1
        progress.totalCoins += sessionCoins
        
        // Increase happiness when practicing (max 100)
        petCustomization.happiness = min(100, petCustomization.happiness + 15)
        petCustomization.lastPlayDate = Date()
        
        isFinished = true
        
        showCoinAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCoinAnimation = false
        }
    }
    
    private func startNewSession() {
        currentIndex = 0
        sessionCoins = 0
        isFinished = false
        userTranscription = ""
        feedback = ""
        score = nil
    }
    
    private func evaluateResponse(userSpeech: String, expectedImageName: String) {
        guard let apiKey = loadOpenAIKeyFromInfoPlist() else {
            feedback = "Missing API key."
            return
        }

        let prompt = """
        A person with aphasia is doing speech therapy. They need to describe an image of: \(expectedImageName).

        They said: "\(userSpeech)"

        Please evaluate this response:
        1. Score from 0-10 based on how well they described the object
        2. Be very encouraging and positive - if they clearly identified the object, give 8-10 points
        3. Give ONE short positive sentence of feedback (max 15 words)
        4. If they said the exact word or described it well, praise them highly

        Format: Give just one short encouraging sentence, then "Score: X/10"
        """

        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are an encouraging speech therapist for aphasia patients. Give very short, positive feedback (max 15 words). Be generous with scores for good attempts."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3
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

            DispatchQueue.main.async {
                feedback = trimmedFeedback

                // Extract score with better regex
                if let scoreRange = trimmedFeedback.range(of: #"Score:\s*(\d+)"#, options: .regularExpression) {
                    let scoreText = String(trimmedFeedback[scoreRange])
                    let scoreNumber = scoreText.replacingOccurrences(of: "Score:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if let s = Int(scoreNumber) {
                        score = min(10, max(0, s)) // Ensure score is between 0-10
                        
                        // Award coins based on actual performance (more reasonable amounts)
                        let earnedCoins = max(1, s / 2) // 1-5 coins based on score (score/2)
                        sessionCoins += earnedCoins

                        // Auto-advance after good scores
                        if s >= 7 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
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

// MARK: - Score View Component
struct ScoreView: View {
    let score: Int
    
    var body: some View {
        HStack {
            ForEach(1...10, id: \.self) { index in
                Image(systemName: index <= score ? "star.fill" : "star")
                    .foregroundColor(index <= score ? .yellow : .gray)
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Pet Care Tab
struct PetCareTab: View {
    @Binding var progress: TherapyProgress
    @Binding var petCustomization: PetCustomization
    @State private var selectedCategory: ItemCategory = .hats
    @State private var showShop = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Coin display
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(progress.totalCoins)")
                        .font(.headline)
                        .bold()
                }
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Pet display
            VStack {
                Text(petCustomization.petName)
                    .font(.title)
                    .bold()
                
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(backgroundGradient)
                        .frame(height: 250)
                    
                    // Pet
                    VStack {
                        if let hat = petCustomization.hatItem {
                            Image(hat) // Now uses PNG image names
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .offset(y: -10)
                        }
                        
                        Image(petCustomization.petType) // Now uses PNG image instead of emoji
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        
                        if let accessory = petCustomization.accessoryItem {
                            Image(accessory) // Now uses PNG image names
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .padding()
            }
            
            // Pet status
            HStack(spacing: 20) {
                VStack {
                    Text("Happiness")
                    HStack {
                        Text(happinessEmoji)
                            .font(.title2)
                        Text("\(petCustomization.happiness)%")
                            .font(.caption)
                            .bold()
                            .foregroundColor(happinessColor)
                    }
                }
                
                VStack {
                    Text("Level")
                    Text("\(progress.sessionsCompleted / 5 + 1)")
                        .font(.title2)
                        .bold()
                }
                
                VStack {
                    Text("Sessions")
                    Text("\(progress.sessionsCompleted)")
                        .font(.title2)
                        .bold()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            // Action buttons
            HStack(spacing: 20) {
                Button("🛍️ Shop") {
                    showShop = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("🎮 Feed Pet") {
                    feedPet()
                }
                .buttonStyle(.bordered)
                .disabled(progress.totalCoins < 10)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showShop) {
            PetShopView(progress: $progress, petCustomization: $petCustomization)
        }
    }
    
    private var backgroundGradient: LinearGradient {
        switch petCustomization.backgroundItem {
        case "ocean":
            return LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
        case "forest":
            return LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.1)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    private var happinessEmoji: String {
        switch petCustomization.happiness {
        case 80...100: return "😊"
        case 60...79: return "🙂"
        case 40...59: return "😐"
        case 20...39: return "😟"
        default: return "😢"
        }
    }
    
    private var happinessColor: Color {
        switch petCustomization.happiness {
        case 80...100: return .green
        case 60...79: return .yellow
        case 40...59: return .orange
        default: return .red
        }
    }
    
    private func feedPet() {
        if progress.totalCoins >= 10 {
            progress.totalCoins -= 10
            petCustomization.happiness = min(100, petCustomization.happiness + 20)
            petCustomization.lastPlayDate = Date()
        }
    }
}

// MARK: - Pet Shop View
struct PetShopView: View {
    @Binding var progress: TherapyProgress
    @Binding var petCustomization: PetCustomization
    @Environment(\.dismiss) private var dismiss
    
    let shopItems = [
        ShopItem(name: "Royal Crown", imageName: "crown", price: 50, category: .hats, description: "Fit for a king!"),
        ShopItem(name: "Cool Hat", imageName: "hat", price: 30, category: .hats, description: "Stay stylish!"),
        ShopItem(name: "Magic Bow", imageName: "bow", price: 25, category: .accessories, description: "Magical effects!"),
        ShopItem(name: "Bow Tie", imageName: "bowtie", price: 20, category: .accessories, description: "Formal wear!"),
        ShopItem(name: "Ocean View", imageName: "water.waves", price: 40, category: .backgrounds, description: "Peaceful waters"),
        ShopItem(name: "Forest Scene", imageName: "tree.fill", price: 35, category: .backgrounds, description: "Nature vibes"),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Pet Shop")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(progress.totalCoins)")
                            .font(.headline)
                            .bold()
                    }
                }
                .padding()
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        ForEach(shopItems) { item in
                            ShopItemCard(item: item, progress: $progress, petCustomization: $petCustomization)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Shop Item Card
struct ShopItemCard: View {
    let item: ShopItem
    @Binding var progress: TherapyProgress
    @Binding var petCustomization: PetCustomization
    
    var body: some View {
        VStack {
            Image(systemName: item.imageName)
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .frame(height: 60)
            
            Text(item.name)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(item.description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                Text("\(item.price)")
                    .bold()
            }
            
            Button(canAfford ? "Buy" : "Need More Coins") {
                buyItem()
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
            .disabled(!canAfford)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    private var canAfford: Bool {
        progress.totalCoins >= item.price
    }
    
    private func buyItem() {
        guard canAfford else { return }
        
        progress.totalCoins -= item.price
        
        switch item.category {
        case .hats:
            petCustomization.hatItem = item.imageName
        case .accessories:
            petCustomization.accessoryItem = item.imageName
        case .backgrounds:
            petCustomization.backgroundItem = item.name.lowercased()
        case .treats:
            // Handle treats (temporary effects)
            break
        }
    }
}

// MARK: - Main Therapy View with Tabs
struct GameifiedTherapyView: View {
    @State private var selectedTab = 0
    @State private var progress = TherapyProgress()
    @State private var petCustomization = PetCustomization()
    @State private var showPetSetup = false
    @State private var showTutorial = false
    @State private var currentTutorialStep = 0
    
    let tutorialSteps = [
        TherapyTutorialStep(
            title: "Welcome to Speech Therapy Games!",
            description: "Let's learn how to practice your speech and take care of your virtual pet!",
            highlightArea: .none
        ),
        TherapyTutorialStep(
            title: "Practice Tab",
            description: "Here you'll see pictures to describe. Tap 'Start Recording' to begin speaking about what you see!",
            highlightArea: .practiceTab
        ),
        TherapyTutorialStep(
            title: "Recording Your Voice",
            description: "• Tap 'Start Recording' to begin\n• Describe the picture you see\n• Tap 'Stop Recording' when done\n• Watch your words appear as you speak!",
            highlightArea: .recordingArea
        ),
        TherapyTutorialStep(
            title: "Getting Feedback",
            description: "After recording, you'll get encouraging feedback and earn coins based on how well you described the picture!",
            highlightArea: .feedbackArea
        ),
        TherapyTutorialStep(
            title: "Your Virtual Pet",
            description: "Switch to 'My Pet' tab to see your companion! The more you practice, the happier your pet becomes!",
            highlightArea: .petTab
        ),
        TherapyTutorialStep(
            title: "Pet Care & Shop",
            description: "Use coins you earn to buy hats, accessories, and backgrounds for your pet. You can also feed your pet to keep it happy!",
            highlightArea: .petShop
        ),
        TherapyTutorialStep(
            title: "Ready to Start!",
            description: "Practice regularly to improve your speech, earn coins, and keep your pet happy. Have fun!",
            highlightArea: .none
        )
    ]
    
    var body: some View {
        ZStack {
            Group {
                if !petCustomization.isSetup {
                    PetSetupView(petCustomization: $petCustomization, showPetSetup: $showPetSetup)
                } else {
                    TabView(selection: $selectedTab) {
                        TherapyPracticeTab(progress: $progress, petCustomization: $petCustomization)
                            .tabItem {
                                Image(systemName: "mic.fill")
                                Text("Practice")
                            }
                            .tag(0)
                            .overlay(
                                therapyTutorialHighlight(for: .practiceTab)
                            )
                        
                        PetCareTab(progress: $progress, petCustomization: $petCustomization)
                            .tabItem {
                                Image(systemName: "heart.fill")
                                Text("My Pet")
                            }
                            .tag(1)
                            .overlay(
                                therapyTutorialHighlight(for: .petTab)
                            )
                    }
                    .navigationTitle("Therapy Games")
                }
            }
            .onAppear {
                loadProgress()
                updateHappiness()
                checkShowTherapyTutorial()
            }
            .onDisappear {
                saveProgress()
            }
            
            // Tutorial Overlay
            if showTutorial && petCustomization.isSetup {
                TherapyTutorialOverlay(
                    currentStep: $currentTutorialStep,
                    showTutorial: $showTutorial,
                    selectedTab: $selectedTab,
                    steps: tutorialSteps
                )
            }
        }
    }
    
    @ViewBuilder
    private func therapyTutorialHighlight(for area: TherapyTutorialArea) -> some View {
        if showTutorial && tutorialSteps[currentTutorialStep].highlightArea == area {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green, lineWidth: 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(15)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: showTutorial)
        }
    }
    
    // Check if tutorial should be shown
    func checkShowTherapyTutorial() {
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenTherapyTutorial")
        if !hasSeenTutorial && petCustomization.isSetup {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showTutorial = true
            }
        }
    }
    
    // MARK: - Data persistence methods
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: "therapyProgress"),
           let decoded = try? JSONDecoder().decode(TherapyProgress.self, from: data) {
            progress = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: "petCustomization"),
           let decoded = try? JSONDecoder().decode(PetCustomization.self, from: data) {
            petCustomization = decoded
        }
    }
    
    private func updateHappiness() {
        let daysSinceLastPlay = Calendar.current.dateComponents([.day], from: petCustomization.lastPlayDate, to: Date()).day ?? 0
        
        if daysSinceLastPlay > 0 {
            // Decrease happiness by 10 per day of not playing, minimum 0
            petCustomization.happiness = max(0, petCustomization.happiness - (daysSinceLastPlay * 10))
            petCustomization.lastPlayDate = Date()
        }
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: "therapyProgress")
        }
        
        if let encoded = try? JSONEncoder().encode(petCustomization) {
            UserDefaults.standard.set(encoded, forKey: "petCustomization")
        }
    }
}
