//
//  SettingsViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 2/2/23.
//

import UIKit
import Toast_Swift

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(logoutLoading), name: Notification.Name(noti.logout), object: nil)
        
        DispatchQueue.main.async {
            self.title = "Settings"
        }
        settingsTableView.register(UINib(nibName: ProfileTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier)
        settingsTableView.register(UINib(nibName: DummyTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: DummyTableViewCell.reuseIdentifier)
        settingsTableView.register(UINib(nibName: LogoutTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: LogoutTableViewCell.reuseIdentifier)
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
    }
    
    @objc
    private func logoutLoading() {
        self.view.makeToastActivity(.center)
    }
    
}

//MARK: - Tableview delegate & datasource

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            navigationController?.pushViewController(AccountViewController(), animated: true)
        case 1:
            self.view.makeToast("Dummy label pressed", position: .top)
        default: print("default case settings vc")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 7
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return "Dummy Section"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier, for: indexPath) as? ProfileTableViewCell else {return UITableViewCell()}
            Request.getAccountDetail(sessionID: AuthLogic.getSession()!) { account in
                cell.nameLabel.text = account.name
                cell.profileImageView.sd_setImage(with: URL(string: "\(Support.posterImageURL)\(account.avatar.tmdb.values.first!)"))
            }
            return cell
        case 1:
            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: DummyTableViewCell.reuseIdentifier, for: indexPath) as? DummyTableViewCell else
            {return UITableViewCell()}
            return cell
        case 2:
            guard let cell = settingsTableView.dequeueReusableCell(withIdentifier: LogoutTableViewCell.reuseIdentifier, for: indexPath) as? DummyTableViewCell else
            {return UITableViewCell()}
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 70.0
        case 1: return 50.0
        case 2: return 30.0
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0.0
        case 1: return 50.0
        case 2: return 0.0
        default: return 0
        }
    }
}
