import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { RestaurantOrder } from './restaurant-order.entity';
import { RestaurantOffer } from './restaurant-offer.entity';

@Entity({ name: 'restaurant_order_items' })
export class RestaurantOrderItem {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => RestaurantOrder, (o) => o.items, { onDelete: 'CASCADE' })
  order!: RestaurantOrder;

  @ManyToOne(() => RestaurantOffer, { eager: true, onDelete: 'RESTRICT' })
  offer!: RestaurantOffer;

  @Column({ type: 'int' })
  qty!: number;

  @Column({ type: 'int' })
  price!: number; // unit price at time of order
}
