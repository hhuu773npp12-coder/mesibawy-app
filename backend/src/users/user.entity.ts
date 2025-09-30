import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

export type UserRole =
  | 'citizen'
  | 'taxi'
  | 'tuk_tuk'
  | 'kia_haml'
  | 'kia_passenger'
  | 'stuta'
  | 'bike'
  | 'electrician'
  | 'plumber'
  | 'ac_tech'
  | 'blacksmith'
  | 'restaurant_owner'
  | 'admin'
  | 'owner';

@Entity({ name: 'users' })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  userId: string; // system user code used across the app

  @Column({ length: 120 })
  name: string;

  @Column({ length: 20 })
  phone: string;

  @Column({ type: 'varchar', length: 32 })
  role: UserRole;

  @Column({ default: false })
  isApproved: boolean; // admin approval status

  @Column({ default: true })
  isActive: boolean;

  @Column({ type: 'int', default: 0 })
  walletBalance: number; // in IQD

  // Last known location (optional)
  @Column({ type: 'float', nullable: true })
  lastLat?: number | null;

  @Column({ type: 'float', nullable: true })
  lastLng?: number | null;

  // Vehicle owner profile (optional)
  @Column({ type: 'varchar', length: 24, nullable: true })
  vehicleType?: string | null; // taxi | tuk_tuk | kia_haml | kia_passenger | stuta | bike

  @Column({ type: 'varchar', length: 24, nullable: true })
  vehicleColor?: string | null;

  @Column({ type: 'varchar', length: 32, nullable: true })
  plateNumber?: string | null;

  @Column({ type: 'varchar', length: 256, nullable: true })
  plateImageUrl?: string | null;

  // Craft owner profile (optional)
  @Column({ type: 'varchar', length: 24, nullable: true })
  craftType?: string | null; // electrician | plumber | blacksmith | ac_tech

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
