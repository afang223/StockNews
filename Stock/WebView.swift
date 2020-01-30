//
//  WebView.swift
//  Stock
//
//  Created by Andy Fang on 1/9/20.
//  Copyright © 2020 Andy Fang. All rights reserved.
//

import UIKit
import WebKit

class WebView: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.load(URLRequest(url: URL(string: url!)!))
    }
    

 

}
