//
//  PostListViewController.swift
//  Post-New
//
//  Created by Eric Lanza on 11/28/18.
//  Copyright © 2018 ETLanza. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        PostController.fetchPosts{
        
            self.reloadTableView()
        }
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        tableView.refreshControl = refresh
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        presentNewPostAlert()
    }
    
    func presentNewPostAlert() {
        let alert = UIAlertController(title: "Add New Post", message: "", preferredStyle: .alert)
        
        
        
        let addButton = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let username = alert.textFields?[0].text,
                let text = alert.textFields?[1].text else {return}
            if username.isEmpty || text.isEmpty {
                self.presentErrorAlert()
            }
            PostController.addNewPostWith(username: username, text: text) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        let cancleButton = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addTextField { (_) in
            alert.textFields?[0].placeholder = "username"
        }
        alert.addTextField { (_) in
            alert.textFields?[1].placeholder = "message"
        }
        alert.addAction(addButton)
        alert.addAction(cancleButton)
        self.present(alert, animated: true)
    }
    
    func presentErrorAlert() {
        let alert = UIAlertController(title: "Add the info jackass", message: "", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    @objc func refreshControlPulled() {
        PostController.fetchPosts {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.reloadTableView()
                
            }
        }
    }
    func reloadTableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
           
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = PostController.posts[indexPath.row]
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.timestamp)"
        
        
        
        return cell
    }
}// end of class
extension PostListViewController  {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= PostController.posts.count - 1 {
            PostController.fetchPosts(reset: false) {
                self.reloadTableView()
            }
        }
    }
}
