import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'restaurant_settlements' })
export class RestaurantSettlement {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  restaurantOwnerId!: string;

  @Column({ type: 'int', default: 0 })
  ordersCount!: number;

  @Column({ type: 'int', default: 0 })
  totalAmount!: number; // total orders amount

  @Column({ type: 'int', default: 0 })
  taxAmount!: number; // 10%

  @Column({ type: 'int', default: 0 })
  dueAmount!: number; // payable to restaurant

  @Column({ type: 'timestamp', nullable: true })
  paidAt?: Date | null;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
}
