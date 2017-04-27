//
//  ManagerAPI.swift
//  VIDME
//
//  Created by Hyzhnyak Evgen on 19.04.17.
//  Copyright © 2017 Hyzhnyak Evgen. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class NewViewController: UITableViewController {
    
    var videos = [Video]()
    weak var selectedVideo: Video?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: VideoCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: VideoCell.self))
        tableView.contentInset.top = UIApplication.shared.statusBarFrame.height
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshVideos(self.refreshControl!)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        VideoDataService.getNewVideoList(limit: 10, offset: self.videos.count) { (error, videos) in
            self.upadateTableView(videoList: videos!)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVideo = videos[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: playVideoSegueIdentifier, sender: nil)
    }
    
    //MARK: Actions
    
    @IBAction func refreshVideos(_ sender: UIRefreshControl) {
        VideoDataService.getNewVideoList(limit: 10, offset: 0) { (error, videos) in
            sender.endRefreshing()
            
            if let videoList = videos {
                self.videos = videoList
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: UITableViewDelegate and UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoCell.self)) as! VideoCell
        let video = videos[(indexPath as NSIndexPath).row]
        
        cell.nameLabel.text = video.title
        cell.likesLabel.text = "\(video.likesCount) 👍🏿"
        
        if let thumbnailData = video.thumbnail {
            cell.videoPreview.image = UIImage(data: thumbnailData as Data)
        } else {
            cell.videoPreview.image = nil
            VideoDataService.getThumbnailForVideo(video, completionHandler: {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            })
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let video = videos[(indexPath as NSIndexPath).row]
        let previewHeightToWidthRatio = CGFloat(video.height / video.width)
        let previewHeight = tableView.bounds.width * previewHeightToWidthRatio
        return CellHeight + previewHeight
    }
    
    func upadateTableView(videoList: [Video]) {
        var indexPaths = [IndexPath]()
        
        if (self.videos.last?.title == videoList.last?.title) {
            return
        }
        
        let fromCount = self.videos.count
        self.videos += videoList
        let toCount = self.videos.count
        
        for i in fromCount...toCount-1 {
            indexPaths.append(IndexPath.init(row: i, section: 0))
        }
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexPaths, with: .fade)
        self.tableView.endUpdates()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == playVideoSegueIdentifier {
            let playerViewController = segue.destination as! AVPlayerViewController
            let playerItem = AVPlayerItem(url: URL(string: selectedVideo!.videoURL!)!)
            playerViewController.player = AVPlayer(playerItem: playerItem)
            playerViewController.player?.play()
        } else {
            super.prepare(for: segue, sender: sender)
        }
        
    }
}

