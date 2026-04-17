import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { ItinerariesService } from './itineraries.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateItineraryDto } from './dto/create-itinerary.dto';
import { UpdateItineraryDto } from './dto/update-itinerary.dto';
import { ReorderItineraryDto } from './dto/reorder-itinerary.dto';

@UseGuards(JwtAuthGuard)
@Controller('trips/:tripId/itineraries')
export class ItinerariesController {
  constructor(private itinerariesService: ItinerariesService) {}

  @Post()
  create(
    @Param('tripId') tripId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateItineraryDto,
  ) {
    return this.itinerariesService.create(tripId, userId, dto);
  }

  @Get()
  findByTrip(@Param('tripId') tripId: string) {
    return this.itinerariesService.findByTrip(tripId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.itinerariesService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('tripId') tripId: string,
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateItineraryDto,
  ) {
    return this.itinerariesService.update(tripId, id, userId, dto);
  }

  @Delete(':id')
  remove(
    @Param('tripId') tripId: string,
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.itinerariesService.remove(tripId, id, userId);
  }

  @Post('reorder')
  reorder(
    @Param('tripId') tripId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: ReorderItineraryDto,
  ) {
    return this.itinerariesService.reorder(tripId, userId, dto.orderedIds);
  }
}
