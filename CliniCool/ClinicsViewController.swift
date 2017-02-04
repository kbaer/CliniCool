//
//  ClinicsViewController.swift
//  CliniCool
//
//  Created by Ken Baer on 3/2/16.
//  Copyright © 2016 BaerCode. All rights reserved.
//

import Foundation
import UIKit


class ClinicsViewController : UICollectionViewController {
    
    let insets: UIEdgeInsets! = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    var clinicData: [[String:AnyObject]]?
    var screenWidth: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        clinicData = nil
        
        // load saved Clinic List array from the keychain
        if let clinicArray: [[String : AnyObject]] = KeychainWrapper.objectForKey(GlobalConstants.clinicListKey) as? [[String:AnyObject]] {
            // show it in the Console
            print("Stored Clinic Array = \(clinicArray)" as Any)
            // remove it so we can save a new one
            KeychainWrapper.removeObjectForKey(GlobalConstants.clinicListKey)
            print("Clinic List removed from Keychain")
        }
        
        self.screenWidth = self.view.frame.size.width
        
        self.readAndStoreJSON("clinicList")
        
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.screenWidth = size.width
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView!.performBatchUpdates(nil, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let clinic: [String : AnyObject] = sender as? [String:AnyObject] else {
            return
        }
        if let clinicDetailController: ClinicDetailViewController = segue.destination as? ClinicDetailViewController {
            clinicDetailController.clinic = clinic
        }
    }

    func readAndStoreJSON(_ name: String!) {
 
        let clinicList = NSMutableArray()

        // load the JSON from the file in the main bundle
        // pull out the names and ids, handle case where the id is saved as "providerId instead of "id"
        if let path = Bundle.main.path(forResource: name, ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    if let data = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String : AnyObject]] {
                        clinicData = data[0]["recommendations"] as? [Dictionary]
                        for clinic: Dictionary in clinicData! {
                            var id: AnyObject?
                            if clinic["id"] == nil{
                                id = clinic["providerId"]
                            }
                            else {
                                id = clinic["id"]
                            }
                            
                            if id != nil {
                                let clinicItem: Dictionary! =
                                    ["name" : clinic["name"]!,
                                     "id" : id as! String]
                                clinicList.add(clinicItem)
                            }
                        }
                        storeClinicInKeychain(clinicList)
                        self.collectionView?.reloadData()
                    }
                } catch {}
            } catch {}
        }
    }
    
    func storeClinicInKeychain(_ clinicList: NSArray) {
        
        if clinicList.count > 0 {
            
            KeychainWrapper.setObject(clinicList, forKey:GlobalConstants.clinicListKey)
        }
        
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            
        if clinicData == nil {
            return 0
        }
            
        return clinicData!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClinicCell", for: indexPath) as! ClinicCell
        
        if let clinic: [String : AnyObject]? = clinicData![indexPath.row] {
            cell.clinicName.text = clinic!["name"] as? String
            if let preferredState: Bool? = clinic!["preferred"] as? Bool{
                if preferredState == true{
                    cell.preferredString.text = "Is Preferred: Yes"
                }
                else {
                    cell.preferredString.text = "Is Preferred: No"
                }
            }
        }
        
        return cell

    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ShowDetails", sender: clinicData![indexPath.row])

    }

}


extension ClinicsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: screenWidth - 40.0, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 20.0
    }

}

