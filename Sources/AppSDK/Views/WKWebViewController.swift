//
//  WKWebViewController.swift
//  
//
//  Created by Joe Manto on 5/28/23.
//

import Foundation
import AppKit
import WebKit

class WKWebViewController: NSViewController {
    
    lazy private(set) var webview: WKWebView = {
        return WKWebView()
    }()
    
    var initialURL: URL?
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webview)
        
        NSLayoutConstraint.activate([
            self.webview.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.webview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.webview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear() {
        if let url = self.initialURL {
            self.loadPage(url: url)
        }
        
        super.viewWillAppear()
    }
    
    func loadPage(url: URL) {
        guard let html = try? String(contentsOf: url) else {
            return
        }
        
        self.webview.loadHTMLString(html, baseURL: url)
    }
}
