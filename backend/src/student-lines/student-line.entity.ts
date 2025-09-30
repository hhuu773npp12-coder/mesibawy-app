import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'student_lines' })
export class StudentLine {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 160 })
  name: string; // اسم المدرسة/الجامعة

  @Column({ length: 160 })
  originArea: string; // منطقة انطلاق تقريبية

  @Column({ length: 160 })
  destinationArea: string; // منطقة المدرسة/الجامعة

  @Column({ type: 'float' })
  distanceKm: number; // المسافة التقديرية بالكيلومترات

  @Column({ length: 16 })
  kind: 'school' | 'university';

  @Column({ type: 'int' })
  weeklyPrice: number; // السعر بالأسبوع بحسب المسافة

  @Column({ default: true })
  active: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
