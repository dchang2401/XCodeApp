//
//  QuestionPicker.swift
//  AACAPP
//
//  Created by Daniel Chang on 8/3/25.
//

import SwiftUI
import AVFoundation
import Foundation
import Speech

struct QuestionPicker: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            Picker(selection: $selection, label: Text("")) {
                ForEach(options, id: \ .self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.inline)
        }
    }
}
