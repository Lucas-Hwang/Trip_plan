import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { CommentsService } from './comments.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateCommentDto } from './dto/create-comment.dto';

@UseGuards(JwtAuthGuard)
@Controller('itineraries/:itineraryId/comments')
export class CommentsController {
  constructor(private commentsService: CommentsService) {}

  @Post()
  create(
    @Param('itineraryId') itineraryId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateCommentDto,
  ) {
    return this.commentsService.create(itineraryId, userId, dto);
  }

  @Get()
  findByItinerary(@Param('itineraryId') itineraryId: string) {
    return this.commentsService.findByItinerary(itineraryId);
  }
}
