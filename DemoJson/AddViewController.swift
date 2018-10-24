//
//  AddViewController.swift
//  DemoJson
//
//  Created by macbook on 10/16/18.
//  Copyright © 2018 macbook. All rights reserved.
//

import UIKit

struct Post: Codable {
    
    let userId : Int
    let title : String
    let body : String
}

class AddViewController: UIViewController {
    
    
    @IBOutlet weak var UserId: UITextField!
    @IBOutlet weak var Body: UITextField!
    @IBOutlet weak var AddTitle: UITextField!
    @IBOutlet weak var Instruction: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Instruction.isHidden = true
    }
    
    @IBAction func SaveData(_ sender: UIBarButtonItem)
    {
        if UserId.text != "" && AddTitle.text != "" && Body.text != "" && IsValidateUserid(TextUserid: UserId.text!) && (Int(UserId.text!)! <= 100 || Int(UserId.text!)! >= 1)
        {
            let mypost = Post(userId:Int(UserId.text!)!, title: AddTitle.text!, body: Body.text!)
            
            submitPost(post: mypost) { (error) in
                if let error = error
                {
                    fatalError(error.localizedDescription)
                }
            }
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: "Please Fill All Detail Properly", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func submitPost(post:Post,complition:((Error?)->Void)?)
    {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "jsonplaceholder.typicode.com"
        urlComponents.path = "/posts"
        
        guard let url = urlComponents.url else {
            fatalError("could not create url from compononts")}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let encoder = JSONEncoder()
        do{
        let jsondata = try encoder.encode(post)
            
            request.httpBody = jsondata
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
            
        }catch{
            complition?(error)
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, responce, error) in
            guard error == nil else {
                complition?(error!)
                return
            }
            
            if let strresp = String(data: data!, encoding: String.Encoding.utf8)
            {
                print(strresp)
            }
            else
            {
                print("Not readble data received")
            }
        }
        task.resume()
    }
    
    @IBAction func EditingStart(_ sender: UITextField)
    {
        Instruction.isHidden = false
        Instruction.text = "id must be between 1 to 100"
    }
    
    @IBAction func EditingEnd(_ sender: UITextField)
    {
        if IsValidateUserid(TextUserid: UserId.text!)
        {
            Instruction.isHidden = true
        }
        UserId.borderStyle = .roundedRect
        UserId.layer.borderColor = UIColor.gray.cgColor
    }
    
    @IBAction func EditingChanged(_ sender: UITextField)
    {
        if IsValidateUserid(TextUserid: UserId.text!) 
        {
            UserId.rightViewMode = .never
            UserId.clipsToBounds = true
            //UserId.layer.borderWidth = 1
            //UserId.layer.borderColor = UIColor.green.cgColor
            Instruction.isHidden = true

        }
        else
        {
            //UserId.layer.borderWidth = 1
            //UserId.layer.borderColor = UIColor.red.cgColor
            Instruction.isHidden = false
        }
    }
    
    func IsValidateUserid(TextUserid:String)->Bool
    {
        //let UserIdRegEx = "[0-9]{1,3}"
        let UserIdRegEx = "([1-9]{1,2}[0]?|100)"
        let UserTest = NSPredicate(format:"SELF MATCHES %@", UserIdRegEx)
        let result = UserTest.evaluate(with: TextUserid)
        return result
    }
}

extension AddViewController: UITextFieldDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.view.endEditing(true)
    }
}
