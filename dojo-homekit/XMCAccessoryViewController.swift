//
//  XMCAccessoryViewController.swift
//  dojo-homekit
//
//  Created by David McGraw on 2/11/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import HomeKit

class XMCAccessoryViewController: UITableViewController, HMAccessoryDelegate {
    
    var accessory: HMAccessory?
    var data = [HMService]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for service in accessory!.services {
            if service.serviceType == HMServiceTypeLightbulb {
                data.append(service as HMService)
            }
        }
        
        accessory?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Table Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let loaded = accessory {
            return data.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("serviceId") as UITableViewCell
        let service = data[indexPath.row] as HMService
        
        for item in service.characteristics {
            let characteristic = item as HMCharacteristic
            println("value \(characteristic.value) : \(characteristic.metadata)")
            
            let metadata = characteristic.metadata as HMCharacteristicMetadata
            if metadata.format == HMCharacteristicMetadataFormatBool {
                if characteristic.value as Bool == true {
                    cell.detailTextLabel?.text = "ON"
                } else {
                    cell.detailTextLabel?.text = "OFF"
                }
                
                characteristic.enableNotification(true, completionHandler: { (error) -> Void in
                    if error != nil {
                        println("Something went wrong when enabling notification for a chracteristic. \(error.localizedDescription)")
                    }
                })
                
            }
            else if metadata.format == HMCharacteristicMetadataFormatString {
                cell.textLabel?.text = characteristic.value as? String
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let service = data[indexPath.row] as HMService
        let characteristic = service.characteristics[0] as HMCharacteristic
        let toggleState = (characteristic.value as Bool) ? false : true
        characteristic.writeValue(NSNumber(bool: toggleState), completionHandler: { (error) -> Void in
            if error != nil {
                println("Something went wrong when attempting to update the service. \(error.localizedDescription)")
            }
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Accessory Delegate
    
    func accessory(accessory: HMAccessory!, service: HMService!, didUpdateValueForCharacteristic characteristic: HMCharacteristic!) {
        println("Accessory characteristic has changed! \(characteristic.value)")
        tableView.reloadData()
    }
}
