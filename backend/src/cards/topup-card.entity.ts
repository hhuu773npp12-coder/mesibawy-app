import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'topup_cards' })
export class TopupCard {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  code: string; // 10-digit or alphanumeric code

  @Column({ type: 'int', default: 10000 })
  amount: number;

  @Column({ default: false })
  used: boolean;

  @Column({ type: 'uuid', nullable: true })
  usedByUserId: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
