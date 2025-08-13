//
//  MainMenuView.swift
//  AACAPP
//
//  Created by Daniel Chang on 8/2/25.
//

import SwiftUI
import AVFoundation
import Foundation
import Speech

struct MainMenuView: View {
    @State private var animateButtons = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6), Color.pink.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating circles for visual interest
                GeometryReader { geometry in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .offset(x: -50, y: -100)
                    
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 300, height: 300)
                        .offset(x: geometry.size.width - 150, y: geometry.size.height - 200)
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // App Title Section
                    VStack(spacing: 16) {
                        // App icon placeholder
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "message.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animateButtons ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateButtons)
                        
                        Text("SpeakEasy")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                        
                        Text("Communication Made Simple")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 60)
                    
                    // Mode Selection Buttons
                    VStack(spacing: 24) {
                        // Patient Mode Button
                        NavigationLink(destination: PatientMenuView()) {
                            ModeButtonView(
                                icon: "figure.wave",
                                title: "Patient Mode",
                                subtitle: "Tools for communication",
                                gradient: LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }
                        .scaleEffect(animateButtons ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.2), value: animateButtons)
                        
                        // Caregiver Mode Button
                        NavigationLink(destination: CaregiverMenuView()) {
                            ModeButtonView(
                                icon: "heart.fill",
                                title: "Caregiver Mode",
                                subtitle: "Manage and customize",
                                gradient: LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }
                        .scaleEffect(animateButtons ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.4), value: animateButtons)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Footer
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white.opacity(0.7))
                        Text("Designed for individuals with communication needs")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 30)
                }
            }
            .onAppear {
                animateButtons = true
            }
        }
    }
}

struct ModeButtonView: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon container
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(gradient)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
