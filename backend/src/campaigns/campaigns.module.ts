import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Campaign } from './campaign.entity';
import { CampaignBooking } from './campaign-booking.entity';
import { CampaignsService } from './campaigns.service';
import { CampaignsController } from './campaigns.controller';
import { CampaignsPublicController } from './campaigns.public.controller';
import { User } from '../users/user.entity';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [TypeOrmModule.forFeature([Campaign, CampaignBooking, User]), NotificationsModule],
  controllers: [CampaignsController, CampaignsPublicController],
  providers: [CampaignsService],
  exports: [CampaignsService],
})
export class CampaignsModule {}
