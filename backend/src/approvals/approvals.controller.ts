import { Body, Controller, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { ApprovalsService } from './approvals.service';

class CreateApprovalBody {
  userId: string;
}

class DecisionBody {
  adminId: string;
  note?: string;
}

@Controller('approvals')
export class ApprovalsController {
  constructor(private readonly approvals: ApprovalsService) {}

  @Get()
  list(@Query('status') status?: string) {
    // Cast to known statuses in service
    return this.approvals.list(status as any);
  }

  @Post()
  create(@Body() body: CreateApprovalBody) {
    return this.approvals.createForUser(body.userId);
  }

  @Patch(':id/approve')
  approve(@Param('id') id: string, @Body() body: DecisionBody) {
    return this.approvals.approve(id, body.adminId, body.note);
  }

  @Patch(':id/reject')
  reject(@Param('id') id: string, @Body() body: DecisionBody) {
    return this.approvals.reject(id, body.adminId, body.note);
  }
}
