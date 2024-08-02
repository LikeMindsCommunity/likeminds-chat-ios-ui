//
//  LMChatPollView.swift
//  LikeMindsChatUI
//
//  Created by Pushpendra Singh on 24/07/24.
//

import UIKit

public protocol LMChatPollViewDelegate: AnyObject {
    func didTapVoteCountButton(for chatroomId: String, messageId: String, optionID: String?)
    func didTapToVote(for chatroomId: String, messageId: String, optionID: String)
    func didTapSubmitVote(for chatroomId: String, messageId: String)
    func editVoteTapped(for chatroomId: String, messageId: String)
    func didTapAddOption(for chatroomId: String, messageId: String)
}

open class LMChatPollView: LMBasePollView {
    
    public struct ContentModel: LMBasePollView.Content {
        public let chatroomId: String
        public let messageId: String
        public var question: String
        public var options: [LMChatPollOptionView.ContentModel]
        public var expiryDate: Date
        public var optionState: String
        public var optionCount: Int
        public var isAnonymousPoll: Bool
        public var isInstantPoll: Bool
        public var allowAddOptions: Bool
        public var answerText: String
        public var isShowSubmitButton: Bool
        public var isShowEditVote: Bool
        
        public init(
            chatroomId: String,
            messageId: String,
            question: String,
            answerText: String,
            options: [LMChatPollOptionView.ContentModel],
            expiryDate: Date,
            optionState: String,
            optionCount: Int,
            isAnonymousPoll: Bool,
            isInstantPoll: Bool,
            allowAddOptions: Bool,
            isShowSubmitButton: Bool,
            isShowEditVote: Bool
        ) {
            self.chatroomId = chatroomId
            self.messageId = messageId
            self.question = question
            self.options = options
            self.expiryDate = expiryDate
            self.optionState = optionState
            self.optionCount = optionCount
            self.isAnonymousPoll = isAnonymousPoll
            self.isInstantPoll = isInstantPoll
            self.allowAddOptions = allowAddOptions
            self.answerText = answerText
            self.isShowSubmitButton = isShowSubmitButton
            self.isShowEditVote = isShowEditVote
        }
        
        
        public var expiryDateFormatted: String {
            let now = Date()
            
            guard expiryDate > now else {
                return "Poll Ended"
            }
            
            let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: expiryDate)
            
            guard let days = components.day, let hours = components.hour, let minutes = components.minute else {
                return "Just Now"
            }
            
            switch (days, hours, minutes) {
            case (0, 0, let min) where min > 0:
                return "Ends in \(min) \(getPluralText(withNumber: min, text: "min"))"
            case (0, let hr, _) where hr >= 1:
                return "Ends in \(hr) \(getPluralText(withNumber: hr, text: "hour"))"
            case (let d, _, _) where d >= 1:
                return "Ends in \(d) \(getPluralText(withNumber: d, text: "day"))"
            default:
                return "Just Now"
            }
        }
        
        func getPluralText(withNumber number: Int, text: String) -> String {
            number > 1 ? "\(text)s" : text
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var bottomStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 16
        return stack
    }()
    
