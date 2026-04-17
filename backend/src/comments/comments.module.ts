import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommentsService } from './comments.service';
import { CommentsController } from './comments.controller';
import { Comment } from '../common/entities/comment.entity';
import { TripMember } from '../common/entities/trip-member.entity';
import { Itinerary } from '../common/entities/itinerary.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Comment, TripMember, Itinerary])],
  controllers: [CommentsController],
  providers: [CommentsService],
  exports: [CommentsService],
})
export class CommentsModule {}
