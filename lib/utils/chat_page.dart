import 'dart:io';

import 'package:chat_app/service/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '/models/profile.dart';
import '/service/auth_service.dart';
import '/service/media_service.dart';
import '/main.dart';
import '/models/chat.dart';
import '/models/message.dart';
import '/service/database_service.dart';
import '/service/storage_service.dart';

class ChatPage extends StatefulWidget {
  final Profile chatUser;
  const ChatPage({Key? key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  ChatUser? currentUser, otherUser;
  late AuthService _authService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late PushNotificationService _pushNotificationService;
  Profile? myself;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _pushNotificationService = _getIt.get<PushNotificationService>();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    myself = await _databaseService.fetchPersonalProfile();
    setState(() {
      currentUser = ChatUser(
        id: _authService.user!.uid,
        firstName: _authService.user!.displayName,
        profileImage: myself?.pfpURL,
      );
      otherUser = ChatUser(
        id: widget.chatUser.userid,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.pfpURL,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatUser.pfpURL),
            ),
            SizedBox(
                width: 8.0), // Add some space between the avatar and the text
            Text(
              widget.chatUser.name,
            ),
          ],
        ),
      ),
      body:
          _isLoading ? Center(child: CircularProgressIndicator()) : _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text("No chat data available"));
        }

        Chat? chat = snapshot.data!.data();
        List<ChatMessage> messages = [];

        if (chat != null) {
          messages = _generateChatMessagesList(chat.messages);
        }

        return DashChat(
          messageOptions: MessageOptions(
            showOtherUsersAvatar: true,
            showCurrentUserAvatar: true,
            showTime: true,
            avatarBuilder: (ChatUser user, Function? onPressAvatar,
                Function? onLongPressAvatar) {
              return DefaultAvatar(
                user: user,
                size: 34, // Adjust size as needed
                fallbackImage:
                    AssetImage('assets/lottie_animations/loading.gif'),
              );
            },
          ),
          inputOptions: InputOptions(alwaysShowSend: true, trailing: [
            _mediaMessageButton(),
          ]),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String? downloadURL = await _storageService.uploadImageToChat(
              file: file,
              chatID: generateChatID(
                  uid1: _authService.user!.uid, uid2: widget.chatUser.userid));
          if (downloadURL != null) {
            ChatMessage chatMessage = ChatMessage(
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  ChatMedia(
                      url: downloadURL, fileName: "", type: MediaType.image)
                ]);
            _sendMessage(chatMessage);
          }
        }
      },
      icon: Icon(
        color: Theme.of(context).colorScheme.primary,
        Icons.image,
      ), // Icon
    ); // IconButton
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendChatMessage(
          currentUser!.id,
          otherUser!.id,
          message,
        );
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
        currentUser!.id,
        otherUser!.id,
        message,
      );
    }
    bool userStatus = await _pushNotificationService.status(otherUser!.id);

    if (!userStatus) {
      String? deviceToken =
          await _pushNotificationService.getToken(otherUser!.id);
      _pushNotificationService.sendNotificationToSelectedDriver(deviceToken!);
    }
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            createdAt: m.sentAt!.toDate(),
            medias: [
              ChatMedia(
                url: m.content!,
                fileName: "",
                type: MediaType.image,
              )
            ]);
      } else {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }
}
