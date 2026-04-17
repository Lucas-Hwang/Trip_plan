import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification, NotificationType } from '../common/entities/notification.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private notificationRepo: Repository<Notification>,
  ) {}

  async create(data: {
    userId: string;
    type: NotificationType;
    title: string;
    body: string;
    extraData?: Record<string, any>;
  }) {
    const notification = this.notificationRepo.create({
      userId: data.userId,
      type: data.type,
      title: data.title,
      body: data.body,
      data: data.extraData || {},
    });
    return this.notificationRepo.save(notification);
  }

  async findByUser(userId: string) {
    return this.notificationRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async markAsRead(userId: string, notificationId: string) {
    await this.notificationRepo.update(
      { id: notificationId, userId },
      { isRead: true },
    );
    return { success: true };
  }

  async markAllAsRead(userId: string) {
    await this.notificationRepo.update(
      { userId, isRead: false },
      { isRead: true },
    );
    return { success: true };
  }
}
