import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Vote } from '../common/entities/vote.entity';
import { TripMember } from '../common/entities/trip-member.entity';
import { Itinerary } from '../common/entities/itinerary.entity';
import { CreateVoteDto } from './dto/create-vote.dto';

@Injectable()
export class VotesService {
  constructor(
    @InjectRepository(Vote)
    private voteRepo: Repository<Vote>,
    @InjectRepository(TripMember)
    private memberRepo: Repository<TripMember>,
    @InjectRepository(Itinerary)
    private itineraryRepo: Repository<Itinerary>,
  ) {}

  async createOrUpdate(itineraryId: string, userId: string, dto: CreateVoteDto) {
    const itinerary = await this.itineraryRepo.findOneBy({ id: itineraryId });
    if (!itinerary) throw new NotFoundException('Itinerary not found');

    const member = await this.memberRepo.findOneBy({
      tripId: itinerary.tripId,
      userId,
    });
    if (!member) throw new NotFoundException('Not a trip member');

    let vote = await this.voteRepo.findOneBy({ itineraryId, userId });
    if (vote) {
      vote.option = dto.option;
    } else {
      vote = this.voteRepo.create({ itineraryId, userId, option: dto.option });
    }
    await this.voteRepo.save(vote);

    return this.findByItinerary(itineraryId);
  }

  async remove(itineraryId: string, userId: string) {
    await this.voteRepo.delete({ itineraryId, userId });
    return this.findByItinerary(itineraryId);
  }

  async findByItinerary(itineraryId: string) {
    return this.voteRepo.find({
      where: { itineraryId },
      relations: ['user'],
    });
  }
}
