import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Trip } from './trip.entity';

export enum TripRole {
  OWNER = 'owner',
  EDITOR = 'editor',
  VIEWER = 'viewer',
}

@Entity('trip_members')
export class TripMember {
  @PrimaryColumn()
  tripId: string;

  @PrimaryColumn()
  userId: string;

  @Column({
    type: 'enum',
    enum: TripRole,
    default: TripRole.EDITOR,
  })
  role: TripRole;

  @CreateDateColumn()
  joinedAt: Date;

  @ManyToOne(() => Trip, (trip) => trip.members, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'tripId' })
  trip: Trip;

  @ManyToOne(() => User, (user) => user.tripMemberships, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;
}
