//  raceScreen.swift
//  RunApp
//
//  Created by Ricky Wang on 8/5/19.
//  Copyright © 2019 Michael Peng. All rights reserved.
//
/*
import UIKit
import Firebase
import CoreLocation
import TextFieldEffects
import GTProgressBar
import Lottie
import MBCircularProgressBar

class raceScreen: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    //TODO: LocationServices
    let locationManager = CLLocationManager()
    var startLocation:CLLocation!
    var lastLocation:CLLocation!
    var traveledDistance:Double = 0
    var goalDistance : Double = 100
    
    var name : String!
    var currentLobby : Int!
    
    //TODO: Timer
    var seconds:Int = 3
    var timer = Timer()
    var checkerTimer = Timer()
    @IBOutlet weak var countdownAnimation: AnimationView!
    //TODO: ProgressBar
    @IBOutlet weak var newProgressBar2: MBCircularProgressBarView!
    @IBOutlet weak var newProgressBar1: MBCircularProgressBarView!
    //TODO: Labels
    var spd: Float = 0.0
    @IBOutlet weak var distanceLabel: UILabel!
    var playerIndex : Int = 0
    var playerLobby : Int = 0
    var ref: DatabaseReference!
    
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //reset progress bars
        newProgressBar1.value = 0
        newProgressBar2.value = 0
        
        locationManager.requestAlwaysAuthorization()
        //Set everything up and start everything
        ref = Database.database().reference()
        //TODO: Timer
        checkerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(raceScreen.checkIn), userInfo: nil, repeats: true)
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        ref.child("RacingPlayers").child("Players").child("\(currentLobby!)").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snap) in
            guard let data = snap.value as? NSDictionary else {
                print("NO DATTAA!!!")
                return
            }
            self.name = data["Username"] as? String
        }
        
        
    }
    
    func startEverything()  {
        print("started")
        retrieveLabels()
        startAnimation()
        retrieveData()
        print("goal : \(goalDistance) playerIndex : \(playerIndex) ")
        newProgressBar1.isHidden = true
        newProgressBar2.isHidden = true
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
            newProgressBar1.isHidden = false
            newProgressBar2.isHidden = false
            locationManager.delegate = self
            //do other stuff
        }
    }
    //TODO: LocationServices
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if (location.horizontalAccuracy > 0) {
            //            var speed: CLLocationSpeed = CLLocationSpeed()
            if startLocation == nil {
                startLocation = locations.first
            } else {
                updateRivalProgressBars()
                if (traveledDistance >= goalDistance) {
                    updateSelfProgress()
                    updateRivalProgressBars()
                    locationManager.stopUpdatingLocation()
                    ref.child("RacingPlayers").child("Players").child("\(currentLobby!)").observeSingleEvent(of: .value) { (snapshot) in
                        if !snapshot.hasChild("Winner") {
                            self.ref.child("RacingPlayers").child("Players").child("\(self.currentLobby!)").updateChildValues(["Winner" : self.name!])
                            self.performSegue(withIdentifier: "toWinScreen", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "goToLoseScreen", sender: self)
                        }
                    }
                    
                    
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
    /*
    func updateSelfProgress() {
        distanceLabel.text = String(traveledDistance)
        ref.child("RacingPlayers").child("Players").child("\(currentLobby!)").child(Auth.auth().currentUser!.uid).updateChildValues([ "Distance" : traveledDistance])
    }
    */
    /*
    func updateRivalProgressBars() {
        ref.child("RacingPlayers").child("Players").child("\(currentLobby!)").observeSingleEvent(of: .value) { snapshot in
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
                
                if (uid == Auth.auth().currentUser!.uid) {
                    if (distanceRan > self.goalDistance) {
                        self.newProgressBar1.isHidden = true
                    }
                    UIView.animate(withDuration: 0.5) {
                        self.newProgressBar1.value = CGFloat(distanceRan / self.goalDistance) * 100
                    }
                    
                } else {
                    if (distanceRan > self.goalDistance) {
                        self.newProgressBar2.isHidden = true
                    }
                    UIView.animate(withDuration: 0.5) {
                        self.newProgressBar2.value = CGFloat(distanceRan / self.goalDistance) * 100
                    }
            
                }
            }
        }
    }
    */
    /*
    func startAnimation() {
        countdownAnimation.animation = Animation.named("8803-simple-countdown")
        countdownAnimation.play()
    }
    */
    // basically right now the firebase RacingPlayers section has "id" "Distance" "Lobby" "PlayerIndex". PlayerIndex is to figure out which progress bar to update. Lobby is for checking if the player's lobby is the same one as the player who's currently signed in.
    /*
    func retrieveData() {
        ref.child("RacingPlayers").child("Players").child("\(currentLobby!)").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { snapshot in
            print(snapshot.childrenCount)
            guard let value = snapshot.value as? NSDictionary else {
                print("No Data!!!!!!")
                return
            }
            
            let distance = value["SelectedDist"] as! Double
            print(distance)
            self.setData(dist: distance)
            print(self.goalDistance)
            
            //            self.goalDistance = value["SelectedDist"] as! Double
            self.playerIndex = value["PlayerIndex"] as! Int
            self.playerLobby = value["Lobby"] as! Int
        }
        print(self.goalDistance)
    }
    */
    /*
    func retrieveLabels() {
        ref.child("RacingPlayers").child("Players").child("\(currentLobby!)").observeSingleEvent(of: .value) { snapshot in
            print(snapshot.childrenCount)
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = rest.value as? NSDictionary else {
                    print("could not collect label data")
                    return
                }
                let uid = value["id"] as! String
                let username = value["Username"] as! String
                let index = value["PlayerIndex"] as! Int
                
                if (index == 0) {
                    print(uid)
                    self.Label1.text = username
                } else if (index == 1) {
                    self.Label2.text = username
                }
            }
        }
    }
 */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let destinationVC = segue.destination as! raceScreen
            destinationVC.currentLobby = currentLobby
        }
    func setData(dist : Double ) -> Void{
        goalDistance = dist
    }
    }
    

//bruvv
*/
