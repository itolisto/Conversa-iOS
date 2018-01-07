//
//  FavoritesViewController.swift
//  Conversa
//
//  Created by Edgar Gomez on 11/30/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit

class FavoritesViewController : UICollectionViewController {

    // MARK: - Properties
    fileprivate let reuseIdentifier = "favoriteCollectionCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 4.0, left: 7.0, bottom: 4.0, right: 7.0)
    // Will keep track of all the searches
    fileprivate var searches = [FavoriteSearchResults]()
    // Object that will do the searching
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate var searchMode: Bool! = false
    fileprivate var searchController: UISearchController!
    fileprivate var skip : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController = UISearchController(searchResultsController: nil)
        // If we are using this same view controller to present the results
        // dimming it out wouldn't make sense.  Should set probably only set
        // this to yes if using another controller to display the search results.
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.showsScopeBar = false
        self.searchController.searchBar.delegate = self
        // self.searchController.searchBar.placeholder = NSLocalizedString(@"chat_searchbar_placeholder", nil);
        // Sets this view controller as presenting view controller for the search interface
        self.definesPresentationContext = true
        // Set SearchBar into NavigationBar
        //self.tableView.tableHeaderView = self.searchController.searchBar;
        self.searchController.searchBar.sizeToFit()
        // By default the navigation bar hides when presenting the
        // search interface.  Obviously we don't want this to happen if
        // our search bar is inside the navigation bar.
        self.searchController.hidesNavigationBarDuringPresentation = true

        Favorite.getFavorites(customerId: SettingsKeys.getCustomerId(), skip: skip) { (results, error) in
            //activityIndicator.removeFromSuperview()

            if let error = error {
                // 2
                print("Error searching : \(error)")
                return
            }

            if let results = results {
                // 3
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.insert(results, at: 0)

                // 4
                self.collectionView?.reloadData()
            }

            self.skip += 1
        }

    }

}

// MARK: Private
private extension FavoritesViewController {

    func favoriteForIndexPath(indexPath: IndexPath) -> Favorite {
        return searches[(indexPath as NSIndexPath).section].searchResults[(indexPath as IndexPath).row]
    }

}

// MARK: UICollectionViewDelegate Methods
extension FavoritesViewController  {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let business = favoriteForIndexPath(indexPath: indexPath)

        // Present view controller
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profileViewController") as! ProfileDialogViewController

        // Pass any objects to the view controller here, like...
        vc.objectId = business.objectId
        vc.avatarUrl = business.avatarUrl
        vc.displayName = business.name
        vc.conversaID = "fasd"//business.conversaId
        vc.enable = true
//        [Flurry logEvent:@"user_profile_open" withParameters:@{@"fromCategory": @(YES)}];
//
        self.navigationController?.present(vc, animated: true, completion: nil)
    }

}

// MARK: UICollectionViewDataSource Methods
extension FavoritesViewController  {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return searches.count > 0 ? searches[section].searchResults.count : 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! FavoriteCollectionCell

        let favoriteBusiness = favoriteForIndexPath(indexPath: indexPath)
        // Configure the cell
        cell.configureCellWith(favoriteBusiness)

        return cell
    }

}

extension FavoritesViewController : UICollectionViewDelegateFlowLayout {
    // Responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        /*
         * Here, you work out the total amount of space taken up by padding. There will be
         * n + 1 evenly sized spaces, where n is the number of items in the row. The space
         * size can be taken from the left section inset. Subtracting this from the view’s
         * width and dividing by the number of items in a row gives you the width for each
         * item. You then return the size as a square
         */
        let paddingSpace = 1 * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem + 28)
    }
}

// MARK: UISearchBarDelegate Methods

extension FavoritesViewController : UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //[self performSearch:searchBar];
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //[self performSearch:searchBar];
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if (!self.searchMode) {
            self.searchMode = true
            // [self.tableView reloadData];
        }
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchMode = false
        //    [self.tableView reloadData];
        searchBar.setShowsCancelButton(false, animated: true)
    }

}

// MARK: Search delegate
extension FavoritesViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 1
//        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        textField.addSubview(activityIndicator)
//        activityIndicator.frame = textField.bounds
//        activityIndicator.startAnimating()

        Favorite.getFavorites(customerId: SettingsKeys.getCustomerId(), skip: skip) { (results, error) in
            //activityIndicator.removeFromSuperview()

            if let error = error {
                // 2
                print("Error searching : \(error)")
                return
            }

            if let results = results {
                // 3
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.insert(results, at: 0)

                // 4
                self.collectionView?.reloadData()
            }

            self.skip += 1
        }

        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

