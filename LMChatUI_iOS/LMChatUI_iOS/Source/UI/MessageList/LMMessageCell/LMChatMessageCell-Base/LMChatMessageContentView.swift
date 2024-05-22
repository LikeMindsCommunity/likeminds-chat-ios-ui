//
//  LMChatMessageContentView.swift
//  LMChatCore_iOS
//
//  Created by Pushpendra Singh on 22/03/24.
//

import Foundation
import Kingfisher

public protocol LMChatMessageContentViewDelegate: AnyObject {
    func clickedOnReaction(_ reaction: String)
    func clickedOnAttachment(_ url: String)
    func didTapOnProfileLink(route: String)
    func didTapOnReplyPreview()
}

extension LMChatMessageContentViewDelegate {
    public func clickedOnReaction(_ reaction: String) {}
    public func clickedOnAttachment(_ url: String) {}
    func didTapOnProfileLink(route: String) {}
}

@IBDesignable
open class LMChatMessageContentView: LMView {

    open private(set) lazy var bubbleView: LMChatMessageBubbleView = {
        return LMUIComponents.shared
            .messageBubbleView
            .init()
            .translatesAutoresizingMaskIntoConstraints()
    }()
    
    open private(set) lazy var chatProfileImageContainerStackView: LMStackView = {
        let view = LMStackView().translatesAutoresizingMaskIntoConstraints()
        view.axis = .horizontal
        view.alignment = .bottom
        view.spacing = 10
        view.addArrangedSubview(chatProfileImageView)
        return view
    }()
    
    open private(set) lazy var chatProfileImageView: LMChatProfileView = {
        let image = LMUIComponents.shared.senderProfileView.init().translatesAutoresizingMaskIntoConstraints()
        image.isUserInteractionEnabled = true
        return image
    }()
    
    open private(set) lazy var reactionsView: LMChatMessageReactionsView = {
        let view = LMUIComponents.shared.messageReactionView.init().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var reactionContainerStackView: LMStackView = {
        let view = LMStackView().translatesAutoresizingMaskIntoConstraints()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 0
        view.addArrangedSubview(reactionsView)
        return view
    }()

    open private(set) lazy var replyMessageView: LMChatMessageReplyPreview = {
        let view = LMUIComponents.shared.messageReplyView.init().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    var textLabel: LMTextView = {
        let label =  LMTextView()
            .translatesAutoresizingMaskIntoConstraints()
        label.isScrollEnabled = false
        label.font = Appearance.shared.fonts.textFont1
        label.backgroundColor = .clear
        label.textColor = .black
        label.textAlignment = .left
        label.isEditable = false
        label.textContainerInset = UIEdgeInsets(top: 4, left: 5, bottom: 0, right: 0)
        label.text = ""
        return label
    }()
    
    open private(set) lazy var usernameLabel: LMLabel = {
        let label =  LMLabel()
            .translatesAutoresizingMaskIntoConstraints()
        label.numberOfLines = 1
        label.font = Appearance.shared.fonts.headingLabel
        label.textColor = Appearance.shared.colors.red
        label.paddingLeft = 2
        label.paddingTop = 2
        label.paddingBottom = 2
        label.text = ""
        label.isUserInteractionEnabled = true
        return label
    }()
    
    open private(set) lazy var cancelRetryContainerStackView: LMStackView = {
        let view = LMStackView().translatesAutoresizingMaskIntoConstraints()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 0
        view.addArrangedSubview(loaderView)
        view.addArrangedSubview(retryView)
        return view
    }()
    
    open private(set) lazy var loaderView: LMAttachmentLoaderView = {
        let view = LMUIComponents.shared.attachmentLoaderView.init().translatesAutoresizingMaskIntoConstraints()
        view.cornerRadius(with: 24)
        view.isHidden = true
        return view
    }()
    
    open private(set) lazy var retryView: LMChatAttachmentUploadRetryView = {
        let view = LMUIComponents.shared.attachmentRetryView.init().translatesAutoresizingMaskIntoConstraints()
        view.isHidden = true
        return view
    }()
    
    var bubbleLeadingConstraint: NSLayoutConstraint?
    var bubbleTrailingConstraint: NSLayoutConstraint?
    
    var outgoingbubbleLeadingConstraint: NSLayoutConstraint?
    var outgoingbubbleTrailingConstraint: NSLayoutConstraint?
    
    var replyViewWidthConstraint: NSLayoutConstraint?
    
    weak var delegate: LMChatMessageContentViewDelegate?
    var dataView: LMChatMessageCell.ContentModel?
    
    @objc func didTapOnProfileLink(_ gesture: UITapGestureRecognizer) {
        delegate?.didTapOnProfileLink(route: Constants.getProfileRoute(withUUID: self.dataView?.message?.createdById ?? "") )
    }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        let bubble = createBubbleView()
        bubbleView = bubble
        addSubview(bubble)
        addSubview(chatProfileImageContainerStackView)
        addSubview(reactionContainerStackView)
        bubble.addArrangeSubview(usernameLabel)
        bubble.addArrangeSubview(replyMessageView)
        bubble.addArrangeSubview(textLabel)
        backgroundColor = .clear
        reactionsView.isHidden = true
        replyMessageView.isHidden = true
        reactionsView.delegate = self
        
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnProfileLink))
        tapImageGesture.numberOfTapsRequired = 1
        let tapNameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnProfileLink))
        tapNameLabelGesture.numberOfTapsRequired = 1
        chatProfileImageView.addGestureRecognizer(tapImageGesture)
        usernameLabel.addGestureRecognizer(tapNameLabelGesture)
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            reactionContainerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            reactionContainerStackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            reactionContainerStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            chatProfileImageContainerStackView.topAnchor.constraint(equalTo: topAnchor),
            chatProfileImageContainerStackView.bottomAnchor.constraint(equalTo: reactionContainerStackView.topAnchor, constant: 2),
            chatProfileImageContainerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            bubbleView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            bubbleView.bottomAnchor.constraint(equalTo: chatProfileImageContainerStackView.bottomAnchor, constant: -2),
            replyMessageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
