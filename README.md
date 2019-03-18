# Post - Part One

## Project Summary

Post is a simple global messaging service. Students will review MVC principles and work with URLSession, JSON parsing, and closures to build an app that lists and submits posts to a global feed.

Post is a single view application, with the main view being a list of all posts from the global feed listed in reverse-chronological order. The user can add posts via an alert controller presented after tapping an Add (+) bar button item.

Students who complete this project independently are able to:

* use URLSession to make asynchronous GET HTTP requests
* implement the Codable protocol to decode JSON data and generate model objects from requests
* use closures to execute code when an asynchronous task is complete
* use UIRefreshControl to reload data for a table view

## Part One - Model Objects, Model Controller, URLSessionDataTask (HTTP GET method), Refresh Control

## Setup

* If you haven't already, `fork` and `clone` this [student](https://github.com/DevMountain/iOS-Student) repository from GitHub
* Open the `Post.xcodeproj` in the `Afternoon Projects/Unit 3 - Networking/Day 1 & 2/Post` folder

## Step One - Model Objects

### Summary 

In this step, you will create your `Post` model object, give it stored properties and a memberwise initializer.

### Instructions

Create a model object that will represent the `Post` objects that are listed in the feed. This model object will be generated locally, but must also be able to be initialized by decoding JSON data after "GETting" from the backend database.

