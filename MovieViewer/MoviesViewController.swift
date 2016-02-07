//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Akhila Murella on 1/30/16.
//  Copyright © 2016 Akhila Murella. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var endpoint: String!
    var movies: [NSDictionary]?
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Initialize a UIRefreshControl
 

        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Do any additional setup after loading the view.
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData() //reload after network request
                            self.refreshControl.endRefreshing()
                            
                    }
                }
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)
        })
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if let movies = movies
        {
            return movies.count
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell //downcast to become MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as? String  //!force casts and reads in value at title
        let overview = movie["overview"] as? String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseURL = "http://image.tmdb.org/t/p/w342"
        if let posterPath = movie["poster_path"] as? String
        {
            let imageURL = NSURL(string: baseURL + posterPath)
            cell.posterView.setImageWithURL(imageURL!)
        }
        
        
        
        
        func setSelected(selected: Bool, animated: Bool) {
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.redColor()
            cell.selectedBackgroundView = backgroundView
        }
        
        print("row \(indexPath.row)")
        return cell
    }
    
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        // Reload the tableView now that there is new data
        self.tableView.reloadData()
        
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        print("prepare for segue")
    }

}
