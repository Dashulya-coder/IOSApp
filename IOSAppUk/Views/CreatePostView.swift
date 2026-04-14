//
//  CreatePostView.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @State private var showFileImporter = false
    @State private var goToSettings = false

    var onPostCreated: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                authorBlock
                titleField
                textEditorBlock
                imagePickerBlock
                saveButton
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [.green.opacity(0.12), .blue.opacity(0.08), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Create post")
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                viewModel.selectedImageURL = urls.first
            case .failure:
                break
            }
        }
        .alert("Author name is missing", isPresented: $viewModel.showMissingAuthorAlert) {
            Button("Go to settings") {
                goToSettings = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter author name on settings screen")
        }
        .alert("Error", isPresented: $viewModel.showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.validationMessage)
        }
        .navigationDestination(isPresented: $goToSettings) {
            SettingsView()
        }
        .onAppear {
            viewModel.checkAuthorBeforeEnteringScreen()
        }
    }

    private var authorBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Author")
                .font(.headline)

            Text(viewModel.hasAuthorName ? viewModel.authorName : "Not set")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(viewModel.hasAuthorName ? Color.green.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 1)
                }
        }
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.headline)

            TextField("Enter short title", text: $viewModel.title)
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var textEditorBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Main text")
                .font(.headline)

            TextEditor(text: $viewModel.text)
                .frame(minHeight: 180)
                .padding(8)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var imagePickerBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photo")
                .font(.headline)

            Button {
                showFileImporter = true
            } label: {
                Label("Choose photo from Files", systemImage: "folder")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if let selectedImageURL = viewModel.selectedImageURL {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chosen file:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(selectedImageURL.lastPathComponent)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            viewModel.createPost {
                onPostCreated()
            }
        } label: {
            Text("Save post")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}
