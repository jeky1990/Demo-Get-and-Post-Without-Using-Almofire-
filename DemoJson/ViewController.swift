//
//  ViewController.swift
//  DemoJson
//
//  Created by macbook on 10/16/18.
//  Copyright © 2018 macbook. All rights reserved.
//

import UIKit

protocol ExampleCellDelegate: class {
    func didTapButton(cell: Tblcell)
}
struct  Post1: Codable
{
    let userId : Int?
    let id : Int?
    let title : String?
    let body : String?
}

class ViewController: UIViewController {
    
    var finalarr : [Post1] = []
    var i = 0
    var index : Int = 0

    @IBOutlet weak var Tbl: UITableView!
    
    @IBOutlet weak var UserId: UITextField!
    var flag : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ChekFileExist()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Tbl.reloadData()
        UserId.text = ""
        UserId.becomeFirstResponder()

    }
    
    @IBAction func Getdata(_ sender: Any)
    {
        var posts : [Post1] = []
        
        if Int(UserId.text!)! >= 101 || Int(UserId.text!)! <= 0
        {
            let alert = UIAlertController(title: "Error", message: "Plz Enter Id between 1 to 100", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            getPosts(for: Int(UserId.text!)!) { (result) -> Void? in
                switch result {
                case.success(let post):
                    posts = post
                    DispatchQueue.main.async {
                        self.CheckIfidAlreadyExists()
                        if self.i == self.finalarr.count
                        {
                            self.finalarr.append(contentsOf: posts)
                            
                            self.SaveDataLocally(posts: self.finalarr)
                            
                            self.Tbl.reloadData()
                            
                            self.i = 0
                        }
                        
                    }
                case .failure(let Error):
                    print("Error:\(Error.localizedDescription)")
                }
                return nil
            }
        }
    }
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    func getPosts(for id:Int,completion:@escaping ((Result<[Post1]>)->Void?))
    {
        var urlcComponents = URLComponents()
        urlcComponents.scheme = "https"
        urlcComponents.host = "jsonplaceholder.typicode.com"
        urlcComponents.path = "/posts"
        
        let useriditem = URLQueryItem(name: "id", value: "\(id)")
        urlcComponents.queryItems = [useriditem]
        
        guard let url = urlcComponents.url else {
            fatalError("Could not Create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil
            {
                if let jsondata = data
                {
                    let decoder = JSONDecoder()
                    do{
                        let posts = try decoder.decode([Post1].self, from: jsondata)
                        completion(.success(posts))
                        
                        
                    }catch{}
                }
            }
        }
        task.resume()
        
    }
    
    func GetDocumentsURL() -> URL
    {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            return url
        } else
        {
            fatalError("Not Retrive any URl")
        }
    }
    
    func SaveDataLocally(posts:[Post1])
    {
        let url = GetDocumentsURL().appendingPathComponent("posts.json")
        let encode = JSONEncoder()
        
        do{
            let data = try encode.encode(posts)
            
            try data.write(to: url, options: [])
            
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    func GetdatafromLocallyStorage() -> [Post1]
    {
        let url = GetDocumentsURL().appendingPathComponent("posts.json")
        let decode = JSONDecoder()
        
        do
        {
            let data = try Data(contentsOf: url, options: [])
            finalarr = try decode.decode([Post1].self, from: data)
            
            return finalarr
            
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    @IBAction func AddButton(_ sender: Any)
    {
        let nav =  self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
       
        self.navigationController?.pushViewController(nav, animated: true)
        
    }
    
    func ChekFileExist()
    {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let finalURL = url?.appendingPathComponent("posts.json")
        
        if !FileManager.default.fileExists(atPath: finalURL!.path)
        {
            let created = true
            if created
            {
                SaveDataLocally(posts: finalarr)
                print("File Added Successfully")
            }
        }
        else
        {
            print("file alredy Exits")
        }
    }
    
    func CheckIfidAlreadyExists()
    {
        for item in finalarr
        {
            let id = Int(UserId.text!)
            let id1 = item.id
            
            if id == id1
            {
                let alert = UIAlertController(title: "Error", message: "Id Already Added", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                break
            }
            i = i+1
        }
    }
}

extension ViewController:UITableViewDataSource,ExampleCellDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return GetdatafromLocallyStorage().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Tblcell
        
        let dic = GetdatafromLocallyStorage()[indexPath.row]
        
        let id = dic.id
        
        cell.id.text = String(id!)
        cell.Title.text = dic.title
        
        cell.cellDelegate = self

        cell.Click.addTarget(self, action: #selector(didTapButton(cell:)), for: .touchUpInside)
    
        return cell
    }
    
    @objc func didTapButton(cell: Tblcell)
    {
        if let indexPath = Tbl.indexPath(for: cell)
        {
            print(indexPath.row)
            if cell.Cancel.isHidden == false
            {
                cell.Cancel.isHidden = true
            }
            else if cell.Cancel.isHidden == true && cell.LikeLeftSide.constant == 10
            {
                cell.LikeLeftSide.constant = -32
            }
            else if cell.LikeLeftSide.constant == -32 && cell.like.isHidden == false
            {
                cell.like.isHidden = true
            }
            else if cell.like.isHidden == true && cell.commentLeftSide.constant == 10
            {
                cell.commentLeftSide.constant = -36
            }
            else if cell.commentLeftSide.constant == -36 && cell.comment.isHidden == false
            {
                cell.comment.isHidden = true
            }
            else if cell.like.isHidden == true && cell.comment.isHidden == true && cell.Cancel.isHidden == true
            {
                cell.Cancel.isHidden = false
                cell.LikeLeftSide.constant = 10
                cell.like.isHidden = false
                cell.commentLeftSide.constant = 10
                cell.comment.isHidden = false
            }
        }
    }
}

extension ViewController:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let IndexArray = GetdatafromLocallyStorage()[indexPath.row]
        
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        nav.dataArray = [IndexArray]
       
        self.navigationController?.pushViewController(nav, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        var DeleteArry = GetdatafromLocallyStorage()
        DeleteArry.remove(at: indexPath.row)
        finalarr = DeleteArry
        SaveDataLocally(posts: finalarr)
        Tbl.reloadData()
    }
}

class Tblcell  : UITableViewCell
{
    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var Click: UIButton!
    @IBOutlet weak var Cancel: UIButton!
    @IBOutlet weak var comment: UIButton!
    @IBOutlet weak var like: UIButton!
    @IBOutlet weak var commentLeftSide: NSLayoutConstraint!
    @IBOutlet weak var LikeLeftSide: NSLayoutConstraint!
    
    weak var cellDelegate: ExampleCellDelegate?
    
    @IBAction func btnTapped(_ sender: UIButton) {
        cellDelegate?.didTapButton(cell: self)
    }
    
}


