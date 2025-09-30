import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { CraftsService } from './crafts.service';

@Controller('crafts')
export class CraftsController {
  constructor(private readonly crafts: CraftsService) {}

  @Get('jobs')
  list(
    @Query('role') role?: 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech',
    @Query('status') status?: 'PENDING' | 'ACCEPTED' | 'IN_PROGRESS' | 'PAUSED' | 'COMPLETED' | 'REJECTED',
  ) {
    return this.crafts.list(role, status) as any;
  }

  // Citizen creates a new craft request
  @Post()
  create(@Body() body: {
    role: 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech';
    citizenName: string;
    citizenPhone: string;
    address: string;
    detail?: string;
    lat?: number;
    lng?: number;
    hours: number;
    pricePerHour: number;
  }) {
    return this.crafts.createRequest(body) as any;
  }

  @Get(':id')
  getOne(@Param('id') id: string) {
    return this.crafts.getById(id) as any;
  }

  @Post(':id/accept')
  accept(
    @Param('id') id: string,
    @Body() body: { craftsmanName?: string; craftsmanPhone?: string },
  ) {
    return this.crafts.accept(id, { name: body?.craftsmanName, phone: body?.craftsmanPhone }) as any;
  }

  @Post(':id/reject')
  reject(@Param('id') id: string) {
    return this.crafts.reject(id) as any;
  }

  @Post(':id/start')
  start(@Param('id') id: string) {
    return this.crafts.start(id) as any;
  }

  @Post(':id/pause')
  pause(@Param('id') id: string) {
    return this.crafts.pause(id) as any;
  }

  @Post(':id/resume')
  resume(@Param('id') id: string) {
    return this.crafts.resume(id) as any;
  }

  @Post(':id/add-hours')
  addHours(@Param('id') id: string, @Body() body: { hours: number }) {
    return this.crafts.addHours(id, body.hours) as any;
  }

  // Alias for citizen adding hours
  @Post(':id/add-hours-citizen')
  addHoursCitizen(@Param('id') id: string, @Body() body: { hours: number }) {
    return this.crafts.addHours(id, body.hours) as any;
  }

  @Post(':id/complete')
  complete(@Param('id') id: string) {
    return this.crafts.complete(id) as any;
  }

  @Post(':id/cancel')
  cancel(@Param('id') id: string) {
    return this.crafts.cancelByCitizen(id) as any;
  }

  @Post(':id/notify')
  notify(@Param('id') id: string, @Body() body: { message: string }) {
    return this.crafts.notify(id, body.message) as any;
  }
}
