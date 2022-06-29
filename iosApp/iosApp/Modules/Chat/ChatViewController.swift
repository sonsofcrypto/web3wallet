// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ChatView: AnyObject {

    func update(with viewModel: ChatViewModel)
}

final class ChatViewController: BaseViewController {

    var presenter: ChatPresenter!

    private var viewModel: ChatViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var bottomInputBox: UIView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    private var messageToSend = ""

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureNavAndTabBarItem()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        presenter?.present()
    }
}

extension ChatViewController: ChatView {

    func update(with viewModel: ChatViewModel) {

        self.viewModel = viewModel
        
        collectionView.reloadData()
        collectionView.scrollToItem(
            at: .init(row: viewModel.items().count - 1, section: 0),
            at: .bottom,
            animated: true
        )
        processMessage()
    }
}

extension ChatViewController {
    
    func configureUI() {
        
        (view as? GradientView)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]
        
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomContainerView.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor
        ).isActive = true
        bottomContainerView.backgroundColor = Theme.color.backgroundDark
        
        bottomInputBox.backgroundColor = Theme.color.background
        bottomInputBox.layer.cornerRadius = 16
        
        inputTextView.backgroundColor = .clear
        inputTextView.update(lineSpacing: 8)
        inputTextView.textColor = .white
        inputTextView.text = nil
        inputTextView.isScrollEnabled = false
        
        sendButton.addTarget(
            self,
            action: #selector(sendButtonTapped),
            for: .touchUpInside
        )
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tapGesture)
    }

    func configureNavAndTabBarItem() {
        
        title = Localized("chat")
    }
    
    var maxBubleWidth: CGFloat {
        
        collectionView.frame.size.width * 0.8
    }
}

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        viewModel?.items().count ?? 0
    }
    

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let viewModel = viewModel?.items()[indexPath.item]
        
        if viewModel?.owner == .me {
            
            let cell = collectionView.dequeue(
                ChatRightCollectionViewCell.self,
                for: indexPath
            )
            cell.update(
                with: viewModel,
                and: maxBubleWidth
            )
            updateItemAsRead(at: indexPath.item)
            return cell
        } else {
            
            let cell = collectionView.dequeue(
                ChatLeftCollectionViewCell.self,
                for: indexPath
            )
            cell.update(
                with: viewModel,
                and: maxBubleWidth
            )
            updateItemAsRead(at: indexPath.item)
            return cell
        }
    }
}

extension ChatViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let cell = collectionView.dequeue(
            ChatLeftCollectionViewCell.self,
            for: indexPath
        )
        cell.frame.size.width = collectionView.frame.width
        cell.update(
            with: viewModel!.items()[indexPath.row],
            and: maxBubleWidth
        )
        let resizing = cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel
        )
        return .init(width: collectionView.frame.width, height: resizing.height)
    }
}

private extension ChatViewController {
    
    func sendMessage(_ string: String, after delay: TimeInterval = 0) {
        
        self.messageToSend = string
                
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.continueSendingMessage()
        }
    }
    
    func continueSendingMessage() {
        
        if !inputTextView.isFirstResponder {
            
            inputTextView.becomeFirstResponder()
        }
        
        let typed = inputTextView.text ?? ""
        
        guard typed.count == messageToSend.count else {
            
            typeNextCharacter()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.sendButton.sendActions(for: .touchUpInside)
        }
    }
    
    func typeNextCharacter() {
        
        let character = messageToSend[inputTextView.text.count]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { [weak self] in
            
            guard let self = self else { return }
            self.inputTextView.text = self.inputTextView.text + "\(character)"
            self.continueSendingMessage()
        }
    }
    
    @objc func sendButtonTapped() {
        
        let message = inputTextView.text ?? ""
        presenter.handle(.send(message: message))
        inputTextView.text = ""
    }
    
    func processMessage() {
        
        if viewModel?.items().last?.message == Localized("chat.friend.message1") {
            
            let message = Localized("chat.me.message1")
            sendMessage(message, after: 0.5)
        } else if viewModel?.items().last?.message == Localized("chat.friend.message3") {
            
            let message = Localized("chat.me.message2")
            sendMessage(message, after: 0.5)
        } else if viewModel?.items().last?.message == Localized("chat.me.message2") {
            
            let message = Localized("chat.me.message3")
            sendMessage(message, after: 0.5)
        }
    }
    
    @objc func dismissKeyboard() {
        
        inputTextView.resignFirstResponder()
    }
    
    func updateItemAsRead(at index: Int) {
        
        guard let viewModel = viewModel else { return }
        
        guard case let ChatViewModel.loaded(
            items,
            selectedIdx
        ) = viewModel else { return }
        
        guard items.count - 1 < index else { return }
        
        let item = items[index]
        
        guard item.isNewMessage else { return }
        
        let itemToUpdate = ChatViewModel.Item(
            owner: item.owner,
            message: item.message,
            isNewMessage: false
        )
        var itemsUpdated = items
        itemsUpdated[index] = itemToUpdate
        
        self.viewModel = .loaded(
            items: itemsUpdated,
            selectedIdx: selectedIdx
        )
    }
}
