//
//  WinScreen.swift
//  RunApp
//
//  Created by Gavin on 10/21/19.
//  Copyright © 2019 Michael Peng. All rights reserved.
//

import UIKit
import Lottie
import Firebase

class LoseScreen: UIViewController {
    var ref: DatabaseReference!
    var phoneNum = ""
    @IBOutlet weak var msgButton: UIButton!
    @IBOutlet weak var mmButton: UIButton!
    var currentLobby : Int!
    @IBOutlet var runningFlash: AnimationView!
    @IBOutlet weak var time: UILabel!
    var dist : Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        startAnimation()
        ref = Database.database().reference()
        msgButton.layer.cornerRadius = msgButton.frame.height / 2
        msgButton.layer.shadowColor = UIColor.black.cgColor
        msgButton.layer.shadowRadius = 3;
        msgButton.layer.shadowOpacity = 0.5;
        msgButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        mmButton.layer.cornerRadius = msgButton.frame.height / 2
        mmButton.layer.shadowColor = UIColor.black.cgColor
        mmButton.layer.shadowRadius = 3;
        mmButton.layer.shadowOpacity = 0.5;
        mmButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
            self.ref.child("PlayerStats").child(Auth.auth().currentUser!.uid).child("Previous").childByAutoId().updateChildValues(["dist":dist, "won": false, "date": "yote"])
    }
    
    
    func startAnimation() {
        runningFlash.animation = Animation.named("runningFlash")
        runningFlash.loopMode = .loop
        runningFlash.play()
    }
    @IBAction func goToMessage(_ sender: Any) {
        retrieveData()
    }
            func retrieveData() {
                    ref.child("RacingPlayers").child("Players").child("\(currentLobby!)").observeSingleEvent(of: .value) { snapshot in
                        print(snapshot.childrenCount)
                        for rest in snapshot.children.allObjects as! [DataSnapshot] {
                            guard let value = rest.value as? NSDictionary else {
                                print("could not collect label data")
                                return
                            }
                            let uid = value["id"] as! String
                            if (uid != Auth.auth().currentUser!.uid) {
                                print("uid: " + uid)
                                self.ref.child("PlayerStats").child(uid).observeSingleEvent(of: .value) { snapshot in
                                    guard let value = snapshot.value as? NSDictionary else {
                                        print("No Data!!!!!!")
                                        return
                                    }
                                    
                                     let phoneNum = value["Phone"] as! String
                                    print("phonenum: " + phoneNum)
                                     let instagramHooks = "sms://1" + phoneNum
                                    //let instagramHooks = "sms://1" + phoneNum
                                     let instagramUrl = NSURL(string: instagramHooks)
                                     if UIApplication.shared.canOpenURL(instagramUrl! as URL)
                                     {
                                         UIApplication.shared.openURL(instagramUrl! as URL)

                                      } else {
                                         //redirect to safari because the user doesn't have Instagram
                                         UIApplication.shared.openURL(NSURL(string: "http://instagram.com/")! as URL)
                                     }
                                    
                                    //            self.goalDistance = value["SelectedDist"] as! Double
                                }
                            }
                        
                        }
                    }
            }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
