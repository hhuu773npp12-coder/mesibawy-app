import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'restaurant_offers' })
export class RestaurantOffer {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  ownerUserId: string; // restaurant_owner user id

  @Column({ length: 160 })
  name: string;

  @Column({ type: 'int' })
  price: number; // in IQD

  @Column({ length: 256 })
  imageUrl: string;

  // Optional location for delivery fee calculation
  @Column({ type: 'double precision', nullable: true })
  restaurantLat?: number | null;

  @Column({ type: 'double precision', nullable: true })
  restaurantLng?: number | null;

  @CreateDateColumn()
  createdAt: Date;
}
