//
//  SurveyView.swift
//  AACAPP
//
//  Created by Daniel Chang on 8/9/25.
//

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
