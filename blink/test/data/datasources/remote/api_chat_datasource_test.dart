import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:blink/data/datasources/remote/api_chat_datasource.dart';
import 'package:blink/data/datasources/remote/api_client.dart';

class _MockApiClient extends Mock implements ApiClient {}
class _MockDio extends Mock implements Dio {}

void main() {
  late _MockApiClient client;
  late _MockDio dio;
  late ApiChatDatasource ds;

  setUp(() {
    client = _MockApiClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    ds = ApiChatDatasource(client);
  });

  test('fetchConversationsRaw GETs /chats', () async {
    when(() => dio.get('/chats')).thenAnswer(
      (_) async => Response(
        data: {'conversations': []},
        requestOptions: RequestOptions(path: '/chats'),
      ),
    );
    final result = await ds.fetchConversationsRaw();
    expect(result, isA<List<dynamic>>());
    expect(result, isEmpty);
  });

  test('sendText POSTs JSON with type=text', () async {
    when(() => dio.post(
          '/chats/friend1/messages',
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => Response(
        data: {
          'message': {
            '_id': 'm1',
            'conversationId': 'c1',
            'senderId': 'me',
            'type': 'text',
            'text': 'hello',
            'imageUrl': '',
            'createdAt': '2026-04-19T12:00:00.000Z',
            'editedAt': null,
            'deletedAt': null,
            'readBy': []
          }
        },
        requestOptions: RequestOptions(path: '/chats/friend1/messages'),
      ),
    );
    final m = await ds.sendText(friendId: 'friend1', text: 'hello');
    expect(m.text, 'hello');
    expect(m.type, 'text');
  });
}