    open private(set) lazy var topStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var submitButton: LMButton = {
        let button = LMButton.createButton(with: Constants.shared.strings.submitVote, image: nil, textColor: Appearance.shared.colors.white, textFont: Appearance.shared.fonts.buttonFont2, contentSpacing: .init(top: 12, left: 8, bottom: 12, right: 8))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    open private(set) lazy var bottomMetaStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var topMetaStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var topMetaStackSpacer: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: 4).isActive = true
        return view
    }()
    
    open private(set) lazy var answerTitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.appTintColor
        label.font = Appearance.shared.fonts.textFont1
        label.text = "Be the first one to vote"
        label.isUserInteractionEnabled = true
        return label
    }()
    
    open private(set) lazy var editVoteLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.isUserInteractionEnabled = true
        label.textColor = Appearance.shared.colors.appTintColor
        label.font = Appearance.shared.fonts.textFont1
        label.text = "Edit Vote"
        return label
    }()
    
    open private(set) lazy var addOptionButton: LMButton = {
        let button = LMButton.createButton(with: "Add an option", image: Constants.shared.images.plusIcon, textColor: Appearance.shared.colors.black, textFont: Appearance.shared.fonts.buttonFont1, contentSpacing: .init(top: 8, left: 0, bottom: 8, right: 0), imageSpacing: 0)
        button.tintColor = Appearance.shared.colors.black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // MARK: Data Variables
    public weak var delegate: LMChatPollViewDelegate?
    public var chatroomId: String?
    public var messageId: String?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(questionContainerStackView)
        
        questionContainerStackView.addArrangedSubview(topStack)
        questionContainerStackView.addArrangedSubview(questionTitle)
        questionContainerStackView.addArrangedSubview(optionSelectCountLabel)
        
        containerView.addSubview(optionStackView)
        containerView.addSubview(bottomStack)
        
        bottomStack.addArrangedSubview(bottomMetaStack)
        bottomStack.addArrangedSubview(addOptionButton)
        bottomStack.addArrangedSubview(submitButton)
        
        bottomMetaStack.addArrangedSubview(answerTitleLabel)
        topStack.addArrangedSubview(pollTypeLabel)
        topStack.addArrangedSubview(topMetaStack)
        topMetaStack.addArrangedSubview(pollImageView)
        topMetaStack.addArrangedSubview(topMetaStackSpacer)
        topMetaStack.addArrangedSubview(expiryDateLabel)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        let standardMargin: CGFloat = 8
        questionContainerStackView.addConstraint(top: (containerView.topAnchor, standardMargin),
                                                 leading: (containerView.leadingAnchor, standardMargin),
                                                 trailing: (containerView.trailingAnchor, -standardMargin))
        
        optionStackView.addConstraint(top: (questionContainerStackView.bottomAnchor, standardMargin),
                                      leading: (questionContainerStackView.leadingAnchor, 0),
                                      trailing: (questionContainerStackView.trailingAnchor, 0))
        
        addOptionButton.addConstraint(leading: (bottomStack.leadingAnchor, 0),
                                      trailing: (bottomStack.trailingAnchor, 0))
        
        bottomStack.addConstraint(top: (optionStackView.bottomAnchor, standardMargin),
                                  bottom: (containerView.bottomAnchor, -standardMargin),
                                  leading: (optionStackView.leadingAnchor, 0),
                                  trailing: (optionStackView.trailingAnchor, 0))
        
        bottomMetaStack.trailingAnchor.constraint(lessThanOrEqualTo: bottomStack.trailingAnchor, constant: -16).isActive = true
        pollImageView.setWidthConstraint(with: 22)
        pollImageView.setHeightConstraint(with: 22)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        addOptionButton.layer.borderColor = Appearance.shared.colors.gray155.cgColor
        expiryDateLabel.backgroundColor = Appearance.shared.colors.appTintColor
        addOptionButton.layer.borderWidth = 1
        addOptionButton.layer.cornerRadius = 8
        expiryDateLabel.cornerRadius(with: 12)
        submitButton.layer.cornerRadius = 8
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
        editVoteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editVoteTapped)))
        answerTitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(voteCountTapped)))
        addOptionButton.addTarget(self, action: #selector(didTapAddOption), for: .touchUpInside)
    }
    
    @objc
    open func didTapSubmitButton() {
        guard let chatroomId,
              let messageId else { return }
        delegate?.didTapSubmitVote(for: chatroomId, messageId: messageId)
    }
    
    @objc
    open func editVoteTapped() {
        guard let chatroomId,
              let messageId else { return }
        
        delegate?.editVoteTapped(for: chatroomId, messageId: messageId)
    }
    
    @objc
    open func voteCountTapped() {
        guard let chatroomId,
              let messageId else { return }
        
        delegate?.didTapVoteCountButton(for: chatroomId, messageId: messageId, optionID: nil)
    }
    
    
    @objc
    open func didTapAddOption() {
        guard let chatroomId,
              let messageId else { return }
        
        delegate?.didTapAddOption(for: chatroomId, messageId: messageId)
    }
    
    
    // MARK: configure
    open func configure(with data: ContentModel, delegate: LMChatPollViewDelegate?) {
        self.delegate = delegate
        self.chatroomId = data.chatroomId
        self.messageId = data.messageId
        
        questionTitle.text = data.question
        
        optionSelectCountLabel.text = data.optionStringFormatted
        optionSelectCountLabel.isHidden = !data.isShowOption
        
        optionStackView.removeAllArrangedSubviews()
        
        data.options.forEach { option in
            let optionView = LMUIComponents.shared.pollOptionView.init()
            optionView.translatesAutoresizingMaskIntoConstraints = false
            optionView.configure(with: option, delegate: self)
            optionStackView.addArrangedSubview(optionView)
        }
        
        answerTitleLabel.text = data.answerText
        expiryDateLabel.text = data.expiryDateFormatted
        
        addOptionButton.isHidden = !data.allowAddOptions
        
        editVoteLabel.isHidden = !data.isShowEditVote
        
        submitButton.isHidden = !data.isShowSubmitButton
    }
}


// MARK: LMChatDisplayPollWidgetProtocol
extension LMChatPollView: LMChatDisplayPollWidgetProtocol {
    public func didTapVoteCountButton(optionID: String) {
        guard let chatroomId,
              let messageId else { return }
        delegate?.didTapVoteCountButton(for: chatroomId, messageId: messageId, optionID: optionID)
    }
    
    public func didTapToVote(optionID: String) {
        guard let chatroomId,
              let messageId else { return }
        delegate?.didTapToVote(for: chatroomId, messageId: messageId, optionID: optionID)
    }
}
