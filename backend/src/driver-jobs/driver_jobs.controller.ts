import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { DriverJobsService } from './driver_jobs.service';

@Controller('driver-jobs')
export class DriverJobsController {
  constructor(private readonly svc: DriverJobsService) {}

  @Get('jobs')
  list(
    @Query('role') role?: 'taxi' | 'tuk_tuk' | 'kia_haml' | 'stuta',
    @Query('status') status?: 'PENDING' | 'ACCEPTED' | 'COMPLETED' | 'REJECTED',
  ) {
    return this.svc.list(role, status) as any;
  }

  @Post(':id/accept')
  accept(@Param('id') id: string) {
    return this.svc.accept(id) as any;
  }

  @Post(':id/reject')
  reject(@Param('id') id: string) {
    return this.svc.reject(id) as any;
  }

  @Post(':id/complete')
  complete(@Param('id') id: string) {
    return this.svc.complete(id) as any;
  }

  @Post(':id/notify-admin-reject')
  notifyAdmin(@Param('id') id: string) {
    return this.svc.notifyAdminOnReject(id) as any;
  }

  @Post(':id/notify-arrived')
  notifyArrived(@Param('id') id: string) {
    return this.svc.notifyCitizenArrived(id) as any;
  }

  // Bike-specific notifications
  @Post(':id/notify-arrived-restaurant')
  notifyArrivedRestaurant(@Param('id') id: string) {
    return this.svc.notifyArrivedAtRestaurant(id) as any;
  }

  @Post(':id/notify-picked-up')
  notifyPickedUp(@Param('id') id: string, @Body() body: { driverName?: string }) {
    return this.svc.notifyPickedUp(id, body?.driverName ?? '');
  }

  @Post(':id/notify-arrived-citizen')
  notifyArrivedCitizen(@Param('id') id: string) {
    return this.svc.notifyArrivedToCitizen(id) as any;
  }
}
