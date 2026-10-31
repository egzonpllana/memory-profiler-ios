//
//  ProfileScreen.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import MemoryProfiler
import SwiftUI

/// SwiftUI screen that declares its model's lifetime with `detectLeaks(of:)`.
struct ProfileScreen: View {

    @StateObject private var model = ProfileModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(model.name)
                    .font(.title.bold())
                Text("""
                ProfileModel registers itself in ListenerRegistry.shared and never unregisters. \
                Close this screen: SwiftUI tears down the view state, the registry keeps the model alive, \
                and the Events tab reports it.
                """)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("SwiftUI")
            .toolbar {
                Button("Close") { dismiss() }
            }
        }
        .detectLeaks(of: model)
    }
}
