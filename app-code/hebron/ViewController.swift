//
//  ViewController.swift
//  hebron
//
//  Created by Daisuke Nakazawa on 09/01/2015.
//  Copyright (c) 2015 Daisuke Nakazawa. All rights reserved.
//
//
//  ViewController.swift
//  iBeaconDemo
//
//  Created by Fumitoshi Ogata on 2014/07/03.
//  Copyright (c) 2014年 Fumitoshi Ogata. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreBluetooth
import OpenAL
import AudioToolbox
import AVFoundation


class ViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var status: UILabel!

    @IBOutlet weak var btnClose: UIButton!
    //UUID -> NSUUID
    let proximityUUID = NSUUID(UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D")
    var region  = CLBeaconRegion()
    var manager = CLLocationManager()
    
    //Estimote Beacon IDs & positions

    //Edinburgh Version 1.1
    var beaconID = ["1340030201":1, "1340030202":2, "1340030203":3, "1340030204":4, "1340030205":5, "1340030206":6, "1340030207":7, "1340030208":8, "1340030209":9, "1340030210":10, "1340030211":11, "1340030212":12, "1340030213":13, "1340030214":14, "1340030215":15, "1340030216":16, "1340030217":17, "version":110]
    

    //Edinburgh Version 0
    //var beaconID = ["1340030217":17]
    
    //ctrlData
    //for controlling the sound files with the number (XXYY) consisted of scene (XX) and beaconID (YY)
    //track control as dictionary - N:next scene, E:empty, P00000:play bgm(trackno00+volume000), S:stop bgm, V000: volume change for bgm
    //newPOS:current position, cPOS;playing position
    
    //Brixton Version 1
    //let ctrlData = ["0001":"S", "0002":"P02020", "0003":"EV100", "0004":"P01100", "0009":"NS", "0101":"N", "0209":"N", "0301":"N", "0409":"N","0501":"N", "0609":"N","0701":"N","0801":"P03005", "0802":"P03010", "0803":"V015", "0804":"V020","0805":"V025", "0806":"V050", "0807":"N", "0808":"E", "0809":"E", "0901":"E", "0902":"E", "0903":"E", "0904":"E", "0905":"E", "0906":"E", "0908":"EP04100", "0909":"E"]

    //Edinburgh Version 1
    //var ctrlData = ["0015":"P01010", "0016":"P02040", "0017":"P03100"]
    
    //Edinburgh Version 1.1
    var ctrlData =  ["0014":"S", "0015":"P01010", "0016":"P02040", "0017":"P03100", "version":"1.1"]
    

    var newPOS = 0, cPOS = 0, pPOS = 0
    var SCENE = 0
    var ctrl = "Y"
    var ctrlrsv = 0, ctrlNrsv = 0, ctrlPrsv = 0, ctrlSrsv = 0 // ctrlrsv = 0: normal, 1: pending, 7: password-locked
    var newTRACK = "0000", cTRACK = "0000"
    var newBGplayer = 26, cBGplayer = 27
    var newBGTRACK = "00", cBGTRACK = "00"
    var volume:Float = 1.0
    
    //let audio:[OALAudioTrack] = Array(count:12, repeatedValue:OALAudioTrack()) // <- it doesn't work..
    let audio:[OALAudioTrack] = [OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack(),OALAudioTrack()] //0:system,1-25:position,26-27:bgm
    var PTresume:[Int:NSTimeInterval] = [0:0, 1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0, 8:0, 9:0, 10:0, 11:0, 12:0, 13:0, 14:0, 15:0, 16:0, 17:0, 18:0, 19:0, 20:0, 21:0, 22:0, 23:0, 24:0, 25:0] // to keep the resumed sec
    var BGresume:[String:NSTimeInterval] = ["00":0]
    
    var PTfadeoutTask = 0
    var PTfadeoutCtrler:[Int] = []
    var PTstopTask = 0
    var PTstopCtrler:[Int] = []
    var PTplayTask = 0
    var PTplayCtrler:[Int] = []
    var PTplayTrack:[String] = []
    var PTfadeinTask = 0
    var PTfadeinCtrler:[Int] = []
    var PTfadeinTrack:[String] = []
    var PTfinalTask = 0
    var PTfinalTrack:[String] = []
    

    var total = [0:0, 1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0, 8:0, 9:0, 10:0, 11:0, 12:0, 13:0, 14:0, 15:0, 16:0, 17:0, 18:0, 19:0, 20:0, 21:0, 22:0, 23:0, 24:0, 25:0]

    var i = 1, ii = 0, ttt = 0
    var t = ""
    
    let config = NSUserDefaults.standardUserDefaults()
    var passwordtoday = ""
    var alertnumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Start!!!")
        
        let reachability = AMReachability.reachabilityForInternetConnection()
        if reachability.isReachable() {
            var Url:NSURL = NSURL(string:"http://passagetellsproject.net/app/" + DataManager.sharedManager().project_name + "/beaconid.json")!
            
            var Request:NSURLRequest  = NSURLRequest(URL: Url)
            NSURLConnection.sendAsynchronousRequest(Request, queue: NSOperationQueue.mainQueue(),completionHandler: responseforbeaconid)
        } else {
            
            println ("no internet connection")
        }
        
        
//        ctrlData = DataManager.getCtrlData()
        
        //create CLBeaconRegion
        region = CLBeaconRegion(proximityUUID:proximityUUID,identifier:"EstimoteRegion")
    
        //setting deligate
        manager.delegate = self
        self.btnClose.hidden = true;

        checkAuthorizationStatus();
        
    }
        func checkAuthorizationStatus () {
                switch CLLocationManager.authorizationStatus() {
                    case .Restricted, .Denied:
                            //Device does not allowed
                            self.status.text = "Restricted/denied"
                            let alert = UIAlertView(title: "Location Service Setting", message: "The access to location services on this app is restricted/denied. Go to Settings > Privacy > Location Services to change the setting on your phone.", delegate: self, cancelButtonTitle: "OK" )
                            alertnumber = 2
                            alert.show()
                    case .NotDetermined:
                            self.status.text = "Restricted, denied or not Determined"
                            //Asking permission
                            if(UIDevice.currentDevice().systemVersion.substringToIndex(advance(UIDevice.currentDevice().systemVersion.startIndex,1)).toInt() >= 8){
                                    //iOS8 and later: call a function to request authorization
                                    self.manager.requestWhenInUseAuthorization()
                                }else{
                                    self.manager.startRangingBeaconsInRegion(self.region)
                                }
                            let alert = UIAlertView(title: "Location Service", message: "Checking the availability of Location Service on the app.", delegate: self, cancelButtonTitle: "OK" )
                            alertnumber = 3
                            alert.show()
                            checkAuthorizationStatus();
                    case .AuthorizedAlways, .AuthorizedWhenInUse:
                            //Start monitoring
                            println("Monitoring!")
                            self.status.text = "Playing " + toString(beaconID["version"]!)
                            self.btnClose.hidden = false;

                            for i=0;i<27;i++ { self.audio[i].volume = 0 }
                            self.audio[0].volume = 1
                            self.audio[0].playFileAsync(getPath("0000.mp3"), target: self, selector: "PTDidStartPlay")
                            SoundFileLoader()
                            self.manager.startRangingBeaconsInRegion(self.region)
                    default:
                            //unknown error
                            println("Unknown Error")
                            self.status.text = "Unknown Error"
                    }
            }

    
    //imprimentation of CCLocationManager deligate ---------------------------------------------->
    
    /*
    - (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
    */
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        manager.requestStateForRegion(region)
        self.status.text = "Scanning"
    }
    
    /*
    - (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
    Parameters
    */
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion!) {
        if (state == .Inside) {
            //monitoring if it's within the area
            manager.startRangingBeaconsInRegion(region)
        }
    }
    
    /*
    - (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
    */
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println("monitoringDidFailForRegion \(error)")
        self.status.text = "Error: \(error)"
    }
    
    /*
    - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
    Parameters
    manager : The location manager object that was unable to retrieve the location.
    error   : The error object containing the reason the location or heading could not be retrieved.
    */
    //connection failed
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("didFailWithError \(error)")
        self.status.text = "Error: \(error)"
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
        self.status.text = "Possible Match"
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        reset()
        self.status.text = "Reset"
    }
    
    static func  getBeacon(beacons:[AnyObject]!,beaconID:NSDictionary) -> CLBeacon?{
        var ii = -1, iii = 0
        var ttt = ""
        for var i = 0; i < beacons.count; i++ {
            var beacon = beacons[i] as! CLBeacon
            var ttt = "\(beacon.minor):\(beacon.accuracy):\(beacon.rssi):"
            if (beacon.proximity == CLProximity.Unknown) {
                ttt += "Unknown\n"
            } else if (beacon.proximity == CLProximity.Immediate) {
                ttt += "Immediate\n"
            } else if (beacon.proximity == CLProximity.Near) {
                ttt += "Near\n"
            } else if (beacon.proximity == CLProximity.Far) {
                ttt += "Far\n"
            }
            if (beacon.proximity != CLProximity.Unknown && beaconID["\(beacon.major)\(beacon.minor)"] != nil && iii == 0) {
                ii = i  // save the first one's number
                iii = 1
            }
        }
        //D/ self.beaconlist.text = t + tt;
        if (ii == -1) {
            //D/ self.colour.text = "Unknown proximity / beacons"
            return nil
        }
        var beacon = beacons[ii] as! CLBeacon
        println("beacon detected: \(beacon)")
        return beacon;
        
    }
