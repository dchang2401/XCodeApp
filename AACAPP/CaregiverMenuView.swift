//
//  CaregiverMenuView.swift
//  AACAPP
//
//  Created by Daniel Chang on 8/3/25.
//

import SwiftUI
import AVFoundation
import Foundation
import Speech

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
