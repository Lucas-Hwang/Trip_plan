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
import { User } from './user.entity';
import { TripMember } from './trip-member.entity';
import { Itinerary } from './itinerary.entity';

@Entity('trips')
export class Trip {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column()
  destination: string;

  @Column({ type: 'date' })
  startDate: Date;

  @Column({ type: 'date' })
  endDate: Date;

  @Column({ unique: true })
  inviteCode: string;

  @Column()
  createdById: string;

  @ManyToOne(() => User, (user) => user.createdTrips)
  @JoinColumn({ name: 'createdById' })
  createdBy: User;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => TripMember, (tm) => tm.trip)
  members: TripMember[];

  @OneToMany(() => Itinerary, (it) => it.trip)
  itineraries: Itinerary[];
}
