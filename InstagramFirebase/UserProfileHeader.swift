//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by haider ali on 10/10/2019.
//  Copyright © 2019 haider ali. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserProfileHeader: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blue
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        
        
        setupProfileImage()
        
    }
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            guard let url = URL(string: profileImageUrl) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let error = error {
                    print("failed to fetch user image: ", error.localizedDescription)
                    return
                }
                
                
                guard let data = data else { return }
                
                let image = UIImage(data: data)
                // need to get back onto the main UI thread
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
                
                
                
                
                //check for error
                }.resume()
        }
    }
    
    fileprivate func setupProfileImage() {
        
        
        
        
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            
            
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
           
            
            
        }) { (error) in
            print("failed to fetch user :", error.localizedDescription)
        }
        
        
        
       
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
