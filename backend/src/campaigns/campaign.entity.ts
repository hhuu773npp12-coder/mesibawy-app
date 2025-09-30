import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'campaigns' })
export class Campaign {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 160 })
  title: string;

  @Column({ length: 160 })
  originArea: string; // منطقة الانطلاق

  @Column({ type: 'int' })
  seatsTotal: number;

  @Column({ type: 'int', default: 0 })
  seatsBooked: number;

  @Column({ type: 'int' })
  pricePerSeat: number;

  @Column({ default: true })
  active: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
