import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { Trip } from './trip.entity';
import { User } from './user.entity';
import { Comment } from './comment.entity';
import { Vote } from './vote.entity';

export enum ItineraryType {
  FOOD = 'food',
  SIGHT = 'sight',
  SHOPPING = 'shopping',
  RELAX = 'relax',
  TRANSPORT = 'transport',
}

@Entity('itineraries')
export class Itinerary {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  tripId: string;

  @Column({ type: 'int' })
  dayIndex: number;

  @Column({ nullable: true })
  time: string;

  @Column()
  title: string;

  @Column({
    type: 'enum',
    enum: ItineraryType,
    default: ItineraryType.SIGHT,
  })
  type: ItineraryType;

  @Column({ type: 'int', default: 0 })
  cost: number;

  @Column({ type: 'text', nullable: true })
  note: string;

  @Column({ type: 'int', default: 0 })
  orderIndex: number;

  @Column({ default: false })
  done: boolean;

  @Column()
  createdById: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => Trip, (trip) => trip.itineraries, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'tripId' })
  trip: Trip;

  @ManyToOne(() => User, (user) => user.createdItineraries)
  @JoinColumn({ name: 'createdById' })
  createdBy: User;

  @OneToMany(() => Comment, (c) => c.itinerary)
  comments: Comment[];

  @OneToMany(() => Vote, (v) => v.itinerary)
  votes: Vote[];
}
