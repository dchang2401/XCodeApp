    //
    //  CombinedVocabView.swift
    //  AACAPP
    //
    //  Created by Daniel Chang on 8/3/25.
    //

    import SwiftUI
    import AVFoundation

    struct CombinedVocabView: View {
        @State private var sentence: [String] = []
        @State private var selectedTab = 0
        @State private var customWords: [String] = []
        @State private var showTutorial = false
        @State private var currentTutorialStep = 0
        @State private var animateElements = false
        
        let tutorialSteps = [
            TutorialStep(
                title: "Welcome to Vocabulary!",
                description: "Let's learn how to build sentences with words and pictures.",
                highlightArea: .none
            ),
            TutorialStep(
                title: "Building Sentences",
                description: "Tap any word button to add it to your sentence. Watch it appear in the sentence bar above!",
                highlightArea: .sentenceBar
            ),
            TutorialStep(
                title: "Sentence Controls",
                description: "• CLEAR: Remove all words\n• UNDO: Remove last word\n• SPEAK: Hear your sentence out loud",
                highlightArea: .controls
            ),
            TutorialStep(
                title: "Core Words Tab",
                description: "This tab has common words organized by category. Tap any word to add it to your sentence!",
                highlightArea: .coreTab
            ),
            TutorialStep(
                title: "My Words Tab",
                description: "Add your own personal words here. Type a new word and tap 'Add' to create it.",
                highlightArea: .customTab
            ),
            TutorialStep(
                title: "Editing Your Words",
                description: "In 'My Words': Press and hold any word to Edit or Delete it. You can customize your vocabulary!",
                highlightArea: .customTab
            )
        ]
        
        var body: some View {
            ZStack {
                // Modern gradient background matching MainMenuView
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6), Color.pink.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating circles for visual interest
                GeometryReader { geometry in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 150, height: 150)
                        .offset(x: -30, y: -50)
                        .scaleEffect(animateElements ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: animateElements)
                    
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 200, height: 200)
                        .offset(x: geometry.size.width - 100, y: geometry.size.height - 150)
                        .scaleEffect(animateElements ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5), value: animateElements)
                }
                
                VStack(spacing: 0) {
                    // Modern Sentence Bar
                    VStack(spacing: 16) {
                        // Sentence Display
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Your Sentence")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    if sentence.isEmpty {
                                        Text("Tap words below to build your sentence...")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                            .italic()
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                    } else {
                                        ForEach(Array(sentence.enumerated()), id: \.offset) { index, word in
                                            HStack(spacing: 4) {
                                                Text(word)
                                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.black)
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 12)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color.white)
                                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                                    )
                                                
                                                if index < sentence.count - 1 {
                                                    Image(systemName: "arrow.right")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                            }
                                            .scaleEffect(animateElements ? 1.02 : 1.0)
                                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(Double(index) * 0.1), value: animateElements)
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .overlay(
                            tutorialHighlight(for: .sentenceBar)
                        )
                        
                        // Modern Control Buttons
                        HStack(spacing: 12) {
                            ControlButton(
                                icon: "trash.fill",
                                title: "Clear",
                                color: .red,
                                action: { sentence.removeAll() }
                            )
                            
                            ControlButton(
                                icon: "arrow.uturn.backward.circle.fill",
                                title: "Undo",
                                color: .orange,
                                action: {
                                    if !sentence.isEmpty {
                                        sentence.removeLast()
                                    }
                                }
                            )
                            
                            ControlButton(
                                icon: "speaker.wave.2.fill",
                                title: "Speak",
                                color: .green,
                                action: {
                                    let fullSentence = sentence.joined(separator: " ")
                                    if !fullSentence.isEmpty {
                                        speak(fullSentence)
                                    }
                                }
                            )
                        }
                        .overlay(
                            tutorialHighlight(for: .controls)
                        )
                    }
                    .padding()
                    
                    // Modern Tab View
                    TabView(selection: $selectedTab) {
                        CoreWordsTab(sentence: $sentence, customWords: $customWords, animateElements: $animateElements)
                            .tabItem {
                                Image(systemName: "book.fill")
                                Text("Core Words")
                            }
                            .tag(0)
                            .overlay(
                                tutorialHighlight(for: .coreTab)
                            )
                        
                        CustomWordsTab(sentence: $sentence, customWords: $customWords)
                            .tabItem {
                                Image(systemName: "plus.circle.fill")
                                Text("My Words")
                            }
                            .tag(1)
                            .overlay(
                                tutorialHighlight(for: .customTab)
                            )
                    }
                    .background(Color.clear)
                }
            }
            .navigationTitle("Vocabulary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .onAppear {
                loadCustomWords()
                checkShowTutorial()
                animateElements = true
            }
            .onDisappear {
                saveCustomWords()
            }
            .overlay(
                // Tutorial Overlay
                showTutorial ? TutorialOverlay(
                    currentStep: $currentTutorialStep,
                    showTutorial: $showTutorial,
                    selectedTab: $selectedTab,
                    steps: tutorialSteps
                ) : nil
            )
        }
        
        @ViewBuilder
        private func tutorialHighlight(for area: TutorialArea) -> some View {
            if showTutorial && tutorialSteps[currentTutorialStep].highlightArea == area {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.8), lineWidth: 3)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(16)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: showTutorial)
            }
        }
        
        func speak(_ text: String) {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            AVSpeechSynthesizer().speak(utterance)
        }
        
        func saveCustomWords() {
            UserDefaults.standard.set(customWords, forKey: "customWords")
        }
        
        func loadCustomWords() {
            customWords = UserDefaults.standard.stringArray(forKey: "customWords") ?? []
        }
        
        func checkShowTutorial() {
            let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenVocabTutorial")
            if !hasSeenTutorial {
                showTutorial = true
            }
        }
    }

    // MARK: - Modern Control Button Component
    struct ControlButton: View {
        let icon: String
        let title: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(title)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.8), color.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Tutorial Components
    struct TutorialStep {
        let title: String
        let description: String
        let highlightArea: TutorialArea
    }

    enum TutorialArea {
        case none, sentenceBar, controls, coreTab, customTab
    }

    struct TutorialOverlay: View {
        @Binding var currentStep: Int
        @Binding var showTutorial: Bool
        @Binding var selectedTab: Int
        let steps: [TutorialStep]
        
        var body: some View {
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text(steps[currentStep].title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(steps[currentStep].description)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack {
                            ForEach(0..<steps.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentStep ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.vertical, 10)
                        
                        HStack(spacing: 15) {
                            if currentStep > 0 {
                                Button("Previous") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentStep -= 1
                                        updateTabForStep()
                                    }
                                }
                                .buttonStyle(TutorialButtonStyle(isPrimary: false))
                            }
                            
                            Spacer()
                            
                            if currentStep < steps.count - 1 {
                                Button("Next") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentStep += 1
                                        updateTabForStep()
                                    }
                                }
                                .buttonStyle(TutorialButtonStyle(isPrimary: true))
                            } else {
                                Button("Get Started!") {
                                    finishTutorial()
                                }
                                .buttonStyle(TutorialButtonStyle(isPrimary: true))
                            }
                        }
                        
                        if currentStep == steps.count - 1 {
                            Button("Don't show again") {
                                markTutorialAsSeen()
                                showTutorial = false
                            }
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 5)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
        
        private func updateTabForStep() {
            switch steps[currentStep].highlightArea {
            case .coreTab:
                selectedTab = 0
            case .customTab:
                selectedTab = 1
            default:
                break
            }
        }
        
        private func finishTutorial() {
            showTutorial = false
        }
        
        private func markTutorialAsSeen() {
            UserDefaults.standard.set(true, forKey: "hasSeenVocabTutorial")
        }
    }

    struct TutorialButtonStyle: ButtonStyle {
        let isPrimary: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isPrimary ?
                            LinearGradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }

    // MARK: - Updated Tab Views
    struct CoreWordsTab: View {
        @Binding var sentence: [String]
        @Binding var customWords: [String]
        @Binding var animateElements: Bool
        
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
                    ModernWordPanel(title: "Basic", words: basicNeeds, sentence: $sentence, color: .blue, animateElements: $animateElements)
                    ModernWordPanel(title: "Pronouns", words: pronouns, sentence: $sentence, color: .cyan, animateElements: $animateElements)
                    ModernWordPanel(title: "People", words: people, sentence: $sentence, color: .purple, animateElements: $animateElements)
                    ModernWordPanel(title: "Actions", words: actions, sentence: $sentence, color: .green, animateElements: $animateElements)
                    ModernWordPanel(title: "Food", words: food, sentence: $sentence, color: .orange, animateElements: $animateElements)
                    ModernWordPanel(title: "Adjectives", words: adjectives, sentence: $sentence, color: .pink, animateElements: $animateElements)
                    ModernWordPanel(title: "Feelings", words: feelings, sentence: $sentence, color: .red, animateElements: $animateElements)
                    
                    if !customWords.isEmpty {
                        ModernEditableWordPanel(title: "My Words", words: $customWords, sentence: $sentence, color: .indigo, animateElements: $animateElements)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color.clear)
        }
    }

    struct CustomWordsTab: View {
        @Binding var sentence: [String]
        @Binding var customWords: [String]
        @State private var newWord: String = ""
        @State private var editingWord: String? = nil
        @State private var editText: String = ""
        @State private var showingDeleteAlert = false
        @State private var wordToDelete: String? = nil
        
        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    addWordSection
                    customWordsDisplay
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color.clear)
            .alert("Delete Word", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let wordToDelete = wordToDelete {
                        deleteWord(wordToDelete)
                    }
                }
            } message: {
                Text("Are you sure you want to delete '\(wordToDelete ?? "")'?")
            }
        }
        
        // Break the add word section into its own computed property
        private var addWordSection: some View {
            VStack(spacing: 16) {
                addWordHeader
                addWordInputRow
            }
            .padding(20)
            .background(addWordBackground)
        }
        
        private var addWordHeader: some View {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                Text("Add New Words")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
        }
        
        private var addWordInputRow: some View {
            HStack(spacing: 12) {
                newWordTextField
                addWordButton
            }
        }
        
        private var newWordTextField: some View {
            TextField("Enter new word", text: $newWord)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.9))
                )
        }
        
        private var addWordButton: some View {
            Button("Add") {
                let trimmed = newWord.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    customWords.append(trimmed)
                    newWord = ""
                }
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(addButtonBackground)
            .overlay(addButtonBorder)
        }
        
        private var addButtonBackground: some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        
        private var addButtonBorder: some View {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
        
        private var addWordBackground: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        
        // Break the custom words display into its own computed property
        @ViewBuilder
        private var customWordsDisplay: some View {
            if customWords.isEmpty {
                emptyWordsView
            } else {
                wordsGridView
            }
        }
        
        private var emptyWordsView: some View {
            VStack(spacing: 16) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Add your own words above!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("💡 Tip: Press and hold any word to edit or delete it")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .background(emptyViewBackground)
        }
        
        private var emptyViewBackground: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        
        private var wordsGridView: some View {
            VStack(spacing: 16) {
                Text("💡 Press and hold any word to edit or delete it")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                wordsGrid
            }
            .padding(20)
            .background(wordsGridBackground)
        }
        
        private var wordsGrid: some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(Array(customWords.enumerated()), id: \.offset) { index, word in
                    CustomWordButton(
                        word: word,
                        isEditing: editingWord == word,
                        editText: $editText,
                        onTap: {
                            if editingWord == word {
                                finishEditing()
                            } else {
                                sentence.append(word)
                            }
                        },
                        onEdit: { startEditing(word: word) },
                        onDelete: {
                            wordToDelete = word
                            showingDeleteAlert = true
                        }
                    )
                }
            }
        }
        
        private var wordsGridBackground: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        
        // Helper methods
        private func startEditing(word: String) {
            editingWord = word
            editText = word
        }
        
        private func finishEditing() {
            guard let editingWord = editingWord else { return }
            
            let trimmedText = editText.trimmingCharacters(in: .whitespaces)
            if !trimmedText.isEmpty && trimmedText != editingWord {
                if let index = customWords.firstIndex(of: editingWord) {
                    customWords[index] = trimmedText
                }
            }
            
            self.editingWord = nil
            editText = ""
        }
        
        private func deleteWord(_ word: String) {
            customWords.removeAll { $0 == word }
            wordToDelete = nil
        }
    }

    struct CustomWordButton: View {
        let word: String
        let isEditing: Bool
        @Binding var editText: String
        let onTap: () -> Void
        let onEdit: () -> Void
        let onDelete: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                if isEditing {
                    TextField("Edit word", text: $editText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .onSubmit { onTap() }
                } else {
                    Text(word)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.indigo.opacity(0.8), Color.indigo.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color.indigo.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .contextMenu {
                Button("Edit") { onEdit() }
                Button("Delete", role: .destructive) { onDelete() }
            }
        }
    }

    struct ModernWordPanel: View {
        let title: String
        let words: [String]
        @Binding var sentence: [String]
        let color: Color
        @Binding var animateElements: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(words.count) words")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                            Button(action: {
                                sentence.append(word)
                            }) {
                                Text(word)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [color.opacity(0.8), color.opacity(0.6)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .scaleEffect(animateElements ? 1.0 : 0.98)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(Double(index) * 0.05), value: animateElements)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }

    struct ModernEditableWordPanel: View {
        let title: String
        @Binding var words: [String]
        @Binding var sentence: [String]
        let color: Color
        @Binding var animateElements: Bool
        
        @State private var editingWord: String? = nil
        @State private var editText: String = ""
        @State private var showingDeleteAlert = false
        @State private var wordToDelete: String? = nil

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(words.count) words")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                            ModernEditableWordButton(
                                word: word,
                                color: color,
                                isEditing: editingWord == word,
                                editText: $editText,
                                animateElements: $animateElements,
                                index: index,
                                onTap: {
                                    if editingWord == word {
                                        finishEditing()
                                    } else {
                                        sentence.append(word)
                                    }
                                },
                                onEdit: { startEditing(word: word) },
                                onDelete: {
                                    wordToDelete = word
                                    showingDeleteAlert = true
                                },
                                onSubmitEdit: { finishEditing() }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .alert("Delete Word", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let wordToDelete = wordToDelete {
                        deleteWord(wordToDelete)
                    }
                }
            } message: {
                Text("Are you sure you want to delete '\(wordToDelete ?? "")'?")
            }
        }
        
        private func startEditing(word: String) {
            editingWord = word
            editText = word
        }
        
        private func finishEditing() {
            guard let editingWord = editingWord else { return }
            
            let trimmedText = editText.trimmingCharacters(in: .whitespaces)
            if !trimmedText.isEmpty && trimmedText != editingWord {
                if let index = words.firstIndex(of: editingWord) {
                    words[index] = trimmedText
                }
            }
            
            self.editingWord = nil
            editText = ""
        }
        
        private func deleteWord(_ word: String) {
            words.removeAll { $0 == word }
            wordToDelete = nil
        }
    }

    struct ModernEditableWordButton: View {
        let word: String
        let color: Color
        let isEditing: Bool
        @Binding var editText: String
        @Binding var animateElements: Bool
        let index: Int
        let onTap: () -> Void
        let onEdit: () -> Void
        let onDelete: () -> Void
        let onSubmitEdit: () -> Void
        
        private var buttonGradient: LinearGradient {
            LinearGradient(
                colors: [color.opacity(0.8), color.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        private var buttonAnimation: Animation {
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.05)
        }
        
        var body: some View {
            Button(action: onTap) {
                buttonContent
            }
            .scaleEffect(animateElements ? 1.0 : 0.98)
            .animation(buttonAnimation, value: animateElements)
            .contextMenu {
                Button("Edit") { onEdit() }
                Button("Delete", role: .destructive) { onDelete() }
            }
        }
        
        @ViewBuilder
        private var buttonContent: some View {
            if isEditing {
                editingView
            } else {
                normalView
            }
        }
        
        private var editingView: some View {
            TextField("Edit", text: $editText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(10)
                .frame(width: 80)
                .background(Color.white)
                .cornerRadius(12)
                .onSubmit { onSubmitEdit() }
        }
        
        private var normalView: some View {
            Text(word)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(backgroundShape)
                .overlay(borderShape)
        }
        
        private var backgroundShape: some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(buttonGradient)
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        
        private var borderShape: some View {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
    }
