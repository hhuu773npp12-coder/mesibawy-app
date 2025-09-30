import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

export type DriverJobStatus = 'PENDING' | 'ACCEPTED' | 'IN_PROGRESS' | 'COMPLETED' | 'REJECTED';
export type DriverRole = 'taxi' | 'tuk_tuk' | 'kia_haml' | 'kia_passenger' | 'stuta' | 'bike';

@Entity({ name: 'driver_jobs' })
export class DriverJob {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 120 })
  citizenName!: string;

  @Column({ type: 'varchar', length: 30 })
  citizenPhone!: string;

  @Column({ type: 'double precision' })
  startLat!: number;

  @Column({ type: 'double precision' })
  startLng!: number;

  @Column({ type: 'double precision' })
  destLat!: number;

  @Column({ type: 'double precision' })
  destLng!: number;

  @Column({ type: 'int' })
  price!: number;

  // Optional fields for bike delivery jobs
  @Column({ type: 'int', nullable: true })
  totalPrice?: number | null;

  @Column({ type: 'int', nullable: true })
  deliveryPrice?: number | null;

  @Column({ type: 'varchar', length: 20 })
  status!: DriverJobStatus;

  @Column({ type: 'varchar', length: 20 })
  role!: DriverRole;

  @Column({ type: 'uuid', nullable: true })
  driverUserId?: string | null;

  @CreateDateColumn()
  createdAt!: Date;
}
