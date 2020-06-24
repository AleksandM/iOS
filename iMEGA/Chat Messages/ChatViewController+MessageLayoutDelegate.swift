import MessageKit

extension ChatViewController: ChatViewMessagesLayoutDelegate {
    func collectionView(_ collectionView: MessagesCollectionView, layout collectionViewLayout: MessagesCollectionViewFlowLayout, editingOffsetForCellAt indexPath: IndexPath) -> CGFloat {
        guard let message = messages[indexPath.section] as? ChatMessage else {
            return 0
        }
        
        return isFromCurrentSender(message: message) ? 0 : 50
    }

    func collectionView(_ collectionView: MessagesCollectionView, layout collectionViewLayout: MessagesCollectionViewFlowLayout, shouldEditItemAt indexPath: IndexPath) -> Bool {
        guard let chatMessage = messages[indexPath.section] as? ChatMessage, chatMessage.transfer == nil else {
            return false
        }

        return !chatMessage.message.isManagementMessage
    }
    

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if message is ChatNotificationMessage {
            return 0.0
        }
        
        return isDateLabelVisible(for: indexPath) ? 30.0 : 0.0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if message is ChatNotificationMessage {
            return 0.0
        }
        
        return isTimeLabelVisible(at: indexPath) ? 28.0 : 0.0
    }

    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        if messages[section] is ChatNotificationMessage {
            return .zero
        }
        
        if section == 0 {
            if chatRoomDelegate.isFullChatHistoryLoaded {
                let chatMessageHeaderView = ChatViewIntroductionHeaderView.instanceFromNib
                chatMessageHeaderView.chatRoom = chatRoom
                return chatMessageHeaderView.sizeThatFits(
                    CGSize(width: messagesCollectionView.bounds.width,
                           height: .greatestFiniteMagnitude)
                )
            } else {
                return CGSize(width: messagesCollectionView.bounds.width,
                              height: 200)
            }
            
        }
        
        return .zero
    }
}

extension ChatViewController: MessagesEditCollectionOverlayViewDelegate {
    func editOverlayView(_ editOverlayView: MessageEditCollectionOverlayView, activated: Bool) {
        guard let indexPath = editOverlayView.indexPath,
            let message = messages[indexPath.section] as? ChatMessage else {
            return
        }
        
        if activated {
            selectedMessages.insert(message)
        } else {
            selectedMessages.remove(message)
        }
        updateToolbarState()
    }
}
