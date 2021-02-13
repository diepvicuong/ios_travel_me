//
//   TripRepository.swift
//  travelme
//
//  Created by DiepViCuong on 1/27/21.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class PostRepository{
    static let sharedInstance = PostRepository()
    
    private let postRootPath = "Posts"
    private let postImagePath = "post_image"
    private let ref = Database.database().reference()
    
    func createPost(withImage image: UIImage?, caption: String, lat: Double = 0, lon: Double = 0, completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let userPostRef = ref.child(postRootPath).child(uid).childByAutoId()
        
        guard let postId = userPostRef.key else {return}
        
        self.uploadPostImage(image: image){ imageUrl in
            let values =
                ["imageUrl": imageUrl,
                 "caption": caption,
                 "createDate": Date().timeIntervalSince1970,
                 "id": postId,
                 "lat": lat,
                 "lon": lon] as [String: Any]
            
            userPostRef.updateChildValues(values){ (err, ref) in
                if let err = err {
                    debugPrint("Faild to create post:", err)
                    completion(err)
                    return
                }
            }
            completion(nil)
        }
    }
    
    func fetchPost(withUID uid: String, postId: String, completion: @escaping (Post) -> (), withCancel cancel:((Error)-> ())? ){
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child(postRootPath).child(uid).child(postId)
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            guard let postDictionary = snapshot.value as? [String: Any] else {
                return
            }
            UserRepository.sharedInstance.fetchUser(withUID: uid, completion: {user in
                var post = Post(user: user, dictionary: postDictionary)
                post.id = postId
                completion(post)
            })
        }, withCancel: {err in
            debugPrint("Failed to fetch post:", err)
            cancel?(err)
        })
    }
    
    func fetchAllPost(withUID uid: String, completion: @escaping ([Post]) -> (), withCancel cancel: ((Error) -> ())?){
        let childRef = ref.child(postRootPath).child(uid)
        
        debugPrint("Database reference:", ref)
        childRef.observeSingleEvent(of: .value, with: {(snapshot) in
            debugPrint("Snapshot:", snapshot)
            guard let dictionaries = snapshot.value as? [String: Any] else{
                completion([])
                return
            }
            var posts = [Post]()
            
//            debugPrint("Count:", dictionaries.count)
            dictionaries.forEach({ (postId, value) in
                self.fetchPost(withUID: uid, postId: postId, completion: {post in
//                    debugPrint("post:", post.caption)
                    posts.append(post)
                    if posts.count == dictionaries.count{
                        completion(posts)
                    }

                }, withCancel: {err in
                    debugPrint("Failed to fetch all posts:", err)
                    cancel?(err)
                })
            })
        })
    }
    
    func fetchFollowingUserPost(completion: @escaping ([Post]) -> (), withCancel cancel: ((Error) -> ())?) {
        let childRef = ref.child(postRootPath)
        
        debugPrint("Database reference:", childRef)
        childRef.observeSingleEvent(of: .value, with: {(snapshot) in
//            debugPrint("Snapshot:", snapshot)
            guard let userInDictionary = snapshot.value as? [String: Any] else{
                completion([])
                return
            }
            var allPost = [Post]()
            var numOfUser = 0
            
            userInDictionary.forEach({ (uid, value) in
                self.fetchAllPost(withUID: uid, completion: {posts in
                    allPost.append(contentsOf: posts)
                    numOfUser += 1
                    if userInDictionary.count == numOfUser {
                        completion(allPost)
                    }
                }, withCancel: {err in
                    debugPrint("Failed to fetch all posts:", err)
                    cancel?(err)
                })
            })
        })
    }
    
    
    func uploadPostImage(image: UIImage?, completion: @escaping (String) -> ()){
        guard let image = image else{
            completion("")
            return
        }
        guard let uploadData = image.jpegData(compressionQuality: 1) else {
            print("Failed to compress image")
            return}
        
        let storageRef = Storage.storage().reference().child(postImagePath).child(NSUUID().uuidString)
        
        storageRef.putData(uploadData, metadata: nil){ (metadata, error) in
            if let err = error {
                print("Failed to upload post image:", err)
                return
            }
            // access to download URL after upload.
              storageRef.downloadURL { (url, error) in
                if let err = error{
                    print("Failed to obtain download url for post image:", err)
                    return
                }
                guard let downloadURL = url else {
                    print("downloadURL is nil")
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
    }
    
    func countPosts(withUID uid: String, completion: @escaping (Int) -> ()){
        let childRef = ref.child(postRootPath).child(uid)
        
        childRef.observeSingleEvent(of: .value){ snapShot in
            guard let dictionaries = snapShot.value as? [String: Any] else{
                completion(0)
                return
            }
            completion(dictionaries.count)
        }
    }
}
