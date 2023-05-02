//
//  ViewController.swift
//  Project4
//
//  Created by Brandon Johns on 4/21/23.
//

import UIKit
import WebKit

// view controller is view controlelr and conforms to webkit navigation delegate
class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView! // unwrapped
    var progressView: UIProgressView!
    
    var websites = ["yahoo.com", "apple.com", "hackingwithswift.com",  "google.com"]
    

    override func loadView() {
        
        
        webView = WKWebView()  // assigning webview varible to the webview property
        
        //delegate one thing acting inplcae of another answering questions and responding to events
        // when any webpage happens tell current view controller
        webView.navigationDelegate = self

        view = webView // view of view controller
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // #selector calls objective c methods
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) // creates as much flexible space as possible
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload)) //builds the refresh button onto the tool bar
        
        
        //creates the thin line in the bar
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView) //creates a progress bar button
        
        
        toolbarItems = [progressButton, spacer, refresh] // this is where the items in the tool bar
        navigationController?.isToolbarHidden = false
        
        //must also have a call to remove observer
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil) // who == self
                                                                                                                  // what is being observed estimated progress
                                                                                                                  // value  the new value set
        // for keypath is property inside another
        
        /// creates the url and force unwraps because the url was typed in
        let url = URL(string: "https://" + websites[0])!
    
        // updates the view to load the url and request the url created
        webView.load(URLRequest(url: url))
        // this allows gestures
        webView.allowsBackForwardNavigationGestures = true
    }

    @objc func openTapped()
    {
        
        // message to nil becaues it doesnt need a message
        // .actionsheet choose one of these options
        let alert_controller = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        

        // call to the websites array to load the approved websites
        for website in websites {
            alert_controller.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        // hide when cancel is tapped
        alert_controller.addAction(UIAlertAction(title: "cancel", style: .cancel))
        
        // for ipads where action sheet ancored
        alert_controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(alert_controller, animated: true)
    }
    
    
    // action = the UIAlertAction which is the action the user selected
    func openPage(action: UIAlertAction)
    {
        //creates a safe use of action title
        guard let action_title = action.title else { return }
        // puts https:// in front of the action title selected by the user
        guard let url = URL(string: "https://" + action_title) else {return}
        
        // url gets put into a URLRequest and calls the webview to load it.
        webView.load(URLRequest(url: url))
    }// this method loads anything as long the the websites are correct within the action
    
    //called when webpage has finished loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        
    }
    
    // must be implemented after addObserver
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"
        {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    
    /// to allow navigation to happen every time or not
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //decisionHandler == closure
        // closure can escape method and used later thats whyits @escaping
        
        let url = navigationAction.request.url // this is the url of the navigation
        
        if let host = url?.host() { // if there is a website upwrap it
            for website in websites { // loop websites
                if host.contains(website)
                {
                    decisionHandler(.allow) // allow loading if exists
                    return
                }
                
            }
        }
        
        decisionHandler(.cancel) // if let fails or no websites were found
    }

}

