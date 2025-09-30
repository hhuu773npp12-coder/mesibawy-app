import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { User } from '../users/user.entity';

export type WalletTxnType = 'TOPUP' | 'DEBIT' | 'CREDIT' | 'FEE';

@Entity({ name: 'wallet_transactions' })
export class WalletTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { eager: true, onDelete: 'CASCADE' })
  user: User;

  @Column({ type: 'int' })
  amount: number; // in IQD; positive for credit, negative for debit

  @Column({ type: 'varchar', length: 16 })
  type: WalletTxnType;

  @Column({ type: 'varchar', length: 64, nullable: true })
  reference: string | null; // e.g., topup card code or order id

  @CreateDateColumn()
  createdAt: Date;
}
