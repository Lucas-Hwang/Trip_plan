import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../models/trip.dart';
import '../models/itinerary.dart';
import 'auth_provider.dart';

final socketServiceProvider = Provider((ref) => SocketService());

final tripsProvider = FutureProvider<List<Trip>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getTrips();
});

final tripDetailProvider = FutureProvider.family<Trip, String>((ref, tripId) async {
  final api = ref.read(apiServiceProvider);
  return api.getTrip(tripId);
});

final itinerariesProvider = FutureProvider.family<List<Itinerary>, String>((ref, tripId) async {
  final api = ref.read(apiServiceProvider);
  return api.getItineraries(tripId);
});

class ItineraryNotifier extends StateNotifier<AsyncValue<List<Itinerary>>> {
  final ApiService _api;
  final String _tripId;

  ItineraryNotifier(this._api, this._tripId) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final items = await _api.getItineraries(_tripId);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Itinerary item) async {
    try {
      final created = await _api.createItinerary(_tripId, {
        'dayIndex': item.dayIndex,
        'time': item.time,
        'title': item.title,
        'type': item.type.name,
        'cost': item.cost,
        'note': item.note,
        'orderIndex': item.orderIndex,
      });
      state.whenData((list) => state = AsyncValue.data([...list, created]));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateItem(Itinerary item) async {
    try {
      final updated = await _api.updateItinerary(_tripId, item.id, {
        'dayIndex': item.dayIndex,
        'time': item.time,
        'title': item.title,
        'type': item.type.name,
        'cost': item.cost,
        'note': item.note,
        'orderIndex': item.orderIndex,
        'done': item.done,
      });
      state.whenData((list) {
        final newList = list.map((i) => i.id == updated.id ? updated : i).toList();
        state = AsyncValue.data(newList);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _api.deleteItinerary(_tripId, id);
      state.whenData((list) {
        state = AsyncValue.data(list.where((i) => i.id != id).toList());
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void syncFromSocket(Map<String, dynamic> data) {
    final type = data['type'] as String;
    final payload = data['payload'] as Map<String, dynamic>;

    state.whenData((list) {
      if (type == 'itinerary_created') {
        final newItem = Itinerary.fromJson(payload);
        if (!list.any((i) => i.id == newItem.id)) {
          state = AsyncValue.data([...list, newItem]);
        }
      } else if (type == 'itinerary_updated') {
        final id = payload['itineraryId'] as String;
        final changes = payload['changes'] as Map<String, dynamic>;
        final newList = list.map((i) {
          if (i.id == id) {
            final json = i.toJson()..addAll(changes);
            return Itinerary.fromJson(json);
          }
          return i;
        }).toList();
        state = AsyncValue.data(newList);
      } else if (type == 'itinerary_deleted') {
        final id = payload['itineraryId'] as String;
        state = AsyncValue.data(list.where((i) => i.id != id).toList());
      }
    });
  }
}

final itineraryNotifierProvider = StateNotifierProvider.family<ItineraryNotifier, AsyncValue<List<Itinerary>>, String>((ref, tripId) {
  return ItineraryNotifier(ref.read(apiServiceProvider), tripId);
});
