//
//  TaskDetailView.swift
//  BrainBoosty
//
//  Created by Ikzul Stephen on 04.10.2025.
//


import UIKit
import WebKit
import PushwooshFramework
import AppTrackingTransparency
import UserNotifications

class WebviewVC: UIViewController, WKNavigationDelegate, PWMessagingDelegate {

    // MARK: - Properties
    let termsURL: URL
    private var isPushwooshInitialized = false

    // MARK: - Init
    init(url: URL) {
        self.termsURL = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        obtainCookies()
        firemanWebviewForTerms.navigationDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ⚙️ Инициализация Pushwoosh только при первом появлении
        if !isPushwooshInitialized {
            isPushwooshInitialized = true
            requestPushNotificationPermission()
        }
    }

    // MARK: - Pushwoosh Logic
    private func requestPushNotificationPermission() {
        if #available(iOS 14, *) {
            // ATT — для прозрачности, не обязательно, но безопасно
            ATTrackingManager.requestTrackingAuthorization { _ in
                self.initializePushwoosh()
            }
        } else {
            initializePushwoosh()
        }
    }

    private func initializePushwoosh() {
        print("🔹 Initializing Pushwoosh SDK")
        
        // ✅ ПРИНТ КЛЮЧА ДЛЯ ПРОВЕРКИ
        print("🔑 Pushwoosh App ID: \(Config.pushwooshAppId)")
        
        Pushwoosh.initialize(withAppCode: Config.pushwooshAppId)
        Pushwoosh.sharedInstance().delegate = self

        // 🔸 Запрашиваем разрешение и отслеживаем результат
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Error requesting push permission: \(error.localizedDescription)")
                return
            }
            
            if granted {
                print("✅ USER GRANTED PUSH PERMISSION!")
                // 👉 Здесь пользователь дал разрешение!
                self.onPushPermissionGranted()
                
                DispatchQueue.main.async {
                    Pushwoosh.sharedInstance().registerForPushNotifications()
                }
            } else {
                print("🚫 USER DENIED PUSH PERMISSION")
                // 👉 Здесь пользователь отказал
                self.onPushPermissionDenied()
            }
        }
    }

    private func onPushPermissionGranted() {
        print("🎉 Пользователь разрешил уведомления!")
        
        // Сохраняем в UserDefaults
        UserDefaults.standard.set(true, forKey: "pushPermissionGranted")
        UserDefaults.standard.set(Date(), forKey: "pushPermissionGrantedDate")
        
        // Отправляем аналитику или выполняем другие действия
        self.sendAnalyticsEvent("push_permission_granted")
    }

    private func onPushPermissionDenied() {
        print("😞 Пользователь запретил уведомления")
        UserDefaults.standard.set(false, forKey: "pushPermissionGranted")
        
        self.sendAnalyticsEvent("push_permission_denied")
    }

    private func sendAnalyticsEvent(_ event: String) {
        // Отправка в вашу аналитику (AppsFlyer, Firebase и т.д.)
        print("📊 Analytics: \(event)")
    }

    // MARK: - PWMessagingDelegate
    func pushwoosh(_ pushwoosh: Pushwoosh, onMessageReceived message: PWMessage) {
        print("📬 Push received: \(message.payload?.description ?? "")")
    }

    func pushwoosh(_ pushwoosh: Pushwoosh, onMessageOpened message: PWMessage) {
        print("📨 Push opened: \(message.payload?.description ?? "")")
    }

    // MARK: - WebView setup
    lazy var firemanWebviewForTerms: WKWebView = {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private func setupWebView() {
        view.addSubview(firemanWebviewForTerms)
        firemanWebviewForTerms.load(URLRequest(url: termsURL))
        NSLayoutConstraint.activate([
            firemanWebviewForTerms.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            firemanWebviewForTerms.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            firemanWebviewForTerms.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            firemanWebviewForTerms.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Cookies
    private func obtainCookies() {
        if let data = UserDefaults.standard.data(forKey: "cvcvcv"),
           let cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [HTTPCookie] {
            cookies.forEach { HTTPCookieStorage.shared.setCookie($0) }
        }
    }

    private func saveCookies() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: "cvcvcv")
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        saveCookies()
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ WebView loaded: \(webView.url?.absoluteString ?? "")")
        if SaveService.lastUrl == nil {
            SaveService.lastUrl = webView.url
        }
    }
}

// MARK: - SaveService
struct SaveService {
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: "LastUrl") }
        set { UserDefaults.standard.set(newValue, forKey: "LastUrl") }
    }
}