//            replyMessageView.leadingAnchor.constraint(equalTo: bubbleView.contentContainer.leadingAnchor),
//            replyMessageView.trailingAnchor.constraint(equalTo: bubbleView.contentContainer.trailingAnchor)
        ])
        
         bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: chatProfileImageContainerStackView.trailingAnchor)
         bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40)
        
        outgoingbubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: chatProfileImageContainerStackView.trailingAnchor, constant: 40)
        outgoingbubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: trailingAnchor)
        
//        replyViewWidthConstraint = replyMessageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120)
        
    }
    
    open func createBubbleView() -> LMChatMessageBubbleView {
        let bubble = LMUIComponents.shared
            .messageBubbleView
            .init()
            .translatesAutoresizingMaskIntoConstraints()
        bubble.backgroundColor = Appearance.shared.colors.clear
        return bubble
    }
    
    open func setDataView(_ data: LMChatMessageCell.ContentModel, delegate: LMChatAudioProtocol?, index: IndexPath) {
        dataView = data
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: (data.message?.message ?? "").trimmingCharacters(in: .whitespacesAndNewlines), font: Appearance.Fonts.shared.textFont2, withTextColor: Appearance.Colors.shared.black)
        self.textLabel.isHidden = self.textLabel.text.isEmpty
        setTimestamps(data)
        let isIncoming = data.message?.isIncoming ?? true
        bubbleView.bubbleFor(isIncoming)
        
        if data.message?.isDeleted == true {
            deletedConversationView(data)
        } else {
            replyView(data)
            reactionsView(data)
        }
        
        if !isIncoming {
            chatProfileImageView.isHidden = true
            usernameLabel.isHidden = true
            bubbleLeadingConstraint?.isActive = false
            bubbleTrailingConstraint?.isActive = false
            outgoingbubbleLeadingConstraint?.isActive = true
            outgoingbubbleTrailingConstraint?.isActive = true
        } else {
            chatProfileImageView.imageView.kf.setImage(with: URL(string: data.message?.createdByImageUrl ?? ""), placeholder: UIImage.generateLetterImage(name: data.message?.createdBy?.components(separatedBy: " ").first ?? ""))
            chatProfileImageView.isHidden = false
            messageByName(data)
            usernameLabel.isHidden = false
            bubbleLeadingConstraint?.isActive = true
            bubbleTrailingConstraint?.isActive = true
            outgoingbubbleLeadingConstraint?.isActive = false
            outgoingbubbleTrailingConstraint?.isActive = false
        }
        bubbleView.layoutIfNeeded()
    }
    
    func setTimestamps(_ data: LMChatMessageCell.ContentModel) {
        let edited = data.message?.isEdited == true ? "Edited \(Constants.shared.strings.dot) " : ""
        let timestamp = edited + (data.message?.createdTime ?? "")
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: timestamp + " "))
        if data.message?.isIncoming == false {
            let image = ((data.message?.isSent ?? false) ? Constants.shared.images.checkmarkIcon.withSystemImageConfig(pointSize: 9)?.withTintColor(Appearance.shared.colors.textColor) :  Constants.shared.images.clockIcon.withSystemImageConfig(pointSize: 9)?.withTintColor(Appearance.shared.colors.textColor)) ?? UIImage()
            let textAtt = NSTextAttachment(image: image)
            textAtt.bounds = CGRect(x: 0, y: -1, width: 11, height: 11)
            attributedText.append(NSAttributedString(attachment: textAtt))
        }
        bubbleView.timestampLabel.attributedText = attributedText
    }
    
    func messageByName(_ data: LMChatMessageCell.ContentModel) {
        
        let myAttribute = [ NSAttributedString.Key.font: Appearance.shared.fonts.headingLabel, .foregroundColor: Appearance.shared.colors.red]
        let myString = NSMutableAttributedString(string: "\(data.message?.createdBy ?? "")", attributes: myAttribute )
        if let memberTitle = data.message?.memberTitle {
            let myAttribute2 = [ NSAttributedString.Key.font: Appearance.shared.fonts.buttonFont1, .foregroundColor: Appearance.shared.colors.textColor]
            myString.append(NSAttributedString(string: " \(Constants.shared.strings.dot) \(memberTitle)", attributes: myAttribute2))
        }
        usernameLabel.attributedText = myString
    }
    
    func deletedConversationView(_ data: LMChatMessageCell.ContentModel) {
        self.textLabel.font = Appearance.shared.fonts.italicFont16
        self.textLabel.textColor = Appearance.Colors.shared.textColor
        self.textLabel.text = Constants.shared.strings.messageDeleteText
        self.textLabel.isUserInteractionEnabled = false
        self.textLabel.isHidden = false
    }

    func replyView(_ data: LMChatMessageCell.ContentModel) {
        if let repliedMessage = data.message?.replied?.first {
            replyMessageView.isHidden = false
            replyMessageView.closeReplyButton.isHidden = true
            let message = repliedMessage.isDeleted == true ? Constants.shared.strings.messageDeleteText : repliedMessage.message
            replyMessageView.setData(.init(username: repliedMessage.createdBy, replyMessage: message, attachmentsUrls: repliedMessage.attachments?.compactMap({($0.thumbnailUrl, $0.fileUrl, $0.fileType)}), messageType: data.message?.messageType, isDeleted: repliedMessage.isDeleted ?? false))
            replyMessageView.onClickReplyPreview = {[weak self] in
                self?.delegate?.didTapOnReplyPreview()
            }
//            replyViewWidthConstraint?.constant = max(120, bubbleView.bounds.width)
//            replyViewWidthConstraint?.isActive = true
        } else {
            replyMessageView.isHidden = true
        }
    }
    
    func reactionsView(_ data: LMChatMessageCell.ContentModel) {
        if let reactions = data.message?.reactions, reactions.count > 0 {
            reactionsView.isHidden = false
            reactionsView.setData(reactions)
        } else {
            reactionsView.isHidden = true
        }
    }
    
    func prepareToResuse() {
        reactionsView.isHidden = true
        replyMessageView.isHidden = true
    }
}

extension LMChatMessageContentView: LMChatMessageReactionsViewDelegate {
    
    public func clickedOnReaction(_ reaction: String) {
        delegate?.clickedOnReaction(reaction)
    }
}

