//
//  ContentView.swift
//  IOSAppUk
//
//  Created by Daria Ukshe on 14.04.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RedditListContainerView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Posts")
                }

            NavigationStack {
                CreatePostView()
            }
            .tabItem {
                Image(systemName: "plus")
                Text("Create")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }
        }
    }
}

#Preview {
    ContentView()
}