* Create a `Post.swift` file and define a new `Post` struct.
* Go to a sample endpoint of the [Post API](http://devmtn-posts.firebaseio.com/posts.json) and see what JSON (information) you will get back for each post.
* Using this information, add the properties on `Post`.
    * <details>

        <summary> <code> Hint </code> </summary>

        * There should be 3 properties for this object currently
        * timestamp is of type TimeInterval
    </details>
   
* Create a memberwise initializer that takes parameters for the `username` and `text`. Add a parameter for the `timestamp`, but set a default value for it.

    * Note: This memberwise initializer will only be used locally to generate new model objects. When initializing a new `Post` model object we will use the `.timeIntervalSince1970` from the current date for the `timestamp`.

    * <details>

        <summary> <code> Code Hint </code> </summary>

        `timestamp: TimeInterval = Date().timeIntervalSince1970)`
        </details>

Remember, unless you customize it to do otherwise, `JSONEcoder` will use the names of each property as the keys for the JSON data it creates. (EXACT spelling matters!)

There is one more computed property you will add to the `Post` type called `queryTimestamp`, but we will discuss that in Part 2.

## Step Two - Model Controller

### Summary

In this step, you will create a `PostController` class. This class will contain a function that will use a `URLSessionDataTask` to fetch data and will serialize the results into `Post` objects. This class will be used by the view controllers to fetch `Post` objects through completion closures.

Because you will only use one View Controller in this project, there is no reason to make this controller a singleton or shared controller. To learn more about when singletons may not be the best tool, review this article on [Singleton Abuse](https://www.objc.io/issues/13-architecture/singletons/#global-state). The key takeaway, for now, is that singletons aren't always the right tool for the job and you should carefully consider if it is the best pattern for accessing data in your project.

### Instructions

* Create a `PostController` class

* Add a constant `baseURL` to know the base URL for the /posts/ subdirectory. This URL will be used to build other URLs throughout the app.
  * <details>

    <summary> <code> Code Hint </code> </summary>

    `let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")`
    </details>

* Add a `posts` property that will hold the `Post` objects that you pull and decode from the API.
  * <details>

    <summary> <code> Hint </code> </summary>

    This is your "Source of Truth"
    </details>

* Add a method `fetchPosts` that provides a completion closure.
  * <details>

    <summary> <code> Code Hint </code> </summary>

    `func fetchPosts(completion: @escaping () -> Void) {`
    </details>

## Step Three - URLSessionDataTask

### Summary 

In the next steps, you will create an instance of `URLSessionDataTask` that will get the data at the endpoint URL.

### Instructions

* Create an unwrapped instance of the `baseURL.

  * Hint: use a `guard let` statement

* Create a constant `getterEndpoint` which takes the unwrapped `baseURL` and appends a path extension of `"json"`
  * <details>

    <summary> <code> Code Hint </code> </summary>

    `let getterEndpoint = unwrappedURL.appendingPathExtension("json")`
    </details>

* Create an instance of `URLRequest` and give it the `getterEndpoint`. (It's very important that you _not_ forget to set the request's httpMethod and httpBody.)
  * The httpBody and httpMethod are used to tell the API what we are going to do with URLSessionDataTask. We will go into more detail on this later, but for now, know that "GET" is used to receive the JSON data from the API.

  * <details>

    <summary> <code> Code Hint </code> </summary>

    `var request = URLRequest(url: getterEndpoint)`

    `request.httpBody = nil`

    `request.httpMethod = "GET"`
    </details> 

* Create an instance of `URLSessionDataTask`  This method will make the network call and call the completion closer with the `Data?`, `URLResponse?` and `Error?` results.
  * <details>

    <summary> <code> Code Hint </code> </summary>

    `let dataTask = URLSession.shared.dataTas(with:completionHandler:)`
    </details>

  * ***Important:*** Don't forget to call `resume()` after creating this instance. 
        Do this by putting `dataTask.resume()` after the `let dataTask = URLSession...`'s **closing** brace.)


* In the closure of the `dataTask(with: URLRequest, completionHandler: ...)`, you will need to handle the results it comes back with

* Enter `request` for the `URLRequest` parameter, and then highlight the completionHandler and press your *Return* key

* You will need to give the `Data?`, `URLResponse?` and `Error?` results each a name. We suggest `(data, _, error)`. (You can use the '_' (wildcard) when naming the URLResponse because we will not be using it in this project)

* If the dataTask was successful at retrieving data, `data` will have value, and `error` will not. The opposite is also true. If unsuccessful, `data` will be nil and `error` will have value. 

* First, we need to Check for an error. If there is an error, print that error, call `completion()`, and `return`.

    * Hint: Use an `if let` to check if error has a value
    * <details>

        <summary> <code> Code Hint </code> </summary>

        ```js
        if let error = error {
            print(error)
            completion()
            return
        }
        ```
        </details> 

* Unwrap `data` if there is any.
    * Hint: Don't forget to call `completion()` and `return` in the `else` block.

* Create an instance of `JSONDecoder`

* Before adding the next step you will need your `Post` model object to adopt the `Codable` protocol.

* Call `decode(from:)` on your instance of the JSONDecoder. You will need to assign the return of this function to a constant named `postsDictionary`. This function takes in two arguments: a type `[String:Post].self`, and your instance of `data` that came back from the network request. This will decode the data into a [String:Post] _(a dictionary with keys being the UUID that they are stored under on the database as you will see by inspecting the json returned from the network request, and values which should be actual instances of post)_.
    * NOTE: You will also notice that this function `throws`. That means that if you call this function and it doesn't work the way it should, it will _`throw`_ an error. Functions that throw need to be marked with `try` in front of the function call. You will also need to put this call inside of a **do-catch block** and `catch` the error that might be thrown. If there is an error caught, you will want to print the error, call `completion()` and `return`. _Review the [documentation](https://docs.swift.org/swift-book/LanguageGuide/ErrorHandling.html#ID541) if you need to learn about do catch blocks._

* Call `compactMap` on this dictionary, pulling out the `Post` from each key-value pair. Assign the new array of posts to a variable named `posts`. Look at the [documentation](https://developer.apple.com/documentation/swift/array/2957701-compactmap) for `compactMap` to help you remember what it does.
    * <details>

        <summary> <code> Code Hint </code> </summary>

        `var posts = postsDictionary.compactMap({ $0.value })`
        </details> 

* Next, you'll need to sort these posts by timestamp in reverse chronological order (*the newest one is first). You can do this by calling `sort` on the `posts` array. _Look at the [documentation](https://developer.apple.com/documentation/swift/array/2296801-sort) for `sort` to help you remember what it does._
    * <details>

        <summary> <code> Code Hint </code> </summary>

        `posts.sort(by: { $0.timestamp > $1.timestamp })`
        </details> 

* Now assign the array of sorted `posts` to `self.posts` and call `completion()`.

* _Remember: If you call `return` anywhere in this function, remember to call `completion()` before returning. This way you will avoid "leaving the caller hanging" if return ever gets called before adding the fetched posts to your array._

As of iOS 9, Apple is boosting security and requiring developers to use the secure HTTPS protocol and require the server to use the proper TLS Certificate version. The Post API does support HTTPS but does not use the correct TLS Certificate version. So for this app, you will need to turn off the App Transport Security feature.

* Open your `Info.plist` file and add a key-value pair to your Info.plist. This key-value pair should be:
`App Transport Security Settings : [Allow Arbitrary Loads: YES].`

At this point, you should be able to pull the `Post` data from the API and decode it into a list of `Post` objects. Test this functionality with a Playground or by calling this function in your App Delegate and trying to print the results from the API to the console.

_Because you will always want to fetch posts whenever the table view appears, you will want to call `fetchPosts()` in `viewDidLoad()` of your `PostListViewController`. This will start the call to fetch posts and assign them to the `posts` property. (You will create this TableViewController in the next step)_

## Step Four - View Controller

### Summary

Build out a View Controller with a Table View to display each post as an individual cell. 

### Instructions

* Add a `UIViewController` as your root view controller in `Main.storyboard` and embed it in a `UINavigationController`

* Add a title to the navigation item.  You can choose what title you would like to put

* Add a `UITableView` to the view controller and set its constraints to fill the entire view controllers root view

* Make sure to add a prototype cell to the table view.  Set the cell's reuse identifier to `postCell` and set the cell's style to `Subtitle`

* Create a `PostListViewController` file as a subclass of `UIViewController` and set the class of your root view controller scene

* Drag an IBOutlet of the table view from the storyboard into the `PostListViewController`.

* Conform the `PostListViewController` to the `UITableViewDelegate` and the `UITableViewDataSource` protocols

* Assign the `PostListViewController` as the table view's delegate and data source

  * Hint: You can do this programmatically or in storyboards

* Add a `postController` property to `PostListViewController` and set it to an instance of `PostController`

* Implement the UITableViewDataSource functions using the included `postController.posts` array

* Set the `cell.textLabel` to the text, and the `cell.detailTextLabel` to the author and post date

  * Note: It may also help to temporarily add the `indexPath.row` to the `cell.detailTextLabel` to quickly determine if the posts are showing up where you expect them to be

* Add the `fetchPosts` function of the post controller to `viewDidLoad`

## Step Five - Dynamic Cell Height

### Summary

The length of the text on each `Post` is variable. Add support for dynamic resizing cells to your table view so messages are not truncated.

### Instructions

* In the `viewDidLoad()` function, set the `tableView.estimatedRowHeight` to 45
    * _45 is used because that is similar to the default value of non-customized cells.  If you have a larger sized custom cell, you can set the estimated height to that_

* Set the `tableView.rowHeight` to `UITableView.automaticDimension`

* Update the `textLabel` and `detailTextLabel` on the Post List storyboard scene to support multiple lines by setting the number of lines to 0 in the attributes inspector.

## Step Six - Refresh Control

### Summary

Add a `UIRefreshControl` to the table view to support the 'pull to refresh' gesture. Refer to the [documentation](https://developer.apple.com/documentation/uikit/uirefreshcontrol) to read more about the refresh control.

### Instructions 

* In your `PostListViewController` file, create a new variable called refreshControl and initialize it as a `UIRefreshControl`

* In `viewDidLoad`, set the table views `.refreshControl` property to the refresh control you just created in the last step.

* Create a new function called `refreshControlPulled()`. Add `@objc` before the `func` for this function.

  * `@objc` is an Objective C holdover that allows us to use some Objective C methods.  `UIRefreshControl` has an Objective C method to allows us to call a function when we drag to refresh the table view.

  * <details>

     <summary> <code> Code Hint </code> </summary>

    ```swift
    @objc func refreshControlPulled() {
    }
    ```
    </details>

* Now you need to add the @objc function we just created to the refresh control. To do this, you call the `.addTarget` method on the `refreshControl`. The target will be `self`, the selector will be `#selector(refreshControlPulled)` and the control event will be `.valueChanged`

     * <details>

        <summary> <code> Code Hint </code> </summary>

        `refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)`
        </details> 

* Inside the `refreshControlPulled` function, make a call to the `PostController`'s `fetchPost` function

* Tell `UIRefreshControl` to end refreshing when the `fetchPosts` is complete.

    * _Hint: This needs to be called on the main thread_

    * <details>

        <summary> <code> Code Hint </code> </summary>
        
        ```js
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
        ```
        </details> 

## Step Seven - Custom Reload Table View Function

### Summary

Create a function that we'll call in several places to reload the table view on the main thread after `fetchPosts` is called and the completion closure runs.

### Instructions

* Create a function called `reloadTableView`. In this function, you will want to reload the tableview. Make sure you run this on the `main` thread.

* Add this function to the closure of any `fetchPosts` function called in the `PostListViewController`

## Step Eight - Network Activity Indicator

### Summary

It is good practice to let the user know that a network request is processing. This is most commonly done using the Network Activity Indicator in the status bar.

### Instructions

* Look up the documentation for the `isNetworkActivityIndicatorVisible` property on `UIApplication` to turn on the indicator when fetching new posts

* Turn it off when the network call is complete. You should add this to the `reloadTableView` function

  * Hint: This needs to be ran on the main thread

Part One is now complete. You should be able to run the app, fetch all of the posts from the API, and have them display in the table view. Look for bugs and fix any that you may find.

### Black Diamonds

* Use a computed `.date` property, `DateComponent`s and `DateFormatter`s to display the `Post` date in the correct time zone

## Contributions

If you see a problem or a typo, please fork, make the necessary changes, and create a pull request so we can review your changes and merge them into the master repo and branch.

## Copyright

© DevMountain LLC, 2017. Unauthorized use and/or duplication of this material without express and written permission from DevMountain, LLC is strictly prohibited. Excerpts and links may be used, provided that full and clear credit is given to DevMountain with appropriate and specific direction to the original content.

<p align="center">
<img src="https://s3.amazonaws.com/devmountain/readme-logo.png" width="250">
</p>
