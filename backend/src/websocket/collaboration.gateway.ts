import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  namespace: 'collab',
  cors: { origin: '*' },
})
export class CollaborationGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('join-trip')
  handleJoinTrip(client: Socket, payload: { tripId: string }) {
    client.join(`trip:${payload.tripId}`);
    console.log(`Client ${client.id} joined trip:${payload.tripId}`);
    return { event: 'joined', data: payload.tripId };
  }

  @SubscribeMessage('leave-trip')
  handleLeaveTrip(client: Socket, payload: { tripId: string }) {
    client.leave(`trip:${payload.tripId}`);
    console.log(`Client ${client.id} left trip:${payload.tripId}`);
    return { event: 'left', data: payload.tripId };
  }

  @SubscribeMessage('itinerary-update')
  handleItineraryUpdate(
    client: Socket,
    payload: { tripId: string; itineraryId: string; changes: any },
  ) {
    client.broadcast.to(`trip:${payload.tripId}`).emit('trip-updated', {
      type: 'itinerary_updated',
      payload: {
        itineraryId: payload.itineraryId,
        changes: payload.changes,
      },
    });
  }

  @SubscribeMessage('itinerary-create')
  handleItineraryCreate(
    client: Socket,
    payload: { tripId: string; data: any },
  ) {
    client.broadcast.to(`trip:${payload.tripId}`).emit('trip-updated', {
      type: 'itinerary_created',
      payload: payload.data,
    });
  }

  @SubscribeMessage('itinerary-delete')
  handleItineraryDelete(
    client: Socket,
    payload: { tripId: string; itineraryId: string },
  ) {
    client.broadcast.to(`trip:${payload.tripId}`).emit('trip-updated', {
      type: 'itinerary_deleted',
      payload: { itineraryId: payload.itineraryId },
    });
  }

  @SubscribeMessage('comment-added')
  handleCommentAdded(
    client: Socket,
    payload: { tripId: string; itineraryId: string; comment: any },
  ) {
    client.broadcast.to(`trip:${payload.tripId}`).emit('trip-updated', {
      type: 'comment_added',
      payload: {
        itineraryId: payload.itineraryId,
        comment: payload.comment,
      },
    });
  }

  @SubscribeMessage('vote-changed')
  handleVoteChanged(
    client: Socket,
    payload: { tripId: string; itineraryId: string; votes: any[] },
  ) {
    client.broadcast.to(`trip:${payload.tripId}`).emit('trip-updated', {
      type: 'vote_changed',
      payload: {
        itineraryId: payload.itineraryId,
        votes: payload.votes,
      },
    });
  }

  broadcastToTrip(tripId: string, event: string, data: any, excludeSocketId?: string) {
    if (excludeSocketId) {
      this.server.to(`trip:${tripId}`).except(excludeSocketId).emit(event, data);
    } else {
      this.server.to(`trip:${tripId}`).emit(event, data);
    }
  }
}
