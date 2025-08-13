//
//  PatientMenuView.swift
//  AACAPP
//
//  Created by Daniel Chang on 8/3/25.
//



import SwiftUI
import AVFoundation
import Foundation
import Speech

struct PatientMenuView: View {
    @State private var animateCards = false
    
    let menuItems = [
        MenuItem(
            icon: "book.fill",
            title: "Vocabulary",
            subtitle: "Express yourself with words",
            color: Color.blue,
            destination: AnyView(CombinedVocabView())
        ),
        MenuItem(
            icon: "mic.circle.fill",
            title: "Speech to Text",
            subtitle: "Convert your voice to text",
            color: Color.orange,
            destination: AnyView(SpeechToTextView())
        ),
        MenuItem(
            icon: "gamecontroller.fill",
            title: "Therapy Games",
            subtitle: "Fun exercises with your pet",
            color: Color.pink,
            destination: AnyView(GameifiedTherapyView())
        )
    ]
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    
                    // Menu Items
                    LazyVStack(spacing: 20) {
                        ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                            NavigationLink(destination: item.destination) {
                                MenuCardView(item: item)
                                    .scaleEffect(animateCards ? 1.0 : 0.8)
                                    .opacity(animateCards ? 1.0 : 0.0)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateCards)
                            }
                            .buttonStyle(CardButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            withAnimation {
                animateCards = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Welcome message
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Choose your tool")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                Spacer()
                
                // Profile/Settings button
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            // Quick stats or motivational message
            HStack {
                Spacer()
                VStack {
                    Text("🎯")
                        .font(.title2)
                    Text("Daily Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Divider()
                    .frame(height: 30)
                Spacer()
                VStack {
                    Text("🔥")
                        .font(.title2)
                    Text("3 Day Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Divider()
                    .frame(height: 30)
                Spacer()
                VStack {
                    Text("⭐")
                        .font(.title2)
                    Text("Level 4")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 24)
        }
    }
}

struct MenuItem {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AnyView
}

struct MenuCardView: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon container with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [item.color, item.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Image(systemName: item.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(item.subtitle)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Arrow with subtle animation
            ZStack {
                Circle()
                    .fill(item.color.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(item.color)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(item.color.opacity(0.1), lineWidth: 1)
        )
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
