import { Controller, Get, Post, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { NotificationsService } from './notifications.service';

@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsUserController {
  constructor(private readonly notifications: NotificationsService) {}

  @Get('me')
  listMine(@Req() req: any) {
    const userId = req.user?.sub as string;
    return this.notifications.listForUser(userId);
  }

  @Post('read-all')
  markAllRead(@Req() req: any) {
    const userId = req.user?.sub as string;
    return this.notifications.markAllRead(userId);
  }
}
