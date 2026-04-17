import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../common/entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepo: Repository<User>,
  ) {}

  async findById(id: string) {
    const user = await this.userRepo.findOne({
      where: { id },
      select: ['id', 'email', 'displayName', 'avatarUrl', 'fcmToken', 'createdAt'],
    });
    return user;
  }

  async findByIds(ids: string[]) {
    return this.userRepo.find({
      where: ids.map((id) => ({ id })),
      select: ['id', 'email', 'displayName', 'avatarUrl'],
    });
  }
}
