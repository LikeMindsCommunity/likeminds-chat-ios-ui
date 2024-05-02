//
//  LMMessageListViewController.swift
//  LMChatCore_iOS
//
//  Created by Pushpendra Singh on 18/03/24.
//

import AVFoundation
import LMChatUI_iOS
import GiphyUISDK
import UIKit

protocol LMMessageListControllerDelegate: AnyObject {
    func postMessage(message: String?,
                     filesUrls: [AttachmentMediaData]?,
                     shareLink: String?,
                     replyConversationId: String?,
                     replyChatRoomId: String?)
    func postMessageWithAttachment()
    func postMessageWithGifAttachment()
    func postMessageWithAudioAttachment(with url: URL)
}

open class LMMessageListViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var bottomMessageBoxView: LMBottomMessageComposerView = {
        let view = LMBottomMessageComposerView().translatesAutoresizingMaskIntoConstraints()
        view.delegate = self
        return view
    }()
    
    open private(set) lazy var messageListView: LMMessageListView = {
        let view = LMMessageListView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = .systemGroupedBackground
        view.delegate = self
        return view
    }()
    
    open private(set) lazy var chatroomTopicBar: LMChatroomTopicView = {
        let view = LMChatroomTopicView().translatesAutoresizingMaskIntoConstraints()
//        view.backgroundColor = .systemGroupedBackground
//        view.delegate = self
        return view
    }()
    
    public var viewModel: LMMessageListViewModel?
    weak var delegate: LMMessageListControllerDelegate?
    var linkDetectorTimer: Timer?
    var bottomTextViewContainerBottomConstraints: NSLayoutConstraint?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitleAndSubtitle(with: "Chatroom", subtitle: nil, alignment: .center)
        setupNavigationBar()
        
        viewModel?.getInitialData()
        viewModel?.syncConversation()
        
        setRightNavigationWithAction(title: nil, image: Constants.shared.images.ellipsisCircleIcon, style: .plain, target: self, action: #selector(chatroomActions))
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
    }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        self.view.addSubview(messageListView)
        self.view.addSubview(bottomMessageBoxView)
        self.view.addSubview(chatroomTopicBar)
        
        chatroomTopicBar.onTopicViewClick = {[weak self] topicId in
            print("Topic \(topicId) bar clicked")
            self?.topicBarClicked(topicId: topicId)
        }
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        bottomTextViewContainerBottomConstraints = bottomMessageBoxView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomTextViewContainerBottomConstraints?.isActive = true
                                   
        NSLayoutConstraint.activate([
            chatroomTopicBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatroomTopicBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatroomTopicBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            messageListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageListView.bottomAnchor.constraint(equalTo: bottomMessageBoxView.topAnchor),
            messageListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            bottomMessageBoxView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomMessageBoxView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc
    open override func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.bottomTextViewContainerBottomConstraints?.isActive = false
        self.bottomTextViewContainerBottomConstraints?.constant = -((frame.size.height - self.view.safeAreaInsets.bottom))
        self.bottomTextViewContainerBottomConstraints?.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    open override func keyboardWillHide(_ sender: Notification) {
        self.bottomTextViewContainerBottomConstraints?.isActive = false
        self.bottomTextViewContainerBottomConstraints?.constant = 0
        self.bottomTextViewContainerBottomConstraints?.isActive = true
        self.view.layoutIfNeeded()
    }
    
    open override func setupObservers() {
        super.setupObservers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioEnded), name: .LMChatAudioEnded, object: nil)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LMChatAudioRecordManager.shared.deleteAudioRecording()
        LMChatAudioPlayManager.shared.resetAudioPlayer()
    }
    
    @objc
    open func chatroomActions() {
        guard let actions = viewModel?.chatroomActionData?.chatroomActions else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for item in actions {
            let actionItem = UIAlertAction(title: item.title, style: UIAlertAction.Style.default) {[weak self] (UIAlertAction) in
                self?.viewModel?.performChatroomActions(action: item)
            }
            alert.addAction(actionItem)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (UIAlertAction) in
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    public func updateChatroomSubtitles() {
        setNavigationTitleAndSubtitle(with: viewModel?.chatroomViewData?.header, subtitle: "\(viewModel?.chatroomActionData?.participantCount ?? 0) participants")
        let message = "Only community managers can respond here."
        if viewModel?.chatroomViewData?.type == 7 && viewModel?.memberState?.state != 1 {
            bottomMessageBoxView.enableOrDisableMessageBox(withMessage: message, isEnable: false)
        } else {
            bottomMessageBoxView.enableOrDisableMessageBox(withMessage: message, isEnable: (viewModel?.chatroomViewData?.memberCanMessage ?? true))
        }
    }
    
    func topicBarClicked(topicId: String) {
        guard let chatroom = viewModel?.chatroomViewData else {
            return
        }
        viewModel?.fetchIntermediateConversations(chatroom: chatroom, conversationId: topicId)
    }
    
    public func memberRightsCheck() {
        let message = "Restricted to respond in this chatroom by community manager"
        if viewModel?.checkMemberRight(.respondsInChatRoom) == false {
            bottomMessageBoxView.enableOrDisableMessageBox(withMessage: message, isEnable: false)
        }
    }
    
}

extension LMMessageListViewController: LMMessageListViewModelProtocol {
    
    public func scrollToSpecificConversation(indexPath: IndexPath) {
        reloadChatMessageList()
        self.messageListView.scrollAtIndexPath(indexPath: indexPath)
    }
    
    public func reloadChatMessageList() {
        messageListView.tableSections = viewModel?.messagesList ?? []
        messageListView.currentLoggedInUserTagFormat = viewModel?.loggedInUserTagValue ?? ""
        messageListView.currentLoggedInUserReplaceTagFormat = viewModel?.loggedInUserReplaceTagValue ?? ""
        messageListView.reloadData()
        bottomMessageBoxView.inputTextView.chatroomId = viewModel?.chatroomViewData?.id ?? ""
    }
    
    public func scrollToBottom() {
        reloadChatMessageList()
        messageListView.scrollToBottom()
        bottomMessageBoxView.inputTextView.chatroomId = viewModel?.chatroomViewData?.id ?? ""
        updateChatroomSubtitles()
    }
    
    public func updateTopicBar() {
        if let topic = viewModel?.chatroomTopic {
            chatroomTopicBar.setData(.init(title: GetAttributedTextWithRoutes.getAttributedText(from: topic.answer).string, createdBy: viewModel?.chatroomViewData?.member?.name ?? "", chatroomImageUrl: viewModel?.chatroomViewData?.chatroomImageUrl ?? "", topicId: topic.id ?? ""))
        } else {
            chatroomTopicBar.setData(.init(title: viewModel?.chatroomViewData?.title ?? "", createdBy: viewModel?.chatroomViewData?.member?.name ?? "", chatroomImageUrl: viewModel?.chatroomViewData?.chatroomImageUrl ?? "", topicId: viewModel?.chatroomViewData?.id ?? ""))
        }
    }
}

extension LMMessageListViewController: LMMessageListViewDelegate {
    
    public func getMessageContextMenu(_ indexPath: IndexPath, item: LMMessageListView.ContentModel.Message) -> UIMenu {
        var actions: [UIAction] = []
        let replyAction = UIAction(title: NSLocalizedString("Reply", comment: ""),
                                   image: UIImage(systemName: "arrowshape.turn.up.backward.fill")) { [weak self] action in
            self?.contextMenuItemClicked(withType: .reply, atIndex: indexPath, message: item)
        }
        actions.append(replyAction)
        if let message = item.message, !message.isEmpty {
            let copyAction = UIAction(title: NSLocalizedString("Copy", comment: ""),
                                      image: UIImage(systemName: "doc.on.doc")) { [weak self] action in
                self?.contextMenuItemClicked(withType: .copy, atIndex: indexPath, message: item)
            }
            actions.append(copyAction)
        }
        
        if viewModel?.isAdmin() == true {
            let copyAction = UIAction(title: NSLocalizedString("Set as current topic", comment: ""),
                                      image: UIImage(systemName: "doc")) { [weak self] action in
                self?.contextMenuItemClicked(withType: .setTopic, atIndex: indexPath, message: item)
            }
            actions.append(copyAction)
        }
        
        if item.isIncoming == false, viewModel?.checkMemberRight(.respondsInChatRoom) == true {
            let editAction = UIAction(title: NSLocalizedString("Edit", comment: ""),
                                      image: UIImage(systemName: "pencil")) { [weak self] action in
                self?.contextMenuItemClicked(withType: .edit, atIndex: indexPath, message: item)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""),
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { [weak self] action in
                self?.contextMenuItemClicked(withType: .delete, atIndex: indexPath, message: item)
            }
            actions.append(editAction)
            actions.append(deleteAction)
        } else {
            let reportAction = UIAction(title: NSLocalizedString("Report message", comment: "")) { [weak self] action in
                self?.contextMenuItemClicked(withType: .report, atIndex: indexPath, message: item)
            }
            actions.append(reportAction)
        }
        
        return UIMenu(title: "", children: actions)
    }
    
    public func didReactOnMessage(reaction: String, indexPath: IndexPath) {
        let message = messageListView.tableSections[indexPath.section].data[indexPath.row]
        if reaction == "more" {
            
        } else {
            viewModel?.putConversationReaction(conversationId: message.messageId, reaction: reaction)
        }
    }
    
    public func contextMenuItemClicked(withType type: LMMessageActionType, atIndex indexPath: IndexPath, message: LMMessageListView.ContentModel.Message) {
        switch type {
        case .delete:
            viewModel?.deleteConversations(conversationIds: [message.messageId])
        case .edit:
            viewModel?.editConversation(conversationId: message.messageId)
            bottomMessageBoxView.inputTextView.setAttributedText(from: viewModel?.editChatMessage?.answer ?? "")
            break
        case .reply:
            viewModel?.replyConversation(conversationId: message.messageId)
            bottomMessageBoxView.showReplyView(withData: .init(username: message.createdBy, replyMessage: message.message, attachmentsUrls: message.attachments?.compactMap({($0.thumbnailUrl, $0.fileUrl, $0.fileType)})))
            break
        case .copy:
            viewModel?.copyConversation(conversationId: message.messageId)
            break
        case .report:
            NavigationScreen.shared.perform(.report(chatroomId: nil, conversationId: message.messageId, memberId: nil), from: self, params: nil)
        case .select:
            break
        case .setTopic:
            viewModel?.setAsCurrentTopic(conversationId: message.messageId)
        default:
            break
        }
    }

    public func didTappedOnReplyPreviewOfMessage(indexPath: IndexPath) {
        let message = messageListView.tableSections[indexPath.section].data[indexPath.row]
        guard let chatroom = viewModel?.chatroomViewData,
            let repliedId = message.replied?.first?.messageId else {
            return
        }
        
        if let mediumConversation = viewModel?.chatMessages.first(where: {$0.id == repliedId}) {
            guard let section = messageListView.tableSections.firstIndex(where: {$0.section == mediumConversation.date}),
                  let index = messageListView.tableSections[section].data.firstIndex(where: {$0.messageId == mediumConversation.id}) else { return }
            scrollToSpecificConversation(indexPath: IndexPath(row: index, section: section))
            return
        }
        
        viewModel?.fetchIntermediateConversations(chatroom: chatroom, conversationId: repliedId)
    }
    
    public func didTappedOnAttachmentOfMessage(url: String, indexPath: IndexPath) {
        guard let fileUrl = URL(string: url) else {
            return
        }
        NavigationScreen.shared.perform(.browser(url: fileUrl), from: self, params: nil)
    }
    
    public func didTappedOnGalleryOfMessage(attachmentIndex: Int, indexPath: IndexPath) {
        let message = messageListView.tableSections[indexPath.section].data[indexPath.row]
        guard let attachments = message.attachments, !attachments.isEmpty else { return }
        
        let mediaData: [LMChatMediaPreviewViewModel.DataModel.MediaModel] = attachments.compactMap {
            .init(mediaType: MediaType(rawValue: ($0.fileType ?? "")) ?? .image, thumbnailURL: $0.thumbnailUrl, mediaURL: $0.fileUrl ?? "")
        }
        
        let data: LMChatMediaPreviewViewModel.DataModel = .init(userName: message.createdBy ?? "User", senDate: formatDate(message.timestamp ?? 0), media: mediaData)
        
        NavigationScreen.shared.perform(.mediaPreview(data: data, startIndex: indexPath.row), from: self, params: nil)
    }
    
    public func didTappedOnReaction(reaction: String, indexPath: IndexPath) {
        let message = messageListView.tableSections[indexPath.section].data[indexPath.row]
        guard let conversation = viewModel?.chatMessages.first(where: {$0.id == message.messageId}),
              let reactions = conversation.reactions else { return }
        NavigationScreen.shared.perform(.reactionSheet(reactions: reactions.reversed(), selectedReaction: reaction, conversation: conversation.id, chatroomId: nil), from: self, params: nil)
    }
    
    
    public func fetchDataOnScroll(indexPath: IndexPath, direction: ScrollDirection) {
        let message = messageListView.tableSections[indexPath.section].data[indexPath.row]
        viewModel?.getMoreConversations(conversationId: message.messageId, direction: direction)
    }
    
    
    public func didTapOnCell(indexPath: IndexPath) {
    }

    // TODO: Move to Date Extension Folder
    func formatDate(_ epoch: Int, _ format: String = "dd MMM yyyy, HH:mm") -> String {
        // Convert epoch to Date
        var epoch = epoch
        
        if epoch > Int(Date().timeIntervalSince1970) {
            epoch /= 1000
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        
        // Create a DateFormatter to format the Date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.string(from: date)
    }
}

extension LMMessageListViewController: LMBottomMessageComposerDelegate {
    
    public func cancelReply() {
        viewModel?.replyChatMessage = nil
    }
    
    public func cancelLinkPreview() {
        viewModel?.currentDetectedOgTags = nil
    }
    
    public func composeMessage(message: String) {
        print("\(message)")
        if let chatMessage = viewModel?.editChatMessage {
            viewModel?.editChatMessage = nil
            viewModel?.postEditedConversation(text: message, shareLink: viewModel?.currentDetectedOgTags?.url, conversation: chatMessage)
        } else {
            delegate?.postMessage(message: message, filesUrls: nil, shareLink: viewModel?.currentDetectedOgTags?.url, replyConversationId: viewModel?.replyChatMessage?.id, replyChatRoomId: nil)
        }
        cancelReply()
        cancelLinkPreview()
    }
    
    public func composeAttachment() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alert.view.tintColor = BrandingColor.shared.buttonColor
        let camera = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { (UIAlertAction) in
//            self.presenter?.openMediaPicker(mediaType: "camera")
        }
        let cameraImage = Constants.shared.images.cameraIcon
        camera.setValue(cameraImage, forKey: "image")
        
        let photo = UIAlertAction(title: "Photo & Video", style: UIAlertAction.Style.default) { [weak self] (UIAlertAction) in
            guard let viewController =  try? LMChatAttachmentViewModel.createModule(delegate: self, chatroomId: self?.viewModel?.chatroomId) else { return }
            self?.present(viewController, animated: true)
        }
        
        let photoImage = Constants.shared.images.galleryIcon
        photo.setValue(photoImage, forKey: "image")
        
        let audio = UIAlertAction(title: "Audio", style: UIAlertAction.Style.default) { (UIAlertAction) in
            MediaPickerManager.shared.presentAudioAndDocumentPicker(viewController: self, delegate: self, fileType: .audio)
        }
        
        let audioImage = Constants.shared.images.micIcon
        audio.setValue(audioImage, forKey: "image")
        
        let document = UIAlertAction(title: "Document", style: UIAlertAction.Style.default) { (UIAlertAction) in
            MediaPickerManager.shared.presentAudioAndDocumentPicker(viewController: self, delegate: self, fileType: .pdf)
        }
        
        let documentImage = Constants.shared.images.documentsIcon
        document.setValue(documentImage, forKey: "image")
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(camera)
        alert.addAction(photo)
        alert.addAction(audio)
        alert.addAction(document)
        /*
        if let provider = dataProvider,
           provider.checkMemberRight(with: .createPolls),
           provider.currentChatRoom?.type != .directMessage {
            let microPollAction = UIAlertAction(title: "Poll", style: .default) { UIAlertAction in
                self.presenter?.openMediaPicker(mediaType: "poll")
            }
            let pollImage = UIImage(named: "microPoll")
            microPollAction.setValue(pollImage, forKey: "image")
            alert.addAction(microPollAction)
        }
        */
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    public func composeAudio() {
        if let audioURL = LMChatAudioRecordManager.shared.recordingStopped() {
            let mediaModel = MediaPickerModel(with: audioURL, type: .voice_note)
            postConversationWithAttchments(message: nil, attachments: [mediaModel])
//            delegate?.postMessageWithAudioAttachment(with: audioURL)
        }
        LMChatAudioRecordManager.shared.resetAudioParameters()
    }
    
    public func composeGif() {
        let giphy = GiphyViewController()
        giphy.mediaTypeConfig = [.gifs]
        giphy.theme = GPHTheme(type: .lightBlur)
        giphy.showConfirmationScreen = false
        giphy.rating = .ratedPG
        giphy.delegate = self
        self.present(giphy, animated: true, completion: nil)
    }
    
    public func linkDetected(_ link: String) { 
        linkDetectorTimer?.invalidate()
        linkDetectorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {[weak self] timer in
            print("detected first link: \(link)")
            self?.viewModel?.decodeUrl(url: link) {[weak self] ogTags in
                guard let ogTags else { return }
                self?.bottomMessageBoxView.linkPreviewView.isHidden = false
                self?.bottomMessageBoxView.linkPreviewView.setData(.init(title: ogTags.title, description: ogTags.description, link: ogTags.url, imageUrl: ogTags.image))
            }
        })
    }
    
    public func audioRecordingStarted() {
        LMChatAudioPlayManager.shared.stopAudio { }
        // If Any Audio is playing, stop audio and reset audio view
        messageListView.resetAudio()
        
        do {
            let canRecord = try LMChatAudioRecordManager.shared.recordAudio(audioDelegate: self)
            if canRecord {
                bottomMessageBoxView.showRecordingView()
                NotificationCenter.default.addObserver(self, selector: #selector(updateRecordDuration), name: .audioDurationUpdate, object: nil)
            } else {
                // TODO: Show Error Alert if false
            }
        } catch let error {
            // TODO: Show Error Alert
            print(error.localizedDescription)
        }
    }
    
    public func audioRecordingEnded() {
        if let url = LMChatAudioRecordManager.shared.recordingStopped() {
            print(url)
            bottomMessageBoxView.showPlayableRecordView()
        } else {
            bottomMessageBoxView.resetRecordingView()
        }
    }
    
    public func playRecording() {
        guard let url = LMChatAudioRecordManager.shared.audioURL else { return }
        LMChatAudioPlayManager.shared.startAudio(fileURL: url.absoluteString) { [weak self] progress in
            self?.bottomMessageBoxView.updateRecordTime(with: progress, isPlayback: true)
        }
    }
    
    public func stopRecording(_ onStop: (() -> Void)) {
        LMChatAudioPlayManager.shared.stopAudio(stopCallback: onStop)
    }
    
    public func deleteRecording() {
        LMChatAudioRecordManager.shared.deleteAudioRecording()
    }
    
    @objc
    open func updateRecordDuration(_ notification: Notification) {
        if let val = notification.object as? Int {
            bottomMessageBoxView.updateRecordTime(with: val)
        }
    }
}

extension LMMessageListViewController: MediaPickerDelegate {
    func filePicker(_ picker: UIViewController, didFinishPicking results: [MediaPickerModel], fileType: MediaType) {
        postConversationWithAttchments(message: nil, attachments: results)
    }
}

extension LMMessageListViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var results: [MediaPickerModel] = []
        for item in urls {
            guard let localPath = MediaPickerManager.shared.createLocalURLfromPickedAssetsUrl(url: item) else { continue }
            results.append(.init(with: localPath, type: MediaPickerManager.shared.fileTypeForDocument))
        }
        postConversationWithAttchments(message: nil, attachments: results)
    }
}

