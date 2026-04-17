import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TripsService } from './trips.service';
import { TripsController } from './trips.controller';
import { Trip } from '../common/entities/trip.entity';
import { TripMember } from '../common/entities/trip-member.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Trip, TripMember])],
  controllers: [TripsController],
  providers: [TripsService],
  exports: [TripsService],
})
export class TripsModule {}
