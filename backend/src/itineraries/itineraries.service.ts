import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Itinerary } from '../common/entities/itinerary.entity';
import { TripMember, TripRole } from '../common/entities/trip-member.entity';
import { CreateItineraryDto } from './dto/create-itinerary.dto';
import { UpdateItineraryDto } from './dto/update-itinerary.dto';

@Injectable()
export class ItinerariesService {
  constructor(
    @InjectRepository(Itinerary)
    private itineraryRepo: Repository<Itinerary>,
    @InjectRepository(TripMember)
    private memberRepo: Repository<TripMember>,
  ) {}

  async create(tripId: string, userId: string, dto: CreateItineraryDto) {
    await this.ensureEditor(tripId, userId);

    const count = await this.itineraryRepo.count({ where: { tripId, dayIndex: dto.dayIndex } });
    const itinerary = this.itineraryRepo.create({
      ...dto,
      tripId,
      createdById: userId,
      orderIndex: dto.orderIndex ?? count,
    });
    await this.itineraryRepo.save(itinerary);
    return this.findOne(itinerary.id);
  }

  async findByTrip(tripId: string) {
    return this.itineraryRepo.find({
      where: { tripId },
      order: { dayIndex: 'ASC', orderIndex: 'ASC' },
    });
  }

  async findOne(id: string) {
    const itinerary = await this.itineraryRepo.findOne({
      where: { id },
      relations: ['comments', 'comments.user', 'votes', 'votes.user', 'createdBy'],
    });
    if (!itinerary) throw new NotFoundException();
    return itinerary;
  }

  async update(tripId: string, id: string, userId: string, dto: UpdateItineraryDto) {
    await this.ensureEditor(tripId, userId);
    const itinerary = await this.itineraryRepo.findOneBy({ id, tripId });
    if (!itinerary) throw new NotFoundException();

    Object.assign(itinerary, dto);
    await this.itineraryRepo.save(itinerary);
    return this.findOne(id);
  }

  async remove(tripId: string, id: string, userId: string) {
    await this.ensureEditor(tripId, userId);
    const result = await this.itineraryRepo.delete({ id, tripId });
    if (result.affected === 0) throw new NotFoundException();
    return { success: true };
  }

  async reorder(tripId: string, userId: string, orderedIds: string[]) {
    await this.ensureEditor(tripId, userId);
    for (let i = 0; i < orderedIds.length; i++) {
      await this.itineraryRepo.update(
        { id: orderedIds[i], tripId },
        { orderIndex: i },
      );
    }
    return this.findByTrip(tripId);
  }

  private async ensureEditor(tripId: string, userId: string) {
    const member = await this.memberRepo.findOneBy({ tripId, userId });
    if (!member || member.role === TripRole.VIEWER) {
      throw new ForbiddenException('Insufficient permissions');
    }
  }
}
