//
//  SceneDelegate.swift
//  MemoryProfilerShowcase
//
//  Created by Egzon Pllana on 31.10.26.
//

import MemoryProfiler
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties

    var window: UIWindow?
    private var automatedRunner: AutomatedScenarioRunner?

    // MARK: - UIWindowSceneDelegate

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let scenariosNavigation = UINavigationController()
        let performer = ScenarioPerformer(navigation: scenariosNavigation)
        scenariosNavigation.viewControllers = [ScenarioListViewController(performer: performer)]
        scenariosNavigation.tabBarItem = UITabBarItem(title: "Scenarios", image: UIImage(systemName: "flask"), tag: 0)
        let eventsNavigation = UINavigationController(rootViewController: EventLogViewController(feed: .shared))
        let eventsImage = UIImage(systemName: "waveform.path.ecg")
        eventsNavigation.tabBarItem = UITabBarItem(title: "Events", image: eventsImage, tag: 1)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [scenariosNavigation, eventsNavigation]
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
        startAutomatedRunIfRequested(performer: performer)
    }

    // MARK: - Private Methods

    /// `-runAllScenarios` runs every scenario unattended, prints a transcript to stderr and exits.
    private func startAutomatedRunIfRequested(performer: ScenarioPerformer) {
        guard ProcessInfo.processInfo.arguments.contains("-runAllScenarios") else { return }
        let runner = AutomatedScenarioRunner(performer: performer, feed: .shared)
        automatedRunner = runner
        Task { await runner.run() }
    }
}
