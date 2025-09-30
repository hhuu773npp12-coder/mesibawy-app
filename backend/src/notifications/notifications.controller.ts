import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'owner')
@Controller('admin/notifications')
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Post('broadcast')
  broadcast(@Body() body: { title: string; message: string; data?: Record<string, any> }) {
    return this.notifications.sendToAll(body.title, body.message, body.data);
  }

  @Post('users')
  toUsers(
    @Body()
    body: { userIds: string[]; title: string; message: string; data?: Record<string, any> },
  ) {
    return this.notifications.sendToExternalUserIds(body.userIds, body.title, body.message, body.data);
  }

  @Post('tags')
  toTags(
    @Body()
    body: {
      tags: Array<{ key: string; relation: '=' | '!=' | 'exists' | 'not_exists' | '>' | '<'; value?: string }>;
      title: string;
      message: string;
      data?: Record<string, any>;
    },
  ) {
    return this.notifications.sendToTags(body.tags, body.title, body.message, body.data);
  }
}
