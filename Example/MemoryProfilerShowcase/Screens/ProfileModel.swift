//
//  ProfileModel.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// SwiftUI model that registers itself globally and never unregisters.
@MainActor
final class ProfileModel: ObservableObject {

    @Published private(set) var name = "Ada Lovelace"

    init() {
        ListenerRegistry.shared.register(self)
    }
}
