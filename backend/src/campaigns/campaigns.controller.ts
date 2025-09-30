import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { CampaignsService } from './campaigns.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('admin/campaigns')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'owner')
export class CampaignsController {
  constructor(private readonly campaigns: CampaignsService) {}

  @Post()
  create(
    @Body()
    body: { title: string; originArea: string; seatsTotal: number; pricePerSeat: number },
  ) {
    return this.campaigns.create(body);
  }

  @Get()
  list() {
    return this.campaigns.list();
  }

  @Post(':id/share')
  share(@Param('id') id: string) {
    return this.campaigns.sharePlaceholder(id);
  }

  @Get(':id/bookings')
  listBookings(@Param('id') id: string) {
    return this.campaigns.adminListBookings(id);
  }
}
