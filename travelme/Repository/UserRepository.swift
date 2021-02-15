//
//  UserRepository.swift
//  travelme
//
//  Created by DiepViCuong on 1/28/21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class UserRepository {
    static let sharedInstance = UserRepository()
    private let collectionPathUser = "User"
    private let collectionPathFollowing = "Following"
    private let collectionPathFollower = "Follower"
    private let collectionPathLike = "Like"
    private let collectionPathPost = "Posts"

    private let profileImagePath = "profile_image"
    private let ref = Database.database().reference()
    
    func fetchUser(withUID uid: String, completion: @escaping (User) -> ()){
        ref.child(collectionPathUser).child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else {return}
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }){ err in
            debugPrint("Failed to fetch user:", err)
        }
    }
    
    func createUser(email: String, username: String, password: String, image: UIImage?, completionBlock: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let err = error{
                print("Failed to create user:", err)
                completionBlock(err)
                return
            }
            guard let uid = authResult?.user.uid else {return}
            if let image = image{
                self.uploadUserProfileImage(image: image){ profileImageUrl in
                    self.uploadUser(withUID: uid, username: username, profileImageUrl: profileImageUrl){
                        completionBlock(nil)
                    }
                }
            }else{
                self.uploadUser(withUID: uid, username: username){
                    completionBlock(nil)
                }
            }
        }
    }
    
    func uploadUser(withUID uid: String, username: String, profileImageUrl: String? = nil, completion: @escaping (() -> ())){
        var dictionaryValues = ["username": username]
        if profileImageUrl != nil {
            dictionaryValues["profileImageUrl"] = profileImageUrl
        }
        let values = [uid: dictionaryValues]
        
        ref.child(collectionPathUser).updateChildValues(values){ (err, ref) in
            if let err = err {
                print("Failed to upload user to database:", err)
                return
            }
            completion()
        }
    }
    
    private func uploadUserProfileImage(image: UIImage, completion: @escaping (String) -> ()){
        guard let uploadData = image.jpegData(compressionQuality: 1) else {
            print("Failed to compress image")
            return}
        
        let storageRef = Storage.storage().reference().child(profileImagePath).child(NSUUID().uuidString)
        
        storageRef.putData(uploadData, metadata: nil){ (metadata, error) in
            if let err = error {
                print("Failed to upload profile image:", err)
                return
            }
            // access to download URL after upload.
              storageRef.downloadURL { (url, error) in
                if let err = error{
                    print("Failed to obtain download url for profile image:", err)
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
    
    func numberOfFollowing(withUID uid: String, completion: @escaping (Int) -> ()){
        ref.child(collectionPathFollowing).child(uid).observeSingleEvent(of: .value){ snapshot in
            if let dictionaries = snapshot.value as? [String: Any]{
                completion(dictionaries.count)
            }else{
                completion(0)
            }
            
        }
    }
    
    func numberOfFollowers(withUID uid: String, completion: @escaping (Int) -> ()) {
        ref.child(collectionPathFollower).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }
    
    func numberOfUserPosts(withUID uid: String, completion: @escaping (Int) -> ()) {
        ref.child(collectionPathPost).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }
}
