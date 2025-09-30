import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CraftsController } from './crafts.controller';
import { CraftsService } from './crafts.service';
import { MatchingModule } from '../matching/matching.module';
import { CraftProfile } from './entities/craft-profile.entity';
import { CraftJob } from './entities/craft-job.entity';

@Module({
  imports: [MatchingModule, TypeOrmModule.forFeature([CraftProfile, CraftJob])],
  providers: [CraftsService],
  controllers: [CraftsController],
  exports: [CraftsService],
})
export class CraftsModule {}
