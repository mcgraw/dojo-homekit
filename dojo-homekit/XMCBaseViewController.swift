//
//  XMCBaseViewController.swift
//  dojo-homekit
//
//  Created by David McGraw on 2/11/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import HomeKit

class XMCBaseViewController: UITableViewController, HMHomeManagerDelegate {
    
    let homeManager = HMHomeManager()
    var activeHome: HMHome?
    var activeRoom: HMRoom?
    
    var lastSelectedIndexRow = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        homeManager.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    func updateControllerWithHome(home: HMHome) {
        if let room = home.rooms.first as HMRoom? {
            activeRoom = room
            title = room.name + " Devices"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showServicesSegue" {
            let vc = segue.destinationViewController as! XMCAccessoryViewController
            if let accessories = activeRoom?.accessories {
                vc.accessory = accessories[lastSelectedIndexRow] as HMAccessory?
            }
        }
    }
    
    // MARK: - Table Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let accessories = activeRoom?.accessories {
            return accessories.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("deviceId") as UITableViewCell?
        let accessory = activeRoom!.accessories[indexPath.row] as HMAccessory
        cell?.textLabel?.text = accessory.name
        
        // ignore the information service
        cell?.detailTextLabel?.text = "\(accessory.services.count - 1) service(s)"
        
        return (cell != nil) ? cell! : UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        lastSelectedIndexRow = indexPath.row
    }
    
    // MARK: - Home Delegate
    
    // Homes are not loaded right away. Monitor the delegate so we catch the loaded signal.
    func homeManager(manager: HMHomeManager, didAddHome home: HMHome) {
        
    }
    
    func homeManager(manager: HMHomeManager, didRemoveHome home: HMHome) {
        
    }
    
    func homeManagerDidUpdateHomes(manager: HMHomeManager) {
        if let home = homeManager.primaryHome {
            activeHome = home
            updateControllerWithHome(home)
        } else {
            initialHomeSetup()
        }
        tableView.reloadData()
    }
    
    func homeManagerDidUpdatePrimaryHome(manager: HMHomeManager) {
        
    }
    
    // MARK: - Setup
    
    // Create our primary home if it doens't exist yet
    private func initialHomeSetup() {
        homeManager.addHomeWithName("Porter Ave", completionHandler: { (home, error) in
            if error != nil {
                print("Something went wrong when attempting to create our home. \(error?.localizedDescription)")
            } else {
                if let discoveredHome = home {
                    // Add a new room to our home
                    discoveredHome.addRoomWithName("Office", completionHandler: { (room, error) in
                        if error != nil {
                            print("Something went wrong when attempting to create our room. \(error?.localizedDescription)")
                        } else {
                            self.updateControllerWithHome(discoveredHome)
                        }
                    })
                    
                    // Assign this home as our primary home
                    self.homeManager.updatePrimaryHome(discoveredHome, completionHandler: { (error) in
                        if error != nil {
                            print("Something went wrong when attempting to make this home our primary home. \(error?.localizedDescription)")
                        }
                    })
                } else {
                    print("Something went wrong when attempting to create our home")
                }
                
            }
        })
    }
}

