//
//  ManagerAPI.swift
//  VIDME
//
//  Created by Hyzhnyak Evgen on 27.04.17.
//  Copyright © 2017 Hyzhnyak Evgen. All rights reserved.
//

import UIKit

class FeedViewController: FeaturedViewController {
    
    @IBOutlet weak var logoutBarButton: UIBarButtonItem?
    @IBOutlet weak var flexibleSpaceBarButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set up toolbar
        navigationController?.toolbar.isHidden = false
        toolbarItems = [flexibleSpaceBarButtonItem!, logoutBarButton!, flexibleSpaceBarButtonItem!]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if videos.count == 0 {
            self.refreshVideos(self.refreshControl!)
        }
    }


    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        VideoDataService.getFeauturedVideoList(limit: 10, offset: self.videos.count) { (error, videos) in
            self.upadateTableView(videoList: videos!)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVideo = videos[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: playVideoSegueIdentifier, sender: nil)
    }
    
    //MARK: Actions
    
    @IBAction override func refreshVideos(_ sender: UIRefreshControl) {
        
        VideoDataService.getFeauturedVideoList(limit: 10, offset: self.videos.count) { (error, videos) in
            self.upadateTableView(videoList: videos!)
        }
     
    }
    
    @IBAction func logoutUser(_ sender: AnyObject) {
        VideoDataService.logoutUser {_ in
                self.navigationController?.popViewController(animated: true)
        }
    }
}
