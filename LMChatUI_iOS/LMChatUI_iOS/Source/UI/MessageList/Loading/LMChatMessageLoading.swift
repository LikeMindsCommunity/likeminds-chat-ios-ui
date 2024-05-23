//
//  LMChatMessageLoading.swift
//  LMChatCore_iOS
//
//  Created by Pushpendra Singh on 01/05/24.
//

import Foundation

@IBDesignable
open class LMChatMessageLoading: LMView {
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    var receivedBubble = Constants.shared.images.bubbleReceived.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch)
        .withRenderingMode(.alwaysTemplate)
    var sentBubble = Constants.shared.images.bubbleSent.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch)
        .withRenderingMode(.alwaysTemplate)
    var incomingColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4).withAlphaComponent(0.8)
    var outgoingColor = UIColor(red: 0.88, green: 0.99, blue: 0.98, alpha: 0.4).withAlphaComponent(0.8)
    
    open private(set) lazy var outgoingImageView: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
//        image.alpha = 0.6
        image.backgroundColor = Appearance.shared.colors.clear
        return image
    }()
    
    open private(set) lazy var incomingImageView: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
//        image.alpha = 0.6
        image.backgroundColor = Appearance.shared.colors.clear
        return image
    }()

    open private(set) lazy var profileMessageView: LMChatShimmerView = {
        let view = LMUIComponents.shared.shimmerView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setWidthConstraint(with: 36)
        view.setHeightConstraint(with: 36)
        view.cornerRadius(with: 18)
        view.backgroundColor = Appearance.shared.colors.previewSubtitleTextColor
        return view
    }()
    
    open private(set) lazy var sentmessageTitleView: LMChatShimmerView = {
        let view = LMUIComponents.shared.shimmerView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setHeightConstraint(with: 14)
        view.cornerRadius(with: 7)
        view.setWidthConstraint(with: 160)
        view.backgroundColor = Appearance.shared.colors.previewSubtitleTextColor
        return view
    }()
    
    open private(set) lazy var incomingMessageTitleView: LMChatShimmerView = {
        let view = LMUIComponents.shared.shimmerView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setHeightConstraint(with: 14)
        view.cornerRadius(with: 7)
        view.setWidthConstraint(with: 160)
        view.backgroundColor = Appearance.shared.colors.previewSubtitleTextColor
        return view
    }()
    
    open private(set) lazy var sentmessageTitleView2: LMChatShimmerView = {
        let view = LMUIComponents.shared.shimmerView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setHeightConstraint(with: 14)
        view.setWidthConstraint(with: 100)
        view.cornerRadius(with: 7)
        view.backgroundColor = Appearance.shared.colors.previewSubtitleTextColor
        return view
    }()
    
    open private(set) lazy var incomingMessageTitleView2: LMChatShimmerView = {
        let view = LMUIComponents.shared.shimmerView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setHeightConstraint(with: 14)
        view.setWidthConstraint(with: 100)
        view.cornerRadius(with: 7)
        view.backgroundColor = Appearance.shared.colors.previewSubtitleTextColor
        return view
    }()
    
    open private(set) lazy var outgoingStackContainer: LMStackView = {
        let view = LMStackView().translatesAutoresizingMaskIntoConstraints()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = 8
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var incomingStackContainer: LMStackView = {
        let view = LMStackView().translatesAutoresizingMaskIntoConstraints()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = 8
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open override func setupAppearance() {
        super.setupAppearance()
    }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        addSubview(containerView)
        containerView.addSubview(profileMessageView)
        
        containerView.addSubview(incomingImageView)
        containerView.addSubview(outgoingImageView)
        
        outgoingStackContainer.addArrangedSubview(sentmessageTitleView)
        outgoingStackContainer.addArrangedSubview(sentmessageTitleView2)
        
        incomingStackContainer.addArrangedSubview(incomingMessageTitleView)
        incomingStackContainer.addArrangedSubview(incomingMessageTitleView2)
        
        outgoingImageView.addSubview(outgoingStackContainer)
        incomingImageView.addSubview(incomingStackContainer)
        
        incomingImageView.tintColor = incomingColor
        incomingImageView.image = receivedBubble
        
        outgoingImageView.tintColor = outgoingColor
        outgoingImageView.image = sentBubble
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            profileMessageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            profileMessageView.bottomAnchor.constraint(equalTo: incomingImageView.bottomAnchor),
            
            incomingImageView.leadingAnchor.constraint(equalTo: profileMessageView.trailingAnchor),
            incomingImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            
            incomingStackContainer.leadingAnchor.constraint(equalTo: incomingImageView.leadingAnchor, constant: 24),
            incomingStackContainer.trailingAnchor.constraint(equalTo: incomingImageView.trailingAnchor, constant: -30),
            incomingStackContainer.topAnchor.constraint(equalTo: incomingImageView.topAnchor,constant: 12),
            incomingStackContainer.bottomAnchor.constraint(equalTo: incomingImageView.bottomAnchor,constant: -12),
            
            outgoingImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            outgoingImageView.topAnchor.constraint(equalTo: incomingImageView.bottomAnchor, constant: 20),
            outgoingImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            outgoingStackContainer.leadingAnchor.constraint(equalTo: outgoingImageView.leadingAnchor, constant: 16),
            outgoingStackContainer.trailingAnchor.constraint(equalTo: outgoingImageView.trailingAnchor, constant: -24),
            outgoingStackContainer.topAnchor.constraint(equalTo: outgoingImageView.topAnchor,constant: 12),
            outgoingStackContainer.bottomAnchor.constraint(equalTo: outgoingImageView.bottomAnchor, constant: -12),
        ])
    }
}
