import { Column, CreateDateColumn, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { RestaurantOrderItem } from './restaurant-order-item.entity';

export type RestaurantOrderStage =
  | 'PENDING'
  | 'APPROVED'
  | 'REJECTED_BY_RESTAURANT'
  | 'COMPLETED';

@Entity({ name: 'restaurant_orders' })
export class RestaurantOrder {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  // Owner (restaurant owner user id). In a richer model, this would be a relation to Restaurant.
  @Column({ type: 'uuid' })
  ownerUserId!: string;

  // Optional customer user id; for now, store name/phone for simplicity
  @Column({ type: 'varchar', length: 120, nullable: true })
  customerName?: string | null;

  @Column({ type: 'varchar', length: 30, nullable: true })
  customerPhone?: string | null;

  @Column({ type: 'varchar', length: 32 })
  stage!: RestaurantOrderStage;

  @Column({ type: 'int', default: 0 })
  itemsTotal!: number; // sum of items price*qty (IQD)

  @Column({ type: 'int', default: 0 })
  commission!: number; // 10%

  @Column({ type: 'int', default: 0 })
  delivery!: number; // optional delivery cost

  @CreateDateColumn()
  createdAt!: Date;

  @OneToMany(() => RestaurantOrderItem, (it: RestaurantOrderItem) => it.order, { cascade: true })
  items!: RestaurantOrderItem[];
}
