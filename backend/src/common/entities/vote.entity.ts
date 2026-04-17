import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { Itinerary } from './itinerary.entity';
import { User } from './user.entity';

@Entity('votes')
@Unique(['itineraryId', 'userId'])
export class Vote {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  itineraryId: string;

  @Column()
  userId: string;

  @Column()
  option: string;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => Itinerary, (it) => it.votes, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'itineraryId' })
  itinerary: Itinerary;

  @ManyToOne(() => User, (user) => user.votes)
  @JoinColumn({ name: 'userId' })
  user: User;
}
