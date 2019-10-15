//  raceScreen.swift
//  RunApp
//
//  Created by Ricky Wang on 8/5/19.
//  Copyright © 2019 Michael Peng. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import TextFieldEffects
import GTProgressBar
import Lottie

class raceScreen: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    //TODO: LocationServices
    let locationManager = CLLocationManager()
    var startLocation:CLLocation!
    var lastLocation:CLLocation!
    var traveledDistance:Double = 0
    var goalDistance : Double = 100
    
    @IBOutlet weak var PlayerIndex: UILabel!
    //TODO: Timer
    var seconds:Int = 3
    var timer = Timer()
    var checkerTimer = Timer()
    @IBOutlet weak var countdownAnimation: AnimationView!
    //TODO: ProgressBar
    @IBOutlet weak var progressBar1: GTProgressBar!
    @IBOutlet weak var progressBar2: GTProgressBar!
    @IBOutlet weak var progressBar3: GTProgressBar!
    @IBOutlet weak var progressBar4: GTProgressBar!
    //TODO: Labels
    var spd: Float = 0.0
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    var playerIndex : Int = 0
    var playerLobby : Int = 0
    var ref: DatabaseReference!
    
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Label3: UILabel!
    @IBOutlet weak var Label4: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("entered race screen")
        locationManager.requestAlwaysAuthorization()
        //Set everything up and start everything
        ref = Database.database().reference()
        //TODO: Timer
        view.setGradientBackground(colorOne: Colors.veryDarkGrey, colorTwo: Colors.lightGrey, property: "none")
        
        checkerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(raceScreen.checkIn), userInfo: nil, repeats: true)
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        
        
    }
    
    func startEverything()  {
        retrieveLabels()
        startAnimation()
        retrieveData()
        progressBar1.isHidden = true
        progressBar2.isHidden = true
        progressBar3.isHidden = true
        progressBar4.isHidden = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(raceScreen.timerCounter), userInfo: nil, repeats: true)
        //TODO: ProgressBar
        
        //TODO: Location Services
    }
    
    
    @objc func checkIn() {
        ref.child("RacingPlayers").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            guard let value = snapshot.value as? NSDictionary else {
                print("No Data!!!")
                return
            }
            let allIn = value["EveryoneIn"] as! Bool
            
            if allIn {
                self.checkerTimer.invalidate()
                self.startEverything()
            }
            
        }) { (error) in
            print("error:\(error.localizedDescription)")
        }
    }
    
    
    //TODO: Timer
    @objc func timerCounter() {
        seconds = seconds - 1
        if (seconds == 0) {
            timer.invalidate()
            progressBar1.isHidden = false
            progressBar2.isHidden = false
            progressBar3.isHidden = false
            progressBar4.isHidden = false
            
            locationManager.delegate = self
            //do other stuff
        }
    }
    //TODO: LocationServices
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if (location.horizontalAccuracy > 0) {
            var speed: CLLocationSpeed = CLLocationSpeed()
            if startLocation == nil {
                startLocation = locations.first
            } else {
                updateRivalProgressBars()
                if (traveledDistance >= goalDistance) {
                    updateSelfProgress()
                    updateRivalProgressBars()
                    locationManager.stopUpdatingLocation()
                    performSegue(withIdentifier: "toWinScreen", sender: self)
                }
                let lastLocation = locations.last as! CLLocation
                if (startLocation.distance(from: lastLocation) > 4) {
                    updateSelfProgress()
                    let distance = startLocation.distance(from: lastLocation)
                    startLocation = lastLocation
                    traveledDistance += distance
                }
            }
        }
    }
    //TODO: Labels
    func updateSelfProgress() {
        speedLabel.text = String(spd)
        distanceLabel.text = String(traveledDistance)
        self.ref.child("RacingPlayers").child("Players").child(Auth.auth().currentUser!.uid).updateChildValues([ "Distance" : traveledDistance])
    }
    func updateRivalProgressBars() {
        ref.child("RacingPlayers").child("Players").observeSingleEvent(of: .value) { snapshot in
            print(snapshot.childrenCount)
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = rest.value as? NSDictionary else {
                    print("No Data!!!")
                    return
                }
                let lobbyNum = value["Lobby"] as! Int
                let uid = value["id"] as! String
                let username = value["Username"] as! String
                let index = value["PlayerIndex"] as! Int
                let distanceRan = value["Distance"] as! Double
                
                if (index == 0) {
                    if (distanceRan > self.goalDistance) {
                        self.progressBar1.isHidden = true;
                    }
                    self.progressBar1.progress = CGFloat(distanceRan / self.goalDistance)
                    
                } else if (index == 1) {
                    if (distanceRan > self.goalDistance) {
                        self.progressBar2.isHidden = true;
                    }
                    self.progressBar2.progress = CGFloat(distanceRan / self.goalDistance)
                } else if (index == 2) {
                    if (distanceRan > self.goalDistance) {
                        self.progressBar3.isHidden = true;
                    }
                    self.progressBar3.progress = CGFloat(distanceRan / self.goalDistance)
                } else {
                    if (distanceRan > self.goalDistance) {
                        self.progressBar3.isHidden = true;
                    }
                    self.progressBar4.progress = CGFloat(distanceRan / self.goalDistance)
                }
            }
        }
    }
    func startAnimation() {
        countdownAnimation.animation = Animation.named("8803-simple-countdown")
        countdownAnimation.play()
    }
    
    // basically right now the firebase RacingPlayers section has "id" "Distance" "Lobby" "PlayerIndex". PlayerIndex is to figure out which progress bar to update. Lobby is for checking if the player's lobby is the same one as the player who's currently signed in.
    
    func retrieveData() {
        ref.child("RacingPlayers").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { snapshot in
            print(snapshot.childrenCount)
            guard let value = snapshot.value as? NSDictionary else {
                print("No Data!!!!!!")
                return
            }
            self.playerIndex = value["PlayerIndex"] as! Int
            self.PlayerIndex.text = String(self.playerIndex)
            self.playerLobby = value["Lobby"] as! Int
        }
    }
    func retrieveLabels() {
        
        ref.child("RacingPlayers").child("Players").observeSingleEvent(of: .value) { snapshot in
            print(snapshot.childrenCount)
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = rest.value as? NSDictionary else {
                    print("could not collect label data")
                    return
                }
                let uid = value["id"] as! String
//                let username = value["Username"] as! String
                let username = "disregard for now"
                let index = value["PlayerIndex"] as! Int
                
                if (index == 0) {
                    print(uid)
                    self.Label1.text = username
                } else if (index == 1) {
                    self.Label2.text = username
                } else if (index == 2) {
                    self.Label3.text = username
                } else {
                    self.Label4.text = username
                }
            }
        }
    }
}
//bruvv
