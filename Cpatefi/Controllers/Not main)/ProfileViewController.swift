//
//  ProfileViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import UIKit
import SDWebImage
class ProfileViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
  
    // MARK: - Private Properties
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.isHidden =  true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var models = [String]()
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        fetchProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private Methods
    private func fetchProfile(){
        print("Full Name:")
        APICaller.shared.getCurrentUserProfile{[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    self?.updateUI(with: model)
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.failedToGetProfile()
                }
            }
        }
    }
    
    private func createTableHeader( with string: String?){
        guard let urlString = string, let url = URL(string: urlString) else { return }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width / 1.5))
        let imageSize : CGFloat = headerView.height/2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize/2
        imageView.contentMode = .scaleAspectFill
        imageView.sd_setImage(with: url,completed: nil)
        tableView.tableHeaderView = headerView
    }
    
    private func updateUI(with model : UserProfile){
        tableView.isHidden = false
        models.append("Name: \(model.display_name)")
        models.append("Email: \(model.email)")
        models.append("ID: \(model.id)")
        models.append("Plan: \(model.product)")
        createTableHeader(with: model.images.first?.url)
        tableView.reloadData()
    }
    private func failedToGetProfile(){
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile"
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
    
    // MARK: - Extension Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
     
        cell.selectionStyle = .none
        return cell
    }
}
