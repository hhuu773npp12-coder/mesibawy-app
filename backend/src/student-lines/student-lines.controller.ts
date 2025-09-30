import { Body, Controller, Get, Post, UseGuards, Param } from '@nestjs/common';
import { StudentLinesService } from './student-lines.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('admin/student-lines')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'owner')
export class StudentLinesController {
  constructor(private readonly lines: StudentLinesService) {}

  @Post()
  create(
    @Body()
    body: {
      name: string;
      originArea: string;
      destinationArea: string;
      distanceKm: number;
      kind: 'school' | 'university';
    },
  ) {
    return this.lines.create(body);
  }

  @Get()
  list() {
    return this.lines.list();
  }

  // Public: citizen submits a student line request
  @Post('/public/request')
  createPublic(
    @Body()
    body: {
      citizenName: string;
      citizenPhone: string;
      kind: 'school' | 'university';
      count: number;
      originLat: number;
      originLng: number;
      destLat: number;
      destLng: number;
      distanceKm: number;
    },
  ) {
    return this.lines.createPublicRequest(body);
  }

  // Public: list submitted requests (temporary)
  @Get('/public/requests')
  listPublic() {
    return this.lines.listPublicRequests();
  }

  @Post('/public/:id/approve')
  approvePublic(@Body('adminId') _adminId: string, @Param('id') id: string) {
    // adminId reserved for auditing in future
    return this.lines.approvePublicRequest(id);
  }

  @Post('/public/:id/reject')
  rejectPublic(@Body('adminId') _adminId: string, @Param('id') id: string) {
    return this.lines.rejectPublicRequest(id);
  }
}
