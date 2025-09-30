import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { CraftJob } from './craft-job.entity';

export type CraftType = 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech';

@Entity({ name: 'craft_profiles' })
export class CraftProfile {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  userId!: string;

  @Column({ type: 'varchar', length: 30 })
  craftType!: CraftType;

  // store uploaded photo urls as JSON array
  @Column({ type: 'jsonb', nullable: true })
  photos?: string[] | null;

  @OneToMany(() => CraftJob, (j) => j.assignee)
  jobs!: CraftJob[];
}
