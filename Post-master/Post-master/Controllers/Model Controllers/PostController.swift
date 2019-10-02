//
//  PostController.swift
//  Post-New
//
//  Created by Eric Lanza on 11/28/18.
//  Copyright © 2018 ETLanza. All rights reserved.
//

import Foundation

class PostController: Codable {
    // MARK: - Default URL
    static let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")

    
    // source of thruth
    static var posts: [Post] = []
    
    static func fetchPosts(reset: Bool = true, completion: @escaping () -> Void) {
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15"
        ]
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) })
        
        guard let unwrappedURL = self.baseURL else { fatalError("URL optional is nil") }
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { completion(); return}

        let getterEndPoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndPoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                completion()
                return
            }
            guard let data = data else {return}
            let jsonDecoder = JSONDecoder()
            do {
                let postDictionary = try
                    jsonDecoder.decode([String:Post].self, from: data)
                var posts = postDictionary.compactMap({ ($0.value) })
                posts.sort(by: { $0.timestamp > $1.timestamp})
                self.posts = posts
                //print(posts)
                completion() // does post or self.post go in here 
            } catch {
                completion()
                return
            }
            
        }
        dataTask.resume()
    }
    
    
    static func addNewPostWith(username: String, text: String, completion: @escaping (Bool) -> Void) {
        let post = Post(text: text, username: username)
        var postData: Data
        do {
            let jsonEncoder = JSONEncoder()
            postData = try jsonEncoder.encode(post)
        } catch {
            completion(false)
            return
        }
        
        guard let baseURL = PostController.baseURL else {return}
        let postEndPoint = baseURL.appendingPathExtension("json")
        completion(true)
        
        var request = URLRequest(url: postEndPoint)
        request.httpBody = postData
        request.httpMethod = "POST"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
//            guard let data = data else {return}
//            let dataAsString = String(data: data, encoding: .utf8)
//            print(dataAsString)
        }
        dataTask.resume()
        fetchPosts {
           completion(true)
        }
        
    }
} // end of class


