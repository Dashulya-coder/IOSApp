//
//  SettingsView.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showSavedAlert = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.orange.opacity(0.12), .pink.opacity(0.10), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Author name")
                        .font(.headline)

                    TextField("Enter your name", text: $viewModel.authorName)
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    viewModel.saveAuthorName()
                    showSavedAlert = true
                } label: {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Settings")
        .alert("Saved", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Author name was saved.")
        }
    }
}
