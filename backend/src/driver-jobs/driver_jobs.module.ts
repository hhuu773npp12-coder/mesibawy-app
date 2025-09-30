import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DriverJobsController } from './driver_jobs.controller';
import { DriverJobsService } from './driver_jobs.service';
import { OwnerModule } from '../owner/owner.module';
import { MatchingModule } from '../matching/matching.module';
import { DriverJob } from './entities/driver-job.entity';

@Module({
  imports: [OwnerModule, MatchingModule, TypeOrmModule.forFeature([DriverJob])],
  controllers: [DriverJobsController],
  providers: [DriverJobsService],
})
export class DriverJobsModule {}
