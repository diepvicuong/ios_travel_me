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
    
    func fetchAllUser(includeCurrentUser: Bool, completion: @escaping ([User]) -> (), withCancel cancel: ((Error)-> ())?){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        ref.child(collectionPathUser).observeSingleEvent(of: .value, with: {snapshot in
            guard var userDictionary = snapshot.value as? [String: Any] else {return}
            
            if !includeCurrentUser{
                userDictionary.removeValue(forKey: currentUid)
            }
            let userIds = userDictionary.keys
            var users: [User] = []
            var count = 0
            
            debugPrint("userIds:", userIds)
            
            for (index, uid) in userIds.enumerated(){

                self.fetchUser(withUID: uid){ user in
                    users.append(user)
                    count += 1
                    if userIds.count == count{
                        completion(users)
                    }
                }
            }
        }){err in
            debugPrint("Failed to fetch all user:", err)
            cancel?(err)
        }
    }
    
    func createUser(email: String, username: String, password: String, phoneNumber: String?, image: UIImage?, completionBlock: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let err = error{
                print("Failed to create user:", err)
                completionBlock(err)
                return
            }
            guard let uid = authResult?.user.uid else {return}
            if let image = image{
                self.uploadUserProfileImage(image: image){ profileImageUrl in
                    self.updateUserInfo(withUID: uid, username: username, email: email, phoneNumber: phoneNumber, profileImageUrl: profileImageUrl){
                        completionBlock(nil)
                    }
                }
            }else{
                self.updateUserInfo(withUID: uid, username: username, email: email, phoneNumber: phoneNumber){
                    completionBlock(nil)
                }
            }
        }
    }
    
    func updateUserInfo(withUID uid: String, username: String, email: String? = nil, phoneNumber: String? = nil, profileImageUrl: String? = nil, completion: @escaping (() -> ())){
        var dictionaryValues = ["username": username]
        if email != nil {
            dictionaryValues["email"] = email
        }
        if phoneNumber != nil {
            dictionaryValues["phoneNumber"] = phoneNumber
        }
        if profileImageUrl != nil {
            dictionaryValues["profileImageUrl"] = profileImageUrl
        }
        
        ref.child(collectionPathUser).child(uid).updateChildValues(dictionaryValues){ (err, ref) in
            if let err = err {
                print("Failed to upload user to database:", err)
                return
            }
            completion()
        }
    }
    
    func uploadUserProfileImage(image: UIImage, completion: @escaping (String) -> ()){
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

//MARK: - Follow & unfollow
extension UserRepository{
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
    func isFollowingUser(withUID uid: String, completion: @escaping (Bool) -> (), withCancel cancel: ((Error) -> ())?){
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        ref.child(collectionPathFollowing).child(currentLoggedInUserId).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                completion(true)
            } else {
                completion(false)
            }
        }) { (err) in
            print("Failed to check if following:", err)
            cancel?(err)
        }
    }
    
    func followUser(withUID uid: String, completion: @escaping (Error?) -> ()) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        let values = [uid: 1]
        ref.child(collectionPathFollowing).child(currentLoggedInUserId).updateChildValues(values) { [weak self] (err, ref) in
            guard let strongSelf = self else {return}
            if let err = err {
                completion(err)
                return
            }
            
            let values = [currentLoggedInUserId: 1]
            strongSelf.ref.child(strongSelf.collectionPathFollower).child(uid).updateChildValues(values) { (err, ref) in
                if let err = err {
                    completion(err)
                    return
                }
                completion(nil)
            }
        }
    }
    
    func unfollowUser(withUID uid: String, completion: @escaping (Error?) -> ()) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        ref.child(collectionPathFollowing).child(currentLoggedInUserId).child(uid).removeValue {[weak self] (err, _) in
            guard let strongSelf = self else {return}
            if let err = err {
                print("Failed to remove user from following:", err)
                completion(err)
                return
            }
            
            strongSelf.ref.child(strongSelf.collectionPathFollower).child(uid).child(currentLoggedInUserId).removeValue(completionBlock: { (err, _) in
                if let err = err {
                    print("Failed to remove user from followers:", err)
                    completion(err)
                    return
                }
                completion(nil)
            })
        }
    }
}