/*
        static func  beaconcatcher(beacons:[AnyObject]!,beaconID:NSDictionary) -> String?{
        var beaconcatching = ""
        for var i = 0; i < beacons.count; i++ {
            var beacon = beacons[i] as! CLBeacon
            beaconcatching += beaconID["\(beacon.major)\(beacon.minor)"]!.description!
        }
        println("beaconcatching:?:\(beaconcatching)")
        return beaconcatching
    }
*/
    
    /*
    Delicate method reciving beacons
    - (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
    Parameters
    manager : The location manager object reporting the event.
    beacons : An array of CLBeacon objects representing the beacons currently in range. You can use the information in these objects to determine the range of each beacon and its identifying information.
    region  : The region object containing the parameters that were used to locate the beacons
    */
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
println("mark 1 ! --------------")
        if(beacons.count == 0) { reset(); return }

        var ii = -1, iii = 0
        var ttt = ""
        var tt = "minor: accuracy: rssi: proximity\n"
        //use the first one except unknown
        for i = 0; i < beacons.count; i++ {
            var beacon = beacons[i] as! CLBeacon
            var ttt = "\(beacon.minor):\(beacon.accuracy):\(beacon.rssi):"
            if (beacon.proximity == CLProximity.Unknown) {
                ttt += "Unknown\n"
            } else if (beacon.proximity == CLProximity.Immediate) {
                ttt += "Immediate\n"
            } else if (beacon.proximity == CLProximity.Near) {
                ttt += "Near\n"
            } else if (beacon.proximity == CLProximity.Far) {
                ttt += "Far\n"
            }
            if (beacon.proximity != CLProximity.Unknown && beaconID["\(beacon.major)\(beacon.minor)"] != nil && iii == 0) {
                ii = i  // save the first one's number
                t = ("\(ttt)\n") // save the first one's info
                iii = 1 // the flag that the first one is got
            }
        }
        //D/ self.beaconlist.text = t + tt;
        if (ii == -1) {
            reset()
            //D/ self.colour.text = "Unknown proximity / beacons"
            return
        }
        var beacon = beacons[ii] as! CLBeacon

        

        t = ""
        total[cPOS]!++
        /*D/ for i = 0; i < 24; ++i {
            t += "\(i):"
            t += NSString(format: "%03d", total[i]!) as String
            t += " "
        }
        self.errlog.text   = t
        */
        if beaconID["\(beacon.major)\(beacon.minor)"] == nil {
            newPOS = 0
        } else {
            newPOS = beaconID["\(beacon.major)\(beacon.minor)"]!
        }
        
        if (newPOS != cPOS && newPOS != 0) {
            newTRACK = NSString(format: "%04d", SCENE*100+newPOS) as String
            PTctrlGet()
            //wait once before scene change
            if ctrlrsv == 0 && (find(ctrl, "N") != nil || find(ctrl, "P") != nil || find(ctrl, "S") != nil || find(ctrl, "V") != nil) {
                ctrlrsv = 1
                //D/ self.colour.text = "\(cTRACK) wait for \(SCENE+1)"; print("WAIT\(ctrlrsv),")
                return
            } else if ctrlrsv == 7 { // for password lock
                return
            } else {
                ctrlrsv = 0
            }
            PTctrlP() //should be in the same func
            PTctrlS() //should be in the same func
            PTctrlV() //should be in the same func
            if find(ctrl, "E") != nil {
                //D/ self.colour.text = "\(cTRACK) stay away from \(newPOS)"; print("E,")
                pPOS = cPOS
                cPOS = newPOS
                cTRACK = newTRACK + "E"
                return
            } else {
                //pPOS = cPOS
            }
            PTctrlN()
                PTplay()
                cPOS = newPOS
                pPOS = cPOS
                cTRACK = newTRACK
                //D/ self.colour.text = "\(cTRACK) new play"
        } else {
            ctrlNrsv = 0
            //D/ self.colour.text = "\(cTRACK)"
        }
    }
    
    func PTctrlGet(){
        var ctrlString = ""
        ctrlString = DataManager.getCtrlData(newTRACK)!;
        if  ctrlString == "NULL" {
            ctrl = "Y"
        } else {
            ctrl = DataManager.getCtrlData(newTRACK)!
        }
        print("CTRL:\(newTRACK)\(ctrl)," )
    }
    func PTctrlN(){
        //if ctrl.rangeOfString("N") != nil {
        if find(ctrl, "N") != nil {
            //if ctrlNrsv != 0 {
            ++SCENE
            PTresume = [0:0, 1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0, 8:0, 9:0, 10:0, 11:0, 12:0, 13:0, 14:0, 15:0, 16:0, 17:0, 18:0, 19:0, 20:0, 21:0, 22:0, 23:0, 24:0, 25:0]
            newTRACK = NSString(format: "%04d", SCENE*100+newPOS) as String
        }
    }
    func PTplay(){
        PTresume[pPOS] = self.audio[pPOS].currentTime - 2
        print("TASK:\(PTfadeoutTask)\(PTplayTask)\(PTfadeinTask)\(PTfinalTask)\(PTstopTask),")
        PTfadeoutCtrler += [pPOS]; PTfadeoutTask += 1
        self.audio[pPOS].fadeTo(0.2, duration: 0.8, target: self, selector: "PTplayNew");print("c\(pPOS):FADE0.2,")
        PTplayCtrler += [newPOS]; PTplayTrack += [newTRACK]; PTplayTask += 1
   }
    func PTplayNew(){
        self.audio[PTfadeoutCtrler[0]].fadeTo(0, duration: 1, target: self, selector: "PTstop");print("c\(PTfadeoutCtrler[0]):FADE0,")
        PTstopCtrler += [PTfadeoutCtrler[0]]; PTstopTask += 1
        PTfadeoutCtrler.removeAtIndex(0); PTfadeoutTask -= 1
        self.audio[PTplayCtrler[0]].stop()
        self.audio[PTplayCtrler[0]].playFileAsync(getPath("\(PTplayTrack[0]).mp3"), target: self, selector: "PTfadein");print("n\(PTplayTrack[0]):PLAY,")
        PTfadeinCtrler += [PTplayCtrler[0]]; PTfadeinTrack += [PTplayTrack[0]]; PTfadeinTask += 1
        PTplayCtrler.removeAtIndex(0); PTplayTrack.removeAtIndex(0); PTplayTask -= 1
    }
    func PTstop(){
        //D/ self.colour.text = "stop"//self.audio[PTstopCtrler[0]].stop();print("c\(PTstopCtrler[0]):STOP\n")
        PTstopCtrler.removeAtIndex(0); PTstopTask -= 1
    }
    func PTfadein(){
        if PTresume[PTfadeinCtrler[0]] > 2 { self.audio[PTfadeinCtrler[0]].currentTime = PTresume[PTfadeinCtrler[0]]! }
        self.audio[PTfadeinCtrler[0]].fadeTo(1, duration: 0.8, target: self, selector: "PTDidPlay");print("n\(PTfadeinCtrler[0]):FADE1,")
        PTfinalTrack += [PTfadeinTrack[0]]; PTfinalTask += 1
        PTfadeinCtrler.removeAtIndex(0); PTfadeinTrack.removeAtIndex(0); PTfadeinTask -= 1
    }
    func PTDidPlay(){
        print("Play:\(PTfinalTrack[0]).mp3,")
        PTfinalTrack.removeAtIndex(0); PTfinalTask -= 1
    }
    
    func PTctrlP(){
        if find(ctrl,"P") != nil {
            var str = ctrl as NSString
            var loc = str.rangeOfString("P").location
            newBGTRACK = mid(str as String,start: loc+2,length: 2)
            volume = Float(mid(str as String,start: loc+4,length: 3).toInt()!) / 100;print("***\(volume)*")
            BGresume[cBGTRACK] = self.audio[cBGplayer].currentTime - 2
            if newBGTRACK != cBGTRACK {
                self.audio[cBGplayer].fadeTo(0.2, duration: 0.8, target: self, selector: "BGplayNew");print("BG\(cBGTRACK):FADE0.2,")

            } else {
                self.audio[cBGplayer].fadeTo(volume, duration: 0.8, target: self, selector: "BGDidFade");print("BG\(cBGTRACK):NO-PLAY-FADE\(volume),")
            }
        }
    }
    func BGplayNew(){
        self.audio[cBGplayer].fadeTo(0, duration: 1, target: self, selector: "BGstop");print("BG\(cBGTRACK):FADE0,")
        self.audio[newBGplayer].stop()
        self.audio[newBGplayer].playFileAsync(getPath("bg\(newBGTRACK).mp3"), target: self, selector: "BGfadein");print("BG\(newBGTRACK):PLAY,")
    }
    func BGstop(){
        self.audio[cBGplayer].stop();print("BG\(cBGTRACK):STOP#")
        if cBGplayer == 27 { cBGplayer = 26; newBGplayer = 27 }
        else { cBGplayer = 27; newBGplayer = 26 }
        cBGTRACK = newBGTRACK
    }
    func BGfadein(){
        if BGresume[newBGTRACK] > 2 { self.audio[newBGplayer].currentTime = BGresume[newBGTRACK]! }
        self.audio[newBGplayer].fadeTo(volume, duration: 0.8, target: self, selector: "BGDidPlay");print("BG\(newBGTRACK):FADE1,")
    }
    func BGDidPlay(){
        print("Play:bg\(newBGTRACK).mp3,")
    }
    func PTctrlS(){
        if find(ctrl,"S") != nil {
            BGresume[cBGTRACK] = self.audio[cBGplayer].currentTime - 2
            self.audio[cBGplayer].fadeTo(0, duration: 5, target: self, selector: "BGDidStop");print("BG\(cBGTRACK):FADE0,")
        }
    }
    func BGDidStop(){
        print("STOP:bg\(cBGTRACK).mp3,")
    }
    func PTctrlV(){
        if find(ctrl,"V") != nil {
            var str = ctrl as NSString
            var loc = str.rangeOfString("V").location
            volume = Float(mid(str as String,start: loc+2,length: 3).toInt()!) / 100
            if volume > 1 { volume = 1 }
            self.audio[cBGplayer].fadeTo(volume, duration: 1, target: self, selector: "BGDidFade");print("BG\(newBGTRACK):V\(volume),")
        }
    }
    func BGDidFade(){
        if find(ctrl,"V") != nil {
            print("Fade:bg\(newBGTRACK).mp3,")
        }
    }
    func getPath(filename : String ) -> String {

       var mp3file = DataManager.getMp3File(filename as String)// Mp3File(); // ;
       var filepath = mp3file.filePath as String
       return filepath
    }
    func SoundFileLoader () {
        for ( i = 1; i < 4; i++ ) {
            var t = NSString(format: "%04d%@", SCENE*100+i,".mp3")
            println(t)
//            var  = DataManager.sharedManager as DataManager
            var mp3file = DataManager.getMp3File(t as String)// Mp3File(); // ;
            if(mp3file != nil){
                var filepath = mp3file.filePath
                var fileManager = NSFileManager.defaultManager()
                if(fileManager.fileExistsAtPath(filepath)){ // yes
                        println("既に存在しています");
                } else {
                    println("存在していません");
                }
                println(mp3file.filePath)
                println(filepath)
                
                self.audio[i].preloadFileAsync(filepath, target: self, selector: "PTDidLoad")
                print("\(t):loaded,")
            }
        }
    }
    func PTDidLoad(){
        print("loading process done,")
    }

    func PTDidStartPlay(){
        print("Let's play!!!!!\n")
    }
    
    func reset(){
        /*D/ self.status.text   = "none"
        self.uuid.text     = "none"
        self.major.text    = "none"
        self.minor.text    = "none"
        self.accuracy.text = "none"
        self.rssi.text     = "none"
        */
    }
    
    func mid(str : String, start : Int, length : Int) -> String {
        var len: Int = count(str)
        var buf: String = ""
        var i: Int = 0
        var j: Int = 0
        if start > len {
            buf = ""
        } else {
            if length <= 0 {
                buf = ""
            } else {
                for char: Character in str {
                    i++
                    if i >= start {
                        if j < length {
                            buf = buf + String(char)
                            j++
                        }
                    }
                }
            }
        }
        return buf
    }

    func responseforbeaconid(res: NSURLResponse!, data: NSData!, error: NSError!){
        println(res.URL)
        println("yeah")

        var jsonbeaconid:NSDictionary! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary //get a data as ictionary
        if (jsonbeaconid != nil) {
            beaconID = jsonbeaconid as! Dictionary
        } else {
            println("no internet connection")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 
    @IBAction func closeButtonTouched(sender: AnyObject) {
        
        println("hogehoge")
        var WebVC : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController")
        self.navigationController!.pushViewController(WebVC as! UIViewController,animated: true)
        
        
        
    }
    
    
    
    
}