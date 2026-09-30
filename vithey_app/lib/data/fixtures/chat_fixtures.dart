import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/chat_shared_content_model.dart';

abstract final class ChatFixtures {
  static List<ConversationModel> buildConversations() {
    return [
      ConversationModel(
        id: MockIds.convMeas,
        participant: const ChatParticipant(
          id: MockIds.author5,
          fullName: 'Meas Lily',
          isOnline: true,
        ),
        lastMessagePreview: 'Are you free this afternoon?',
        updatedAt: MockClock.minutesAgo(2),
        unreadCount: 3,
        isTyping: true,
      ),
      ConversationModel(
        id: MockIds.convNewContact,
        participant: ChatParticipant(
          id: MockIds.author14,
          fullName: 'New Contact',
          lastSeenAt: MockClock.hoursAgo(3),
        ),
        lastMessagePreview: 'Hi, nice to meet you!',
        updatedAt: MockClock.minutesAgo(21),
        unreadCount: 1,
      ),
      ConversationModel(
        id: MockIds.convBora,
        participant: ChatParticipant(
          id: MockIds.author6,
          fullName: 'Ponloeng Bora',
          lastSeenAt: MockClock.minutesAgo(45),
        ),
        lastMessagePreview: "Hey! what's sub",
        updatedAt: MockClock.minutesAgo(35),
        unreadCount: 0,
        lastMessageIsOwn: true,
        lastMessageStatus: MessageDeliveryStatus.read,
      ),
      ConversationModel(
        id: MockIds.convHeng,
        participant: const ChatParticipant(
          id: MockIds.author1,
          fullName: 'Heng Liza',
          isOnline: true,
        ),
        lastMessagePreview: "I'm looking for a job",
        updatedAt: MockClock.hoursAgo(1),
        unreadCount: 0,
      ),
      ConversationModel(
        id: MockIds.convMolika,
        participant: const ChatParticipant(
          id: MockIds.author2,
          fullName: 'Molika Khorn',
          isOnline: true,
        ),
        lastMessagePreview: 'Can you share the assignment file?',
        updatedAt: MockClock.hoursAgo(2),
        unreadCount: 5,
      ),
      ConversationModel(
        id: MockIds.convCareer,
        participant: ChatParticipant(
          id: MockIds.author3,
          fullName: 'AUB Career Center',
          lastSeenAt: MockClock.hoursAgo(5),
        ),
        lastMessagePreview: 'New internship openings this week 📢',
        updatedAt: MockClock.hoursAgo(3),
        unreadCount: 12,
      ),
      ConversationModel(
        id: MockIds.convSreynich,
        participant: ChatParticipant(
          id: MockIds.author4,
          fullName: 'Sreynich Chan',
          lastSeenAt: MockClock.hoursAgo(8),
        ),
        lastMessagePreview: 'Thanks for the recommendation!',
        updatedAt: MockClock.hoursAgo(5),
        unreadCount: 0,
        lastMessageIsOwn: true,
        lastMessageStatus: MessageDeliveryStatus.delivered,
      ),
      ConversationModel(
        id: MockIds.convSokha,
        participant: const ChatParticipant(
          id: MockIds.author8,
          fullName: 'Sokha Phan',
          isOnline: true,
        ),
        lastMessagePreview: 'See you at the library at 4pm',
        updatedAt: MockClock.hoursAgo(6),
        unreadCount: 2,
      ),
      ConversationModel(
        id: MockIds.convDara,
        participant: const ChatParticipant(
          id: MockIds.author9,
          fullName: 'Dara Lim',
          isOnline: true,
        ),
        lastMessagePreview: 'I submitted the CV already.',
        updatedAt: MockClock.hoursAgo(8),
        unreadCount: 0,
        lastMessageIsOwn: true,
        lastMessageStatus: MessageDeliveryStatus.read,
      ),
      ConversationModel(
        id: MockIds.convVanna,
        participant: ChatParticipant(
          id: MockIds.author10,
          fullName: 'Vanna Chea',
          lastSeenAt: MockClock.hoursAgo(14),
        ),
        lastMessagePreview: 'Voice message',
        updatedAt: MockClock.hoursAgo(12),
        unreadCount: 1,
      ),
      ConversationModel(
        id: MockIds.convPisey,
        participant: ChatParticipant(
          id: MockIds.author11,
          fullName: 'Pisey Nget',
          lastSeenAt: MockClock.hoursAgo(20),
        ),
        lastMessagePreview: 'Did you join the Telegram group?',
        updatedAt: MockClock.hoursAgo(18),
        unreadCount: 0,
      ),
      ConversationModel(
        id: MockIds.convRith,
        participant: ChatParticipant(
          id: MockIds.author12,
          fullName: 'Rith Sok',
          lastSeenAt: MockClock.hoursAgo(30),
        ),
        lastMessagePreview: 'Photo',
        updatedAt: MockClock.hoursAgo(26),
        unreadCount: 4,
      ),
      ConversationModel(
        id: MockIds.convSophea,
        participant: const ChatParticipant(
          id: MockIds.author13,
          fullName: 'Sophea Keo',
          isOnline: true,
        ),
        lastMessagePreview: 'Good luck with the interview 💪',
        updatedAt: MockClock.hoursAgo(30),
        unreadCount: 0,
      ),
      ConversationModel(
        id: MockIds.convGroupStudy,
        participant: ChatParticipant(
          id: MockIds.author15,
          fullName: 'Study Group AUB',
          lastSeenAt: MockClock.hoursAgo(42),
        ),
        lastMessagePreview: 'Sokha: Meeting moved to Friday',
        updatedAt: MockClock.hoursAgo(40),
        unreadCount: 8,
      ),
      ConversationModel(
        id: MockIds.convMoeng,
        participant: ChatParticipant(
          id: MockIds.author7,
          fullName: 'Moeng Kimheang',
          lastSeenAt: MockClock.hoursAgo(50),
        ),
        lastMessagePreview:
            'I checked it already nothing to modify on my side.',
        updatedAt: MockClock.hoursAgo(48),
        unreadCount: 0,
        lastMessageIsOwn: true,
        lastMessageStatus: MessageDeliveryStatus.read,
      ),
    ];
  }

  static Map<String, List<ChatMessage>> buildMessages({
    required String currentUserId,
  }) {
    return {
      MockIds.convHeng: [
        ChatMessage(
          id: 'm1',
          conversationId: MockIds.convHeng,
          senderId: MockIds.author1,
          text: "I'm looking for a job position at your company.",
          createdAt: MockClock.hoursAgo(2),
        ),
        ChatMessage(
          id: 'm2',
          conversationId: MockIds.convHeng,
          senderId: currentUserId,
          text: 'Sure! Send me your CV when you are ready.',
          createdAt: MockClock.minutesAgo(35),
          isOwn: true,
          status: MessageDeliveryStatus.read,
        ),
        ChatMessage(
          id: 'm3',
          conversationId: MockIds.convHeng,
          senderId: MockIds.author1,
          text: "I'm looking for a job",
          createdAt: MockClock.hoursAgo(1),
        ),
      ],
      MockIds.convBora: [
        ChatMessage(
          id: 'm4',
          conversationId: MockIds.convBora,
          senderId: currentUserId,
          text: "Hey! what's sub",
          createdAt: MockClock.minutesAgo(35),
          isOwn: true,
          status: MessageDeliveryStatus.read,
        ),
      ],
      MockIds.convMoeng: [
        ChatMessage(
          id: 'm5',
          conversationId: MockIds.convMoeng,
          senderId: currentUserId,
          text: 'I checked it already nothing to modify on my side.',
          createdAt: MockClock.hoursAgo(48),
          isOwn: true,
          status: MessageDeliveryStatus.read,
        ),
      ],
      MockIds.convMeas: [
        ChatMessage(
          id: 'm6',
          conversationId: MockIds.convMeas,
          senderId: MockIds.author5,
          text: 'Are you free this afternoon?',
          createdAt: MockClock.minutesAgo(10),
        ),
        ChatMessage(
          id: 'm6b',
          conversationId: MockIds.convMeas,
          senderId: MockIds.author5,
          text: 'We can review the project together.',
          createdAt: MockClock.minutesAgo(8),
        ),
        ChatMessage(
          id: 'm6c',
          conversationId: MockIds.convMeas,
          senderId: MockIds.author5,
          text: 'Let me know 😊',
          createdAt: MockClock.minutesAgo(2),
        ),
      ],
      MockIds.convMolika: [
        ChatMessage(
          id: 'm7',
          conversationId: MockIds.convMolika,
          senderId: MockIds.author2,
          text: 'Hey, are you done with chapter 4?',
          createdAt: MockClock.hoursAgo(3),
        ),
        ChatMessage(
          id: 'm8',
          conversationId: MockIds.convMolika,
          senderId: currentUserId,
          text: 'Almost — finishing the last section.',
          createdAt: MockClock.hoursAgo(2).add(const Duration(minutes: 20)),
          isOwn: true,
          status: MessageDeliveryStatus.read,
        ),
        ChatMessage(
          id: 'm9',
          conversationId: MockIds.convMolika,
          senderId: MockIds.author2,
          text: 'Can you share the assignment file?',
          createdAt: MockClock.hoursAgo(2),
        ),
      ],
      MockIds.convCareer: [
        ChatMessage(
          id: 'm10',
          conversationId: MockIds.convCareer,
          senderId: MockIds.author3,
          text: 'Welcome to AUB Career Center updates!',
          createdAt: MockClock.hoursAgo(10),
        ),
        ChatMessage(
          id: 'm11',
          conversationId: MockIds.convCareer,
          senderId: MockIds.author3,
          text: 'New internship openings this week 📢',
          createdAt: MockClock.hoursAgo(3),
        ),
      ],
      MockIds.convSreynich: [
        ChatMessage(
          id: 'm12',
          conversationId: MockIds.convSreynich,
          senderId: MockIds.author4,
          text: 'Do you know anyone hiring for marketing?',
          createdAt: MockClock.hoursAgo(6),
        ),
        ChatMessage(
          id: 'm13',
          conversationId: MockIds.convSreynich,
          senderId: currentUserId,
          text: 'Yes — I can introduce you to HR tomorrow.',
          createdAt: MockClock.hoursAgo(5).add(const Duration(minutes: 30)),
          isOwn: true,
          status: MessageDeliveryStatus.read,
        ),
        ChatMessage(
          id: 'm14',
          conversationId: MockIds.convSreynich,
          senderId: currentUserId,
          text: 'Thanks for the recommendation!',
          createdAt: MockClock.hoursAgo(5),
          isOwn: true,
          status: MessageDeliveryStatus.delivered,
        ),
      ],
      MockIds.convSokha: [
        ChatMessage(
          id: 'm15',
          conversationId: MockIds.convSokha,
          senderId: MockIds.author8,
          text: 'Want to study together later?',
          createdAt: MockClock.hoursAgo(7),
        ),
        ChatMessage(
          id: 'm16',
          conversationId: MockIds.convSokha,
          senderId: MockIds.author8,
          text: 'See you at the library at 4pm',
          createdAt: MockClock.hoursAgo(6),
        ),
      ],
      MockIds.convDara: [
        ChatMessage(
          id: 'm17',
          conversationId: MockIds.convDara,
          senderId: currentUserId,
          text: 'I submitted the CV already.',
          createdAt: MockClock.hoursAgo(8),
          isOwn: true,
          status: MessageDeliveryStatus.read,
        ),
      ],
      MockIds.convVanna: [
        ChatMessage(
          id: 'm18',
          conversationId: MockIds.convVanna,
          senderId: MockIds.author10,
          text: 'Voice message',
          createdAt: MockClock.hoursAgo(12),
        ),
      ],
      MockIds.convPisey: [
        ChatMessage(
          id: 'm19',
          conversationId: MockIds.convPisey,
          senderId: MockIds.author11,
          text: 'Did you join the Telegram group?',
          createdAt: MockClock.hoursAgo(18),
        ),
      ],
      MockIds.convRith: [
        ChatMessage(
          id: 'm20',
          conversationId: MockIds.convRith,
          senderId: MockIds.author12,
          text: 'Photo',
          createdAt: MockClock.hoursAgo(26),
        ),
      ],
      MockIds.convSophea: [
        ChatMessage(
          id: 'm21',
          conversationId: MockIds.convSophea,
          senderId: MockIds.author13,
          text: 'Good luck with the interview 💪',
          createdAt: MockClock.hoursAgo(30),
        ),
      ],
      MockIds.convGroupStudy: [
        ChatMessage(
          id: 'm22',
          conversationId: MockIds.convGroupStudy,
          senderId: MockIds.author8,
          text: 'Meeting moved to Friday',
          createdAt: MockClock.hoursAgo(40),
        ),
      ],
      MockIds.convNewContact: [
        ChatMessage(
          id: 'm23',
          conversationId: MockIds.convNewContact,
          senderId: MockIds.author14,
          text: 'Hi, nice to meet you!',
          createdAt: MockClock.minutesAgo(21),
        ),
      ],
    };
  }

