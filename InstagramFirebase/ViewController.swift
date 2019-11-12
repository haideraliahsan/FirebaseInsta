//
//  ViewController.swift
//  InstagramFirebase
//
//  Created by haider ali on 08/10/2019.
//  Copyright © 2019 haider ali. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhotot), for: .touchUpInside)
        return button
    }()
    @objc func handlePlusPhotot() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        if let orignalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {plusPhotoButton.setImage(orignalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        else {
            
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        dismiss(animated: true, completion: nil)
        
    }
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.characters.count ?? 0 > 0 && usernameTextField.text?.characters.count ?? 0 > 0 && passwordTextField.text?.characters.count ?? 0 > 0
        
        
        if isFormValid {
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            signUpButton.isEnabled = true
        }
        else {
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            signUpButton.isEnabled = false
        }
    }
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)

        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)

        return tf
    }()

    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    @objc func handleSignUp () {
        
        guard let email = emailTextField.text, email.characters.count > 0 else { return }
        guard let username = usernameTextField.text, username.characters.count > 0 else { return }
        guard let password = passwordTextField.text, password.characters.count > 0 else { return}
        //creating user
        Auth.auth().createUser(withEmail: email, password: password) {(user, error) in
            if let error = error {
                print("failed to create user : ", error)
                    return
            }
            print("Successfully created user ", user?.user.uid ?? "")
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            let fileName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child(fileName)
            // uploading file to the firebase storage
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if let error = error {
                    print("Failed to upload profile image: ", error )
                    return
                }
                print("Successfully Uploaded the profile Image")
                // fetching download url of photos
                storageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print("Failed to fetch download url:", error.localizedDescription)
                        return
                    }
                    guard let photoURL = url?.absoluteString else { return }
                    print("Download Url :",photoURL)
                    //saving data to database
                    guard let uid = user?.user.uid else { return }
                    let dictionaryValues = ["username": username, "profileImageUrl": photoURL]
                    let values = [uid: dictionaryValues]
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("failed to save user info in database : ", error?.localizedDescription)
                        }
                        else{
                            print("Successfully saved user info to db")
                        }
                    })
                })
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        
        
        setupInputFields()
//
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
        
        
        stackView.topAnchor.constraint(equalTo: plusPhotoButton.bottomAnchor, constant: 20).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        

        
    }


}

