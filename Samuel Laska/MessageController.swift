//
//  MessageController.swift
//  Samuel Laska
//
//  Created by Samuel Laska on 4/24/15.
//  Copyright (c) 2015 Samuel Laska. All rights reserved.
//

import UIKit

class MessageController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    let scripted = Script()
    var positionInScript = 0
    
    var delegate: WWDCControllerDelegate?    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Interviewer, name is not displayed
        self.senderId = "xxx"
        self.senderDisplayName = ""
        
        // disable avatars for sender
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        // disable sending media
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        // disable user input
        self.inputToolbar.contentView.textView.userEnabled = false
        self.inputToolbar.contentView.textView.editable = true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.automaticallyScrollsToMostRecentMessage = true
    }
    
    //MARK:- Scripted
    
    func startAutomaton() {
        if positionInScript == 0 {
            // start automaton
            self.showTypingIndicator = true
            self.scrollToBottomAnimated(true)
            delay(1.0) {
                self.messageAutomaton()
            }
        }
    }
    
    func messageAutomaton() {
        if self.positionInScript < self.scripted.messages.count {
            // load message from script
            let raw = self.scripted.messages[self.positionInScript]
            
            if let id = raw[0] as? String, name = scripted.names[id], content = raw[1] as? String, delay = raw[2] as? Float {
                if (id == "xxx") {
                    // if interviewer, load text and enable send button
                    self.inputToolbar.contentView.textView.text = content
                    self.inputToolbar.toggleSendButtonEnabled()
                } else {
                    // images are for convenience when writing store as "[imageName]"
                    // parse name out, returns "" if not a image
                    let imageName = scripted.parseImageName(content)
                    
                    if (imageName != "") {
                        // image message
                        let photoItem = JSQPhotoMediaItem(image: UIImage(named: imageName))
                        photoItem.appliesMediaViewMaskAsOutgoing = false
                        let photoMessage = JSQMessage(senderId: id, displayName: name, media: photoItem)
                        self.messages += [photoMessage]
                    } else {
                        // text message
                        var message = JSQMessage(senderId: id, displayName: name, text: content)
                        self.messages += [message]
                    }
                    
                    // animate new message, play sound, increment position in script
                    self.finishReceivingMessageAnimated(true)
                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    self.positionInScript++
                    
                    // check if there is next one message
                    if self.positionInScript < self.scripted.messages.count {
                        self.showTypingIndicator = false
                        self.delay(0.5) {
                            // show typing indicator if next message is not from interviewer
                            if !self.scripted.isByInterviewer(self.positionInScript) {
                                self.showTypingIndicator = true
                                self.scrollToBottomAnimated(true)
                            }
                            self.delay(Double(delay)) {
                                self.messageAutomaton()
                            }
                        }
                    } else {
                        // no more scripted messages
                        allowLastMessage()
                    }
                }
            }
        } else {
            allowLastMessage()
        }
    }
    
    func allowLastMessage(){
        self.showTypingIndicator = false
        self.delay(1.0) {
            self.inputToolbar.contentView.textView.text = ""
            self.inputToolbar.contentView.textView.placeHolder = "You can type now"
            self.inputToolbar.contentView.textView.userEnabled = true
        }
    }
    
    func resetEverything() {
        messages.removeAll(keepCapacity: true)
        self.collectionView.reloadData()
        self.positionInScript = 0
    }
    
    
    //MARK:- Write toolbar actions
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        var newMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text);
        messages += [newMessage]
        self.finishSendingMessage()
        
        
        // if another message after this one
        if self.positionInScript < self.scripted.messages.count {
            let raw = self.scripted.messages[self.positionInScript]
            if let nextDelay = raw[2] as? Double {
                positionInScript++
                delay(nextDelay) {
                    self.showTypingIndicator = true
                    self.scrollToBottomAnimated(true)
                    self.delay(1){
                        self.messageAutomaton()
                    }
                }
            }
        } else {
            let command = condenseWhitespace(text).lowercaseString
            if command == "goodbye" || command == "good-bye" || command == "bye" || command == "bye bye" {
                // user said goodbye, return home
                self.inputToolbar.contentView.textView.resignFirstResponder()
                delay(1.0) {
                    delegate?.toggleMessagePanel()
                }
            } else {
                // send me response message (will be forwarded from server to my mail samuel.laska@gmail.com)
                let escapedMessage = text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
                let url = NSURL(string: "http://wwdc.ulovto.eu/?message=\(escapedMessage!)")
                let task = NSURLSession.sharedSession().dataTaskWithURL(url!)
                task.resume()
            }
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
    }
    
    //MARK:- Cell data
    
    //lazy loading of avatars
    func avatarForIndex(id: String) -> JSQMessageAvatarImageDataSource {
        if let avatar = scripted.avatars[id] {
            return avatar
        }
        // return (XX) for unknown users
        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("XX",
            backgroundColor: UIColor.blackColor(),
            textColor: UIColor.whiteColor(),
            font: UIFont.boldSystemFontOfSize(16), diameter: 30)
    }

    
    // get message data
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        var data = self.messages[indexPath.item]
        return data
    }
    
    // get out|in background bubble
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        return scripted.bubbles[message.senderId]
    }
    
    // get avatar
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item]
        return avatarForIndex(message.senderId)
    }
    
    // cells in section
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    // name text
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        if (message.senderId == self.senderId) {
            return nil
        }
        
        if (indexPath.item - 1 >= 0) {
            let previousMessage = self.messages[indexPath.item-1]
            if (previousMessage.senderId == message.senderId) {
                return nil
            }
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    //MARK:- Label Heights
    
    // top label
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if (indexPath.item == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    // name label
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = self.messages[indexPath.item]
        if (message.senderId == self.senderId) {
            return 0.0
        }
        
        if (indexPath.item - 1 >= 0) {
            let previousMessage = self.messages[indexPath.item-1]
            if (previousMessage.senderId == message.senderId) {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    // bottom label
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0.0
    }
    
    //MARK:- Collection view tap events
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = self.messages[indexPath.item]
        
        
        if (message.isMediaMessage) {
            // image overlay
            if let photo = message.media as? JSQPhotoMediaItem {
                let imageOverlay = JTSImageInfo()
                imageOverlay.image = photo.image
                imageOverlay.referenceView = self.collectionView
                imageOverlay.referenceCornerRadius = 15
                
                // get size of image bubble
                let bubbleCell = self.collectionView.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
                let bF = bubbleCell.messageBubbleContainerView.frame
                
                // get position of cell in collection view
                let layoutAttributes = self.collectionView.layoutAttributesForItemAtIndexPath(indexPath)
                let cF = layoutAttributes!.frame
                
                // calculate reference image
                imageOverlay.referenceRect = CGRectMake(cF.origin.x + bF.origin.x + 6, cF.origin.y+bF.origin.y, bF.size.width - 6, bF.size.height)
                
                // start image overlay controller
                let overlayController = JTSImageViewController(
                    imageInfo: imageOverlay,
                    mode: JTSImageViewControllerMode.Image,
                    backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
                 overlayController.showFromViewController(self,
                    transition: JTSImageViewControllerTransition._FromOriginalPosition)
                self.automaticallyScrollsToMostRecentMessage = false
            }
        }
    }
    
    // go to wwdc screen
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        delegate?.toggleMessagePanel()
    }
    
    //MARK:- Convenience functions
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func condenseWhitespace(string: String) -> String {
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!isEmpty($0)})
        return join(" ", components)
    }
}
