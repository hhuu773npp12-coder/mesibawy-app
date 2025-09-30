import { Column, CreateDateColumn, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { EnergyOfferImage } from './energy-offer-image.entity';

@Entity({ name: 'energy_offers' })
export class EnergyOffer {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 200 })
  title!: string;

  @Column({ type: 'varchar', length: 120 })
  brand!: string;

  @Column({ type: 'text' })
  details!: string;

  // Backward compatibility single main image
  @Column({ type: 'varchar', length: 500, nullable: true })
  imageUrl?: string | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @OneToMany(() => EnergyOfferImage, (img: EnergyOfferImage) => img.offer, { cascade: true })
  images!: EnergyOfferImage[];
}
