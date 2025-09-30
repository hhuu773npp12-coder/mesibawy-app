import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StudentLine } from './student-line.entity';
import { StudentLinesService } from './student-lines.service';
import { StudentLinesController } from './student-lines.controller';

@Module({
  imports: [TypeOrmModule.forFeature([StudentLine])],
  controllers: [StudentLinesController],
  providers: [StudentLinesService],
  exports: [StudentLinesService],
})
export class StudentLinesModule {}
