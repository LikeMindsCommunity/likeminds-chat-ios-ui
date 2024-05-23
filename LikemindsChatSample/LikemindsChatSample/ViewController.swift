//
//  ViewController.swift
//  LikemindsChatSample
//
//  Created by Pushpendra Singh on 13/12/23.
//

import UIKit
import LMChatUI_iOS
import LMChatCore_iOS
import LikeMindsChat

class ViewController: LMViewController {
    
    @IBOutlet weak var apiKeyField: UITextField?
    @IBOutlet weak var userIdField: UITextField?
    @IBOutlet weak var userNameField: UITextField?
    @IBOutlet weak var loginButton: UIButton?
    
    
//    open private(set) lazy var containerView: LMChatBottomMessageComposerView = {
//        let view = LMChatBottomMessageComposerView().translatesAutoresizingMaskIntoConstraints()
////        view.backgroundColor = .cyan
//        return view
//    }()
    
//    open private(set) lazy var containerView: LMChatHomeFeedChatroomView = {
//        let view = LMChatHomeFeedChatroomView().translatesAutoresizingMaskIntoConstraints()
////                view.backgroundColor = .cyan
//        return view
//    }()
    
//    open private(set) lazy var containerView: LMChatHomeFeedExploreTabView = {
//        let view = LMChatHomeFeedExploreTabView().translatesAutoresizingMaskIntoConstraints()
//        view.backgroundColor = .systemGroupedBackground
//        return view
//    }()
    
//    open private(set) lazy var containerView: LMChatHomeFeedListView = {
//        let view = LMChatHomeFeedListView().translatesAutoresizingMaskIntoConstraints()
//        view.backgroundColor = .systemGroupedBackground
//        return view
//    }()
    
//    open private(set) lazy var containerView: LMChatMessageReplyPreview = {
//        let view = LMChatMessageReplyPreview().translatesAutoresizingMaskIntoConstraints()
//        view.backgroundColor = .cyan
//        return view
//    }()
    
//    open private(set) lazy var containerView: LMBottomMessageLinkPreview = {
//        let view = LMBottomMessageLinkPreview().translatesAutoresizingMaskIntoConstraints()
//        view.backgroundColor = .cyan
//        return view
//    }()
    
    private(set) lazy var loadingView: LMChatMessageLoadingShimmerView = {
        let view = LMChatMessageLoadingShimmerView().translatesAutoresizingMaskIntoConstraints()
        view.setWidthConstraint(with: UIScreen.main.bounds.size.width)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        try? LMChatMain.shared.initiateUser(username: "DEFCON", userId: "53b0176d-246f-4954-a746-9de96a572cc6", deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "") {[weak self] success, error in
//            guard success else { return }
//            self?.moveToNextScreen()
//        }
        
        // MEDIA PREVIEW
//         var data: [LMChatMediaPreviewViewModel.DataModel] = []
//         data.append(.init(type: .video, url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"))
//         data.append(.init(type: .image, url: "https://farm2.staticflickr.com/1533/26541536141_41abe98db3_z_d.jpg"))
//         data.append(.init(type: .image, url: "https://farm3.staticflickr.com/2220/1572613671_7311098b76_z_d.jpg"))
//         data.append(.init(type: .video, url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"))
//         data.append(.init(type: .video, url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"))
//        
//         let vc = LMChatMediaPreviewViewModel.createModule(with: data, startIndex: 3)
//         navigationController?.pushViewController(vc, animated: true)
       isSavedData()
    }
    
    func moveToNextScreen() {
        self.showHideLoaderView(isShow: false, backgroundColor: .clear)
        guard let homefeedvc =
//                    try? LMExploreChatroomViewModel.createModule() else {return }
//              try? ReactionViewModel.createModule() else { return }
//              try? LMChatMessageListViewModel.createModule(withChatroomId: "88638") else { return }
//            try? LMChatAttachmentViewModel.createModule() else { return }
//            try? LMParticipantListViewModel.createModule(withChatroomId: "36689") else { return }
                try? LMChatHomeFeedViewModel.createModule() else { return }
//            try? LMChatReportViewModel.createModule(reportContentId: ("36689", nil, nil)) else { return }
//            self.addChild(homefeedvc)
//            self.view.addSubview(homefeedvc.view)
//            homefeedvc.didMove(toParent: self)
        let navigation = UINavigationController(rootViewController: homefeedvc)
        navigation.modalPresentationStyle = .overFullScreen
        self.present(navigation, animated: false)
//            self.navigationItem.leftBarButtonItem = LMBarButtonItem()
    }
    
    // MARK: setupViews
    open override func setupViews() {
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
    }
    
    @IBAction func loginAsCMButtonClicked(_ sender: UIButton) {
        apiKeyField?.text = "17ab90f3-6cba-4dd9-aeea-979a081081b7"
        userIdField?.text = "loki123"
        userNameField?.text = "Loki"
    }
    
    @IBAction func loginAsMemberButtonClicked(_ sender: UIButton) {
        apiKeyField?.text = "17ab90f3-6cba-4dd9-aeea-979a081081b7"
        userIdField?.text = "333333"
        userNameField?.text = "Push User"
    }

    @IBAction func loginButtonClicked(_ sender: UIButton) {
        guard let apiKey = apiKeyField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !apiKey.isEmpty,
              let userId = userIdField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userId.isEmpty,
              let username = userNameField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !username.isEmpty else {
            showAlert(message: "All fields are mandatory!")
            return
        }
        
        let userDefalut = UserDefaults.standard
        userDefalut.setValue(apiKey, forKey: "apiKey")
        userDefalut.setValue(userId, forKey: "userId")
        userDefalut.setValue(username, forKey: "username")
        userDefalut.synchronize()
        callInitiateApi(userId: userId, username: username, apiKey: apiKey)
    }
    
    func isSavedData() -> Bool {
        let userDefalut = UserDefaults.standard
        guard let apiKey = userDefalut.value(forKey: "apiKey") as? String,
              let userId = userDefalut.value(forKey: "userId") as? String,
              let username = userDefalut.value(forKey: "username") as? String else {
            return false
        }
        callInitiateApi(userId: userId, username: username, apiKey: apiKey)
        return true
    }
    
    func callInitiateApi(userId: String, username: String, apiKey: String) {
        LMChatMain.shared.configure(apiKey: apiKey)
        self.showHideLoaderView(isShow: true, backgroundColor: .clear)
        try? LMChatMain.shared.initiateUser(username: username, userId: userId, deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "") {[weak self] success, error in
            guard success else { return }
            self?.moveToNextScreen()
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
 
}

