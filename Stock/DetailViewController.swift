//
//  DetailViewController.swift
//  Stock
//
//  Created by Andy Fang on 12/29/19.
//  Copyright © 2019 Andy Fang. All rights reserved.
//

import UIKit
import Foundation

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
  var stock: Stock? {
    didSet {
      configureView()
    }
  }
    
    var articles: [Article]? = []
    var stuff: [CompanyInfo]? = []
    var value: Double = 0
  
  override func viewDidLoad() {
    detailDescriptionLabel.layer.masksToBounds = true
    detailDescriptionLabel.layer.cornerRadius = 5
    super.viewDidLoad()
    fetchInfo()
    configureView()
    fetchArticles()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 600
  }
    
  
  func configureView() {
    if let stock = stock,
        let detailDescriptionLabel = detailDescriptionLabel{
        title = stock.name
        detailDescriptionLabel.text = "NASDAQ: \(stock.symbol)    $\(String(format: "%.2f", self.value))"
    }
  }
    
  func fetchArticles() {
        if let stock = stock{
            let stockName = stock.name.lowercased()
            let final = stockName.replacingOccurrences(of: " ", with: "-")
            let urlRequest = URLRequest(url: URL(string: "https://newsapi.org/v2/everything?q=\(final)&language=en&sortBy=publishedAt&apiKey=f28775ca9e7d4deda54773e691361e18")!)
            let task = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
                
                if error != nil{
                    print(error)
                    return
                }
                
                self.articles = [Article]()
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    
                    if let articlesFromJson = json["articles"] as? [[String : AnyObject]]{
                        
                        var articleTitles = [String]()
                        
                        for articleFromJson in articlesFromJson {
                            
                            if let title = articleFromJson["title"] as? String,
                                let author = articleFromJson["author"] as? String,
                                let summary = articleFromJson["description"] as? String,
                                let url = articleFromJson["url"] as? String,
                                let imageUrl = articleFromJson["urlToImage"] as? String{
                                if !(articleTitles.contains(title)){
                                    let article = Article()
                                    article.articleTitle = title
                                    article.author = author
                                    article.summary = summary
                                    article.url = url
                                    article.imageurl = imageUrl
                                    self.articles?.append(article)
                                    articleTitles.append(title)
                                }
                            }
                            
                        }
                    }
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                    
                } catch let error {
                    print(error)
                }
                
            }
            task.resume()
        }
    }
    
    func fetchInfo() {
           if let stock = stock{
            var semaphore = DispatchSemaphore (value: 0)

            var request = URLRequest(url: URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(stock.symbol)&interval=1min&apikey=8P4X5TE61BCV3BTV")!,timeoutInterval: Double.infinity)
            request.httpMethod = "GET"

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
              guard let data = data else {
                print(String(describing: error))
                return
                }
              let jsonString = String(data: data, encoding: .utf8)!
              let jsonData = Data(jsonString.utf8)
              do {
                    // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers) as? [String: Any] {
                        // try to read out a string array
                        if let info = json["Time Series (1min)"] as? [String: Any]{
                            for (key, value) in info{
                                if let items = value as? [String: String]{
                                    print(items["4. close"]!)
                                    if self.value == Double("0.00"){
                                        self.value = Double(items["4. close"]!) as! Double
                                    }
                                }
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }

              semaphore.signal()
            }

            task.resume()
            semaphore.wait()

        }
       }
       
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles?.count ?? 0
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
        cell.articleTitle.text = self.articles?[indexPath.item].articleTitle
        cell.author.text = self.articles?[indexPath.item].author
        cell.articleSummary.text = self.articles?[indexPath.item].summary
        cell.articleImage.downloadImage(from: (self.articles?[indexPath.item].imageurl!)!)
          return cell
      }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 199
    }
      
      func numberOfSections(in tableView: UITableView) -> Int {
          return 1
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "web") as! WebView
        webVC.url = self.articles?[indexPath.item].url
        self.present(webVC, animated: true, completion: nil)
        
    }
    
    
}


extension UIImageView{
    func downloadImage(from url: String){
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            
            if error != nil{
                print(error)
                return
            }
            
            DispatchQueue.main.async{
                self.image = UIImage(data: data!)
            }
            
        }
        
        task.resume()
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
