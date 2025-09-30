import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { Campaign } from './campaign.entity';
import { User } from '../users/user.entity';

export type CampaignBookingStatus = 'BOOKED' | 'CANCELLED';

@Entity({ name: 'campaign_bookings' })
export class CampaignBooking {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Campaign, { eager: true, onDelete: 'CASCADE' })
  campaign: Campaign;

  @ManyToOne(() => User, { eager: true, onDelete: 'CASCADE' })
  user: User;

  @Column({ type: 'varchar', length: 16, default: 'BOOKED' })
  status: CampaignBookingStatus;

  @CreateDateColumn()
  createdAt: Date;
}
