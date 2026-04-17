import { Controller, Get, Post, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { VotesService } from './votes.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateVoteDto } from './dto/create-vote.dto';

@UseGuards(JwtAuthGuard)
@Controller('itineraries/:itineraryId/votes')
export class VotesController {
  constructor(private votesService: VotesService) {}

  @Post()
  createOrUpdate(
    @Param('itineraryId') itineraryId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateVoteDto,
  ) {
    return this.votesService.createOrUpdate(itineraryId, userId, dto);
  }

  @Delete()
  remove(
    @Param('itineraryId') itineraryId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.votesService.remove(itineraryId, userId);
  }

  @Get()
  findByItinerary(@Param('itineraryId') itineraryId: string) {
    return this.votesService.findByItinerary(itineraryId);
  }
}
