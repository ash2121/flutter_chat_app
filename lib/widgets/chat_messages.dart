import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    // to listen stream of messages so that new messages can be updated
    return StreamBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong!'));
        }
        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemBuilder: (context, index) {
            final userMessage = loadedMessages[index].data();
            final currentMessageUserId = userMessage['user'];
            final nextMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final nextMessageUserId = nextMessage == null
                ? null
                : loadedMessages[index + 1].data()['user'];
            final isSameUser = currentMessageUserId == nextMessageUserId;
            if (isSameUser) {
              return MessageBubble.next(
                  message: userMessage['text'],
                  isMe: authenticatedUser!.uid == currentMessageUserId);
            }
            return MessageBubble.first(
              userImage: userMessage['image_url'],
              username: userMessage['username'],
              message: userMessage['text'],
              isMe: authenticatedUser!.uid == currentMessageUserId,
            );
          },
          itemCount: loadedMessages.length,
        );
      },
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('timestamp', descending: true)
          .snapshots(),
    );
  }
}
