//
//  SettingModelVC.swift
//  webapp
//
//  Created by Timeless on 03/06/2015.
//  Copyright (c) 2015 Shan, Jinyi. All rights reserved.
//

import UIKit

class SettingModelVC: UIViewController {
    let heightMin = 120
    let heightMax = 220
    let weightMin = 30
    let weightMax = 200
    let heightInit = 160
    let weightInit = 50
    
    // input values
    var maleUser: Bool = true
    var skinColour: Int = 0
    var height: Int = 160
    var weight: Int = 50
    
    @IBOutlet weak var FemaleButt: UIButton!
    @IBOutlet weak var MaleButt: UIButton!
    @IBOutlet weak var txtHeight:
    UITextField!
    @IBOutlet weak var txtWeight:
    UITextField!
    @IBOutlet weak var SkinColourSlider: UISlider!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var saveButton: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveTapped:")
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        println("saved")
        if segue.identifier == "saved" {
            
            println(segue.destinationViewController.description)
            println(segue.sourceViewController.description)
            println(segue.identifier)
            var svc = segue.destinationViewController as! MainFeaturesVC;
            svc.shirt = modelImage.image
        }
        
    }

    
    
    @IBAction func MaleTapped(sender: UIButton) {
        maleUser = true
        selectGender(sender)
        deselectGender(FemaleButt)
        modelImage.image = UIImage(named: "defaultM")
        
        
    }
    
    @IBAction func FemaleTapped(sender: UIButton) {
        maleUser = false
        selectGender(sender)
        deselectGender(MaleButt)
        modelImage.image = UIImage(named: "defaultF")
        
    }
    
    
    @IBOutlet weak var modelImage: UIImageView!
    override func viewDidAppear(animated: Bool) {
    
    }
    
    func selectGender(butt: UIButton) {
        butt.selected = true
        if butt == MaleButt {
            butt.setImage(UIImage(named: "colour1"), forState: .Selected)
        } else {
            butt.setImage(UIImage(named: "colour2"),
                forState: .Selected)
        }
    }
    
    func deselectGender(butt: UIButton) {
        butt.selected = false
        if butt == MaleButt {
            butt.setImage(UIImage(named: "black1"), forState: .Normal)
        } else {
            butt.setImage(UIImage(named: "black2"),
                forState: .Normal)
        }
    }
    
    
    @IBAction func skinColourChanged(sender: UISlider) {
        
        skinColour = Int(sender.value)
    }
    
    
    
    func saveTapped(sender: UIBarButtonItem) { // check height and weight value
        let a:Int? = txtHeight.text.toInt()
        let b:Int? = txtWeight.text.toInt()
        
        var error_msg:NSString = " "
        var invalidInput: Bool = false
        
        if a != nil && b != nil {
            height = a!
            weight = b!
            if height < heightMin || height > heightMax {
                invalidInput = true
                error_msg = "Invalid height, use default value?"
            } else if weight < weightMin || weight > weightMax {
                invalidInput = true
                error_msg = "Invalid weight, use default value?"
            }
        } else {
            invalidInput = true
            error_msg = "Input values are not all integers, use default value?"
        }
        
        if invalidInput {
            var invalidInputAlert = UIAlertController(title: "Invalid inputs", message: error_msg as String, preferredStyle: .Alert )
            invalidInputAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: processAlert))
            invalidInputAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(invalidInputAlert, animated: true, completion: nil)
        } else {
            var confirmAlert = UIAlertController(title: "Valid inputs", message: "Do you confirm your information?", preferredStyle: .Alert )
            confirmAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: processConfirmAlert))
            confirmAlert.addAction(UIAlertAction(title: "Wait a sec", style: .Cancel, handler: nil))
            self.presentViewController(confirmAlert, animated: true, completion: nil)
        }
    }
    
    func processAlert(alert: UIAlertAction!) {
        // use default values of height and weight
        height = heightInit
        weight = weightInit
        if (postToDB()) {
            self.performSegueWithIdentifier("saved", sender: self)
        } else {
            var nerworkErrorAlert = UIAlertController(title: "Network error", message: "Network error, please try again", preferredStyle: .Alert )
            nerworkErrorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(nerworkErrorAlert, animated: true, completion: nil)
        }
        // navigationController?.popViewControllerAnimated(true)
    }
    
    func processConfirmAlert(alert: UIAlertAction!) {
        if (postToDB()) {
            self.performSegueWithIdentifier("saved", sender: self)
        } else {
            var nerworkErrorAlert = UIAlertController(title: "Network error", message: "Network error, please try again", preferredStyle: .Alert )
            nerworkErrorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(nerworkErrorAlert, animated: true, completion: nil)
        }
        //navigationController?.popViewControllerAnimated(true)
    }
    
    
    func postToDB() -> Bool {
        // post user information to database
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let logname =  (prefs.valueForKey("USERNAME") as! NSString as String)
        
        //INSERT INTO userprofile VALUES 
        //('Sam2', 'Jiahao2', true, 30, 170, 65, 6,
// ARRAY['http://www.selfridges.com/en/givenchy-amerika-cuban-fit-cotton-jersey-t-shirt_242-3000831-15S73176511/?previewAttribute=Black']);
        var gender = "false"
        if (maleUser) {
            gender = "true"
        }
        var info = [gender, String(height), String(weight), String(skinColour)]
        
        
        var requestLine = ("INSERT INTO userprofile VALUES ('" + logname + "', '")
        requestLine += (logname + "', " + info[0] + ", 20, " + info[1] + ", ")
        requestLine += (info[2] + ", " + info[3] + ");\n")
        
        println(requestLine)
        
        var client:TCPClient = TCPClient(addr: "146.169.53.36", port: 1111)
        var (success,errmsg)=client.connect(timeout: 10)
        if success{
            println("Connection success!")
            var (success,errmsg)=client.send(str: requestLine)
            if success {
                println("sent success!")
                var data=client.read(1024*10)
                if let d = data {
                    if let str = NSString(bytes: d, length: d.count, encoding: NSUTF8StringEncoding) {
                        println("read success")
                        println(str)
                        if (str == "ERROR") {
                            client.close()
                            return false
                        } else {
                            return true
                        }
                        
                    }
                }
            }else{
                client.close()
                println(errmsg)
                return false
            }
        }else{
            client.close()
            println(errmsg)
            return false
        }
        return false
    }

}
