import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VotesService } from './votes.service';
import { VotesController } from './votes.controller';
import { Vote } from '../common/entities/vote.entity';
import { TripMember } from '../common/entities/trip-member.entity';
import { Itinerary } from '../common/entities/itinerary.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Vote, TripMember, Itinerary])],
  controllers: [VotesController],
  providers: [VotesService],
  exports: [VotesService],
})
export class VotesModule {}
