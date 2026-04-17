import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ItinerariesService } from './itineraries.service';
import { ItinerariesController } from './itineraries.controller';
import { Itinerary } from '../common/entities/itinerary.entity';
import { TripMember } from '../common/entities/trip-member.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Itinerary, TripMember])],
  controllers: [ItinerariesController],
  providers: [ItinerariesService],
  exports: [ItinerariesService],
})
export class ItinerariesModule {}