extension LMMessageListViewController: LMChatAttachmentViewDelegate {
    public func postConversationWithAttchments(message: String?, attachments: [MediaPickerModel]) {
        let attachmentMedia: [AttachmentMediaData] = attachments.compactMap { media in
            var mediaData = AttachmentMediaData.builder()
                .url(media.url)
                .fileType(media.mediaType)
                .mediaName(media.url?.lastPathComponent)
                .format(media.mediaType.rawValue)
                .image(media.photo)
        
            switch media.mediaType {
            case .video, .audio, .voice_note:
                if let url = media.url, let videoDeatil = FileUtils.getDetail(forVideoUrl: url) {
                    mediaData = mediaData.duration(videoDeatil.duration)
                        .size(Int64(videoDeatil.fileSize ?? 0))
                        .thumbnailurl(videoDeatil.thumbnailUrl)
                }
            case .pdf:
                if let url = media.url, let pdfDetail = FileUtils.getDetail(forPDFUrl: url) {
                    mediaData = mediaData.pdfPageCount(pdfDetail.pageCount)
                        .size(Int64(pdfDetail.fileSize ?? 0))
                        .thumbnailurl(pdfDetail.thumbnailUrl)
                }
            case .image, .gif:
                if let url = media.url {
                    let dimension = FileUtils.imageDimensions(with: url)
                    mediaData = mediaData.size(Int64(FileUtils.fileSizeInByte(url: media.url) ?? 0))
                        .width(dimension?.width)
                        .height(dimension?.height)
                }
            default:
                break
            }
            return mediaData.build()
        }
        
        viewModel?.postMessage(message: message, filesUrls: attachmentMedia, shareLink: nil, replyConversationId: nil, replyChatRoomId: nil)
    }
}


// MARK: Audio Recording
extension LMMessageListViewController: AVAudioRecorderDelegate { 
    @objc
    open func audioEnded(_ notification: Notification) {
        let duration: Int = (notification.object as? Int) ?? 0
        bottomMessageBoxView.resetAudioDuration(with: duration)
    }
}
