import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../utils/constants.dart';

class SocketService {
  io.Socket? _socket;
  final _tripUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get tripUpdates => _tripUpdateController.stream;

  void connect({String? token}) {
    disconnect();
    final opts = <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    };
    if (token != null && token.isNotEmpty) {
      opts['auth'] = {'token': token};
    }
    _socket = io.io(socketUrl, opts);

    _socket!.onConnect((_) {
      print('Socket connected');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.on('trip-updated', (data) {
      _tripUpdateController.add(data as Map<String, dynamic>);
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void joinTrip(String tripId) {
    _socket?.emit('join-trip', {'tripId': tripId});
  }

  void leaveTrip(String tripId) {
    _socket?.emit('leave-trip', {'tripId': tripId});
  }

  void emitItineraryUpdate(String tripId, String itineraryId, Map<String, dynamic> changes) {
    _socket?.emit('itinerary-update', {
      'tripId': tripId,
      'itineraryId': itineraryId,
      'changes': changes,
    });
  }

  void emitItineraryCreate(String tripId, Map<String, dynamic> data) {
    _socket?.emit('itinerary-create', {'tripId': tripId, 'data': data});
  }

  void emitItineraryDelete(String tripId, String itineraryId) {
    _socket?.emit('itinerary-delete', {'tripId': tripId, 'itineraryId': itineraryId});
  }

  void emitCommentAdded(String tripId, String itineraryId, Map<String, dynamic> comment) {
    _socket?.emit('comment-added', {'tripId': tripId, 'itineraryId': itineraryId, 'comment': comment});
  }

  void emitVoteChanged(String tripId, String itineraryId, List<dynamic> votes) {
    _socket?.emit('vote-changed', {'tripId': tripId, 'itineraryId': itineraryId, 'votes': votes});
  }

  void dispose() {
    disconnect();
    _tripUpdateController.close();
  }
}
