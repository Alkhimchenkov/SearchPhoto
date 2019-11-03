//
//  ViewController.swift
//  SearchPhoto
//
//  Created by Andrey Alhimchenkov on 11/3/19.
//  Copyright © 2019 Andrey Alhimchenkov. All rights reserved.
//

import UIKit
import RealmSwift

class FilterRequest: Object {
    @objc dynamic var request = "";
    @objc dynamic var imageURL = "";
}

class ViewController: UIViewController {
    
    let accessRealm = try! Realm();// object Realm for access to the database
    
    var itemsRequest: Results<FilterRequest>!;
    
    let tableView = UITableView.init(frame: CGRect.zero, style: .plain);
    let searchBar = UISearchBar(frame: .zero);
    let spinnerTable = UIActivityIndicatorView(style: .gray);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.titleView = searchBar;
        self.view.addSubview(self.tableView);
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell");
        self.tableView.dataSource = self;
        self.tableView.delegate   = self;
        self.searchBar.delegate = self;
        self.itemsRequest = accessRealm.objects(FilterRequest.self);
        
        self.spinnerTable.hidesWhenStopped = true;
        self.spinnerTable.center = self.view.center;
        self.view.addSubview(spinnerTable);
        
        
        self.refreshLayout(with: self.view.frame.size);
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator);
        coordinator.animate(alongsideTransition: { (context) in
            self.refreshLayout(with: size);
        }, completion: nil);
    }
    
    private func refreshLayout(with size:CGSize ){
        self.tableView.frame = CGRect.init(origin: .zero, size: size);
    }
    
    private func saveRequest(request:String, imageURL:String){ // Save To Access Realm
        let filterRequest = FilterRequest(value: [request, imageURL]); // create model
        try! accessRealm.write { // write request
            accessRealm.add(filterRequest);
        }
        self.spinnerTable.stopAnimating();
        self.tableView.reloadData();
    }
    
    // MARK: get url parametr for filckr
    private func getFlickrURLParametr(request: String) -> URL {
        
        // Build base URL
        var components = URLComponents();
        components.scheme = Constants.URLParamStr.Scheme;
        components.host = Constants.URLParamStr.Host;
        components.path = Constants.URLParamStr.Path;
        
        // Build query string
        components.queryItems = [URLQueryItem]();
        
        // Query components
        components.queryItems!.append(URLQueryItem(name: Constants.APIKeyStr.APIKey, value: Constants.APIValStr.APIKey));
        components.queryItems!.append(URLQueryItem(name: Constants.APIKeyStr.SearchMethod, value: Constants.APIValStr.SearchMethod));
        components.queryItems!.append(URLQueryItem(name: Constants.APIKeyStr.ResponseFormat, value: Constants.APIValStr.ResponseFormat));
        components.queryItems!.append(URLQueryItem(name: Constants.APIKeyStr.Extras, value: Constants.APIValStr.MediumURL));
        components.queryItems!.append(URLQueryItem(name: Constants.APIKeyStr.SafeSearch, value: Constants.APIValStr.SafeSearch));
        components.queryItems!.append(URLQueryItem(name: Constants.APIKeyStr.DisableJSONCallback, value: Constants.APIValStr.DisableJSONCallback));
        components.queryItems!.append(URLQueryItem(name: Constants.APIKeyStr.Text, value: request));
        
        return components.url!;
    }
    
    // MARK: get image from flickr
    private func startFlickrSearchURL(requesthURL: URL, requestSearch:String){
        // Perform the request
        let session = URLSession.shared;
        let request = URLRequest(url: requesthURL);
        let task = session.dataTask(with: request){
            (data, response, error) in
            if (error == nil){
                
                // Check response code
                let status = (response as! HTTPURLResponse).statusCode;
                if (status < 200 || status > 300){
                    self.displayAlert("Server returned an error");
                    return;
                }
                
                /* Check data returned? */
                guard let data = data else {
                    self.displayAlert("No data was returned by the request!");
                    return;
                }
                
                // Parse the data
                let fotosResult: [String:AnyObject]!;
                do {
                    fotosResult = try (JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]);
                } catch {
                    self.displayAlert("Could not parse the data as JSON: '\(data)'");
                    return;
                }
                
                // Check for "photos" key in our result
                guard let photosDict = fotosResult["photos"] as? [String:AnyObject] else {
                    self.displayAlert("Key 'photos' not found!");
                    return;
                }
                
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosList = photosDict["photo"] as? [[String: AnyObject]] else {
                    self.displayAlert("Cannot find key 'photo' in Dictionary");
                    return;
                }
                
                // Check number of ophotos
                if photosList.count == 0 {
                    self.displayAlert("No Photos Found. Search Again.");
                    return;
                } else {
                    // Get the image random
                    let index = Int(arc4random_uniform(UInt32(photosList.count)));
                    let photoDict = photosList[index] as [String: AnyObject];
                    
                    // our photo key 'url_m'?
                    guard let imageUrlString = photoDict["url_m"] as? String else {
                        self.displayAlert("Cannot find key 'url_m' in dictionary");
                        return;
                    }
                    
                    // Fetch the image
                    self.fetchImageURL(url: imageUrlString, request: requestSearch);
                }
                
            }
            else{
                self.displayAlert((error?.localizedDescription)!);
            }
        }
        task.resume();
    }
    
    // MARK: get image
    private func fetchImageURL(url: String, request:String) {
        
        let imageURL = URL(string: url);
        let task = URLSession.shared.dataTask(with: imageURL!) { (data, response, error) in
            if error == nil {
                _ = CacheImage.shared.imageToCacheData(path: url, imageData: data! as NSData);
                DispatchQueue.main.async(){
                    self.saveRequest(request: request, imageURL: url);
                }
            }
        }
        
        task.resume()
    }
    
    
    // MARK: Alert for Message Error
    func displayAlert(_ message: String){
        let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: Table View Data Source
extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.itemsRequest.count != 0{
            return self.itemsRequest.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell;
        cell.searchResult.text = self.itemsRequest[indexPath.row].request;
        cell.searchImage.image = CacheImage.shared.imageFromCache(path: self.itemsRequest[indexPath.row].imageURL);
        cell.searchImage.contentMode = .scaleAspectFill;
        return cell;
    }
    
    
}

// MARK: Table View Delegate
extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        
        let deleteRow = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            try! self.accessRealm.write {
                self.accessRealm.delete(self.itemsRequest[indexPath.row]);
            }
            self.tableView.reloadData();
        }
        return [deleteRow];
    }
    
}

// MARK: Search Bar Delegate
extension ViewController: UISearchBarDelegate{
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool{
        searchBar.showsCancelButton = true;
        return true;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.text = nil;
        searchBar.showsCancelButton = false;
        searchBar.resignFirstResponder();
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let text = searchBar.text;
        
        self.searchBarCancelButtonClicked(searchBar);
        
        if text!.trimmingCharacters(in: .whitespaces).isEmpty{
            displayAlert("Search text cannot be empty")
            return;
        }
        self.spinnerTable.startAnimating();
        self.startFlickrSearchURL(requesthURL: getFlickrURLParametr(request: text!), requestSearch: text!);
        
    }
}
