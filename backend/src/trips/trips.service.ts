import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Trip } from '../common/entities/trip.entity';
import { TripMember, TripRole } from '../common/entities/trip-member.entity';
import { User } from '../common/entities/user.entity';
import { CreateTripDto } from './dto/create-trip.dto';
import { UpdateTripDto } from './dto/update-trip.dto';

function generateInviteCode(): string {
  return Math.random().toString(36).substring(2, 8).toUpperCase();
}

@Injectable()
export class TripsService {
  constructor(
    @InjectRepository(Trip)
    private tripRepo: Repository<Trip>,
    @InjectRepository(TripMember)
    private memberRepo: Repository<TripMember>,
  ) {}

  async create(userId: string, dto: CreateTripDto) {
    const inviteCode = generateInviteCode();
    const trip = this.tripRepo.create({
      ...dto,
      startDate: new Date(dto.startDate),
      endDate: new Date(dto.endDate),
      createdById: userId,
      inviteCode,
    });
    await this.tripRepo.save(trip);

    await this.memberRepo.save({
      tripId: trip.id,
      userId,
      role: TripRole.OWNER,
    });

    return this.findOne(trip.id, userId);
  }

  async findAll(userId: string) {
    const memberships = await this.memberRepo.find({
      where: { userId },
      relations: ['trip', 'trip.createdBy'],
    });
    return memberships.map((m) => m.trip);
  }

  async findOne(id: string, userId: string) {
    const membership = await this.memberRepo.findOne({
      where: { tripId: id, userId },
    });
    if (!membership) throw new ForbiddenException('Not a member of this trip');

    const trip = await this.tripRepo.findOne({
      where: { id },
      relations: ['members', 'members.user', 'itineraries', 'createdBy'],
    });
    if (!trip) throw new NotFoundException();

    return {
      ...trip,
      myRole: membership.role,
    };
  }

  async update(id: string, userId: string, dto: UpdateTripDto) {
    await this.ensureRole(id, userId, [TripRole.OWNER, TripRole.EDITOR]);

    const updateData: any = { ...dto };
    if (dto.startDate) updateData.startDate = new Date(dto.startDate);
    if (dto.endDate) updateData.endDate = new Date(dto.endDate);

    await this.tripRepo.update(id, updateData);
    return this.findOne(id, userId);
  }

  async joinByCode(userId: string, inviteCode: string) {
    const trip = await this.tripRepo.findOneBy({ inviteCode });
    if (!trip) throw new NotFoundException('Invalid invite code');

    const existing = await this.memberRepo.findOneBy({
      tripId: trip.id,
      userId,
    });
    if (existing) throw new ConflictException('Already a member');

    await this.memberRepo.save({
      tripId: trip.id,
      userId,
      role: TripRole.EDITOR,
    });

    return this.findOne(trip.id, userId);
  }

  async removeMember(tripId: string, ownerId: string, targetUserId: string) {
    await this.ensureRole(tripId, ownerId, [TripRole.OWNER]);

    const target = await this.memberRepo.findOneBy({
      tripId,
      userId: targetUserId,
    });
    if (!target) throw new NotFoundException('Member not found');

    await this.memberRepo.delete({ tripId, userId: targetUserId });
    return { success: true };
  }

  async getMembers(tripId: string, userId: string) {
    const membership = await this.memberRepo.findOneBy({ tripId, userId });
    if (!membership) throw new ForbiddenException();

    return this.memberRepo.find({
      where: { tripId },
      relations: ['user'],
    });
  }

  async getMemberUserIds(tripId: string, excludeUserId?: string): Promise<string[]> {
    const members = await this.memberRepo.find({ where: { tripId } });
    return members
      .map((m) => m.userId)
      .filter((id) => id !== excludeUserId);
  }

  private async ensureRole(
    tripId: string,
    userId: string,
    allowed: TripRole[],
  ) {
    const membership = await this.memberRepo.findOneBy({ tripId, userId });
    if (!membership || !allowed.includes(membership.role)) {
      throw new ForbiddenException('Insufficient permissions');
    }
  }
}
