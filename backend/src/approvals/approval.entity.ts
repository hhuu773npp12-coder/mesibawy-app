import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../users/user.entity';

export type ApprovalStatus = 'PENDING' | 'APPROVED' | 'REJECTED';

@Entity({ name: 'approvals' })
export class Approval {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { eager: true, onDelete: 'CASCADE' })
  user: User;

  @Column({ type: 'varchar', length: 16, default: 'PENDING' })
  status: ApprovalStatus;

  @Column({ type: 'uuid', nullable: true })
  decidedByAdminId: string | null;

  @Column({ type: 'text', nullable: true })
  note: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
