import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Comment } from '../common/entities/comment.entity';
import { TripMember } from '../common/entities/trip-member.entity';
import { Itinerary } from '../common/entities/itinerary.entity';
import { CreateCommentDto } from './dto/create-comment.dto';

@Injectable()
export class CommentsService {
  constructor(
    @InjectRepository(Comment)
    private commentRepo: Repository<Comment>,
    @InjectRepository(TripMember)
    private memberRepo: Repository<TripMember>,
    @InjectRepository(Itinerary)
    private itineraryRepo: Repository<Itinerary>,
  ) {}

  async create(itineraryId: string, userId: string, dto: CreateCommentDto) {
    const itinerary = await this.itineraryRepo.findOneBy({ id: itineraryId });
    if (!itinerary) throw new NotFoundException('Itinerary not found');

    const member = await this.memberRepo.findOneBy({
      tripId: itinerary.tripId,
      userId,
    });
    if (!member) throw new NotFoundException('Not a trip member');

    const comment = this.commentRepo.create({
      itineraryId,
      userId,
      content: dto.content,
    });
    await this.commentRepo.save(comment);

    return this.commentRepo.findOne({
      where: { id: comment.id },
      relations: ['user'],
    });
  }

  async findByItinerary(itineraryId: string) {
    return this.commentRepo.find({
      where: { itineraryId },
      relations: ['user'],
      order: { createdAt: 'ASC' },
    });
  }
}
