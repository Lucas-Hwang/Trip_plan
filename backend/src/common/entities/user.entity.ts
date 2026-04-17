import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Trip } from './trip.entity';
import { TripMember } from './trip-member.entity';
import { Comment } from './comment.entity';
import { Vote } from './vote.entity';
import { Notification } from './notification.entity';
import { Itinerary } from './itinerary.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  passwordHash: string;

  @Column()
  displayName: string;

  @Column({ nullable: true })
  avatarUrl: string;

  @Column({ nullable: true })
  fcmToken: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => Trip, (trip) => trip.createdBy)
  createdTrips: Trip[];

  @OneToMany(() => TripMember, (tm) => tm.user)
  tripMemberships: TripMember[];

  @OneToMany(() => Itinerary, (it) => it.createdBy)
  createdItineraries: Itinerary[];

  @OneToMany(() => Comment, (c) => c.user)
  comments: Comment[];

  @OneToMany(() => Vote, (v) => v.user)
  votes: Vote[];

  @OneToMany(() => Notification, (n) => n.user)
  notifications: Notification[];
}
