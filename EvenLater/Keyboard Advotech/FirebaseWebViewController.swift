//
//  FirebaseWebViewController.swift
//  Keyboard Advotech
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 3/4/24.
//
import UIKit
import WebKit

class FirebaseWebViewController: UIViewController, WKScriptMessageHandler, ObservableObject { // Adopt protocol
    let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirebaseWebView()
        
}

    func loadFirebaseWebView() {
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www")!
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        
    webView.configuration.userContentController.add(self, name: "sendNotification") // Add Script Message Handler
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Message received from JavaScript:", message.body)
    }

    func sendNotification(message: String, caretakerID: String) {
        let notificationData = ["message": message, "caretakerID": caretakerID]
        let jsonData = try! JSONEncoder().encode(notificationData)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        webView.evaluateJavaScript("sendNotification.postMessage(\(jsonString))") {_,_ in }
    }
}
