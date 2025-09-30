import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './notifications.controller';
import { NotificationsUserController } from './notifications.user.controller';
import { NotificationEntity } from './notification.entity';
import { User } from '../users/user.entity';

@Module({
  imports: [ConfigModule, TypeOrmModule.forFeature([NotificationEntity, User])],
  providers: [NotificationsService],
  controllers: [NotificationsController, NotificationsUserController],
  exports: [NotificationsService],
})
export class NotificationsModule {}
