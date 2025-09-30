import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { EnergyOffer } from './energy-offer.entity';

@Entity({ name: 'energy_offer_images' })
export class EnergyOfferImage {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 500 })
  url!: string;

  @ManyToOne(() => EnergyOffer, (offer) => offer.images, { onDelete: 'CASCADE' })
  offer!: EnergyOffer;
}
