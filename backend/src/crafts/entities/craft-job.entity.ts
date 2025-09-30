import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { CraftProfile } from './craft-profile.entity';

export type CraftJobStatus = 'PENDING' | 'ACCEPTED' | 'IN_PROGRESS' | 'PAUSED' | 'COMPLETED' | 'REJECTED';

@Entity({ name: 'craft_jobs' })
export class CraftJob {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 120 })
  citizenName!: string;

  @Column({ type: 'varchar', length: 30 })
  citizenPhone!: string;

  @Column({ type: 'varchar', length: 240 })
  address!: string;

  @Column({ type: 'varchar', length: 20 })
  status!: CraftJobStatus;

  @Column({ type: 'int', default: 0 })
  timerSecondsLeft!: number;

  @Column({ type: 'int', default: 0 })
  hoursRequested!: number;

  @Column({ type: 'int', default: 0 })
  hoursAdded!: number;

  @Column({ type: 'int', default: 0 })
  pricePerHour!: number;

  @CreateDateColumn()
  createdAt!: Date;

  @ManyToOne(() => CraftProfile, (p) => p.jobs, { nullable: true, onDelete: 'SET NULL' })
  assignee?: CraftProfile | null;
}
