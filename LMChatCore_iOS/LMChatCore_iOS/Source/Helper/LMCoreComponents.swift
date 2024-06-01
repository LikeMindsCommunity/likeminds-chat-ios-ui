//
//  LMCoreComponents.swift
//  LikeMindsChatUI
//
//  Created by Pushpendra Singh on 07/03/24.
//

import Foundation
import UIKit

let LMChatCoreBundle = Bundle(for: LMChatMessageListViewController.self)

public struct LMCoreComponents {
    public static var shared = Self()
   /*
    // MARK: Universal Feed
    public var universalFeedViewController: LMUniversalFeedViewController.Type = LMUniversalFeedViewController.self
    public var feedListViewController: LMFeedPostListViewController.Type = LMFeedPostListViewController.self
    
    // MARK: Post Detail
    public var postDetailScreen: LMFeedPostDetailViewController.Type = LMFeedPostDetailViewController.self
    
    // MARK: Topic Feed
    public var topicFeedSelectionScreen: LMFeedTopicSelectionViewController.Type = LMFeedTopicSelectionViewController.self
    
    // MARK: Tagging List View
    public var taggingListView: LMFeedTaggingListView.Type = LMFeedTaggingListView.self
    
    // MARK: Like Screen
    public var likeListScreen: LMFeedLikeViewController.Type = LMFeedLikeViewController.self
    
    // MARK: Notification Screen
    public var notificationScreen: LMFeedNotificationViewController.Type = LMFeedNotificationViewController.self
    
    // MARK: Create Post
    public var createPostScreen: LMFeedCreatePostViewController.Type = LMFeedCreatePostViewController.self
    
    // MARK: Edit Post
    public var editPostScreen: LMFeedEditPostViewController.Type = LMFeedEditPostViewController.self
    
    // MARK: Delete Review Screen
    public var deleteReviewScreen: LMFeedDeleteReviewScreen.Type = LMFeedDeleteReviewScreen.self
    */
    
    // MARK: HomeFeed Screen
    public var homeFeedScreen: LMChatHomeFeedViewController.Type = LMChatHomeFeedViewController.self
    
    public var exploreChatroomListScreen: LMExploreChatroomListView.Type = LMExploreChatroomListView.self
    public var exploreChatroomScreen: LMExploreChatroomViewController.Type = LMExploreChatroomViewController.self
//    public var exploreChatroomView: LMExploreChatroomView.Type = LMExploreChatroomView.self
    
    // MARK: Report Screen
    public var reportScreen: LMChatReportViewController.Type = LMChatReportViewController.self
    
    // MARK: Participant list Screen
    public var participantListScreen: LMParticipantListViewController.Type = LMParticipantListViewController.self
    
    // MARK: Attachment message screen
    public var attachmentMessageScreen: LMChatAttachmentViewController.Type = LMChatAttachmentViewController.self
    
    public var messageListScreen: LMChatMessageListViewController.Type = LMChatMessageListViewController.self
}
