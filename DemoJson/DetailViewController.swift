//
//  DetailViewController.swift
//  DemoJson
//
//  Created by macbook on 10/16/18.
//  Copyright © 2018 macbook. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var Uid: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var Title1: UILabel!
    @IBOutlet weak var Body: UILabel!
    
    
    var dataArray : [Post1] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataArray)
        
        Uid.text = String(dataArray[0].userId!)
        id.text = String(dataArray[0].id!)
        Title1.text = dataArray[0].title
        Body.text = dataArray[0].body
        
        
    }
    @IBAction func AddButton(_ sender: Any)
    {
        let nav =  self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        
        self.navigationController?.pushViewController(nav, animated: true)
        
    }
    
    @IBAction func Back(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}
