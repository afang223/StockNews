//
//  MasterTableViewController.swift
//  Stock
//
//  Created by Andy Fang on 12/29/19.
//  Copyright © 2019 Andy Fang. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
  @IBOutlet var tableView: UITableView!

  
       var stocks: [Stock] = []
       let searchController = UISearchController(searchResultsController: nil)
       var filteredStocks: [Stock] = []

      override func viewDidLoad() {
          super.viewDidLoad()
          stocks = Stock.stocks()
          searchController.searchResultsUpdater = self
          searchController.obscuresBackgroundDuringPresentation = false
          searchController.searchBar.placeholder = "Search Companies"
          navigationItem.searchController = searchController
          definesPresentationContext = true
          searchController.searchBar.scopeButtonTitles = Stock.Category.allCases.map { $0.rawValue }
          searchController.searchBar.delegate = self
      }
      override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
         if let indexPath = tableView.indexPathForSelectedRow {
           tableView.deselectRow(at: indexPath, animated: true)
         }
       }
      
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             guard
               segue.identifier == "ShowDetailSegue",
               let indexPath = tableView.indexPathForSelectedRow,
               let detailViewController = segue.destination as? DetailViewController
               else {
                 return
             }
          
      let stock: Stock
        if isFiltering{
            stock = filteredStocks[indexPath.row]
        }else{
            stock = stocks[indexPath.row]
        }
        detailViewController.stock = stock
      }
      
      var isSearchBarEmpty: Bool{
          return searchController.searchBar.text?.isEmpty ?? true
      }
      
      var isFiltering: Bool{
             let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
             return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
         }
      
      func filterContentForSearchText(_ searchText: String,
                                      category: Stock.Category? = nil){
          filteredStocks = stocks.filter{ (stock : Stock) -> Bool in
              let doesCategoryMatch = category == .all || stock.category == category
              
              if isSearchBarEmpty{
                  return doesCategoryMatch
              }else{
                  return doesCategoryMatch && stock.name.lowercased().contains(searchText.lowercased())
              }
          }
          
          tableView.reloadData()
      }

  }

  extension MasterViewController: UITableViewDataSource{
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          
          if isFiltering{
              return filteredStocks.count
          }
          print(stocks.count)
          return stocks.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

          // Configure the cell...
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
          let stock: Stock
          if isFiltering{
              stock = filteredStocks[indexPath.row]
          }
          else{
              stock = stocks[indexPath.row]
          }
          cell.textLabel?.text = stock.name
          cell.detailTextLabel?.text = stock.category.rawValue
          return cell
      }
      
  }


  extension MasterViewController: UISearchResultsUpdating{
      func updateSearchResults(for searchController: UISearchController) {
          let searchBar = searchController.searchBar
          let category = Stock.Category(rawValue:
              searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
          filterContentForSearchText(searchBar.text!, category: category)
      }
  }

  extension MasterViewController: UISearchBarDelegate{
      func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
          let category = Stock.Category(rawValue: searchBar.scopeButtonTitles![selectedScope])
          filterContentForSearchText(searchBar.text!, category: category)
      }
  }
