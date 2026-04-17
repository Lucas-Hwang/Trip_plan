import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { TripsService } from './trips.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateTripDto } from './dto/create-trip.dto';
import { UpdateTripDto } from './dto/update-trip.dto';
import { JoinTripDto } from './dto/join-trip.dto';

@UseGuards(JwtAuthGuard)
@Controller('trips')
export class TripsController {
  constructor(private tripsService: TripsService) {}

  @Post()
  create(@CurrentUser('id') userId: string, @Body() dto: CreateTripDto) {
    return this.tripsService.create(userId, dto);
  }

  @Get()
  findAll(@CurrentUser('id') userId: string) {
    return this.tripsService.findAll(userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @CurrentUser('id') userId: string) {
    return this.tripsService.findOne(id, userId);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateTripDto,
  ) {
    return this.tripsService.update(id, userId, dto);
  }

  @Post('join')
  joinByCode(
    @CurrentUser('id') userId: string,
    @Body() dto: JoinTripDto,
  ) {
    return this.tripsService.joinByCode(userId, dto.inviteCode);
  }

  @Delete(':id/members/:userId')
  removeMember(
    @Param('id') tripId: string,
    @Param('userId') targetUserId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.tripsService.removeMember(tripId, userId, targetUserId);
  }

  @Get(':id/members')
  getMembers(@Param('id') tripId: string, @CurrentUser('id') userId: string) {
    return this.tripsService.getMembers(tripId, userId);
  }
}
