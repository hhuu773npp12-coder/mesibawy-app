import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { User } from '../users/user.entity';

export type OrderStatus = 'CREATED' | 'CANCELLED' | 'COMPLETED';

@Entity({ name: 'orders' })
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { eager: true, onDelete: 'SET NULL' })
  user: User | null;

  @Column({ length: 32 })
  category: string;

  @Column({ type: 'float' })
  distanceKm: number;

  @Column({ type: 'float', nullable: true })
  durationMin: number | null;

  @Column({ type: 'int' })
  priceTotal: number; // IQD

  @Column({ type: 'varchar', length: 8, default: 'IQD' })
  currency: string;

  @Column({ type: 'json', nullable: true })
  breakdown: any;

  @Column({ type: 'varchar', length: 16, default: 'CREATED' })
  status: OrderStatus;

  @CreateDateColumn()
  createdAt: Date;
}