  static List<MessageRequestModel> buildMessageRequests() {
    return [
      MessageRequestModel(
        id: 'req-1',
        requester: const ChatParticipant(
          id: MockIds.author4,
          fullName: 'Sreynich Chan',
          bio: 'Business student',
        ),
        initialMessage: 'Hi! I saw your post about the campus event.',
        createdAt: MockClock.hoursAgo(5),
      ),
      MessageRequestModel(
        id: 'req-2',
        requester: const ChatParticipant(
          id: MockIds.author10,
          fullName: 'Vanna Chea',
          bio: 'Design major',
        ),
        initialMessage: 'Can I ask about your internship experience?',
        createdAt: MockClock.hoursAgo(12),
      ),
      MessageRequestModel(
        id: 'req-3',
        requester: const ChatParticipant(
          id: MockIds.author12,
          fullName: 'Rith Sok',
          bio: 'Fresh graduate',
        ),
        initialMessage: 'Hello! Are you still hiring for part-time roles?',
        createdAt: MockClock.hoursAgo(20),
      ),
    ];
  }

  static ChatSharedContent sharedContent() {
    return ChatSharedContent(
      imageUrls: List.generate(
        6,
        (i) => 'https://picsum.photos/seed/chat-media-$i/300/300',
      ),
      videoUrls: List.generate(
        6,
        (i) => 'https://picsum.photos/seed/chat-video-$i/300/300',
      ),
      files: [
        ChatSharedFile(
          name: 'Heng_Liza_CV.pdf',
          sizeLabel: '120 KB',
          sharedAt: DateTime(2025, 10, 26, 11, 14),
        ),
        ChatSharedFile(
          name: '${MockIdentities.mockUserFullName.replaceAll(' ', '_')}_CV.pdf',
          sizeLabel: '98 KB',
          sharedAt: DateTime(2025, 10, 26, 11, 14),
        ),
      ],
      links: [
        ChatSharedLink(
          url: 'https://t.me/acledarecruitment',
          sharedAt: DateTime(2026, 1, 12),
          title: 'ACLEDA Recruitment',
          description:
              "Please join ACLEDA recruitment's official Telegram channel to get more Job Announcement updates.",
        ),
      ],
    );
  }

  static List<ChatParticipant> recentContacts() => UserFixtures.recentContacts();
}
