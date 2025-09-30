import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { CampaignsService } from './campaigns.service';

@Controller('campaigns')
export class CampaignsPublicController {
  constructor(private readonly campaigns: CampaignsService) {}

  @Get()
  list() {
    return this.campaigns.list();
  }

  // حجز مقعد في حملة من طرف المستخدم (عام)
  @Post(':id/book')
  book(
    @Param('id') id: string,
    @Body() body: { userId: string; count?: number; originLat?: number; originLng?: number; destLat?: number; destLng?: number },
  ) {
    const count = body.count && body.count > 0 ? Math.floor(body.count) : 1;
    // coords kept for future auditing/assignment
    return this.campaigns.book(id, body.userId, count);
  }
}
