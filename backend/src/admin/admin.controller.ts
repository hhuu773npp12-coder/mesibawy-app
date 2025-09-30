import { Controller, Get, Param, Patch, Body, Query, UseGuards } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { User } from '../users/user.entity';
import { VerificationCode } from '../auth/verification-code.entity';
import { ApprovalsService } from '../approvals/approvals.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

class DecisionBody {
  adminId: string;
  note?: string;
}

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'owner')
export class AdminController {
  constructor(
    private readonly approvals: ApprovalsService,
    @InjectRepository(User) private readonly usersRepo: Repository<User>,
    @InjectRepository(VerificationCode)
    private readonly codesRepo: Repository<VerificationCode>,
  ) {}

  // Approvals
  @Get('approvals')
  listApprovals(@Query('status') status?: 'PENDING' | 'APPROVED' | 'REJECTED') {
    return this.approvals.list(status);
  }

  @Patch('approvals/:id/approve')
  approve(@Param('id') id: string, @Body() body: DecisionBody) {
    return this.approvals.approve(id, body.adminId, body.note);
  }

  @Patch('approvals/:id/reject')
  reject(@Param('id') id: string, @Body() body: DecisionBody) {
    return this.approvals.reject(id, body.adminId, body.note);
  }

  // Verification codes (admin visibility)
  @Get('codes')
  listCodes(@Query('phone') phone?: string) {
    const where = phone ? { phone } : {};
    return this.codesRepo.find({ where, order: { createdAt: 'DESC' }, take: 50 });
  }

  // Users listing and basic filtering
  @Get('users')
  async listUsers(
    @Query('role') role?: User['role'],
    @Query('approved') approved?: 'true' | 'false',
    @Query('q') q?: string,
  ) {
    const where: any = {};
    if (role) where.role = role;
    if (approved === 'true') where.isApproved = true;
    if (approved === 'false') where.isApproved = false;

    if (q && q.trim()) {
      const term = `%${q.trim()}%`;
      // Simple search on name or phone
      return this.usersRepo.find({
        where: [
          { ...where, name: ILike(term) },
          { ...where, phone: ILike(term) },
        ],
        order: { createdAt: 'DESC' },
        take: 100,
      });
    }

    return this.usersRepo.find({ where, order: { createdAt: 'DESC' }, take: 100 });
  }

  @Patch('users/:id/role')
  async setUserRole(
    @Param('id') id: string,
    @Body() body: { role: User['role'] },
  ) {
    await this.usersRepo.update({ id }, { role: body.role });
    return this.usersRepo.findOne({ where: { id } });
  }

  @Patch('users/:id/approve')
  async setUserApproval(
    @Param('id') id: string,
    @Body() body: { approved: boolean },
  ) {
    await this.usersRepo.update({ id }, { isApproved: !!body.approved });
    return this.usersRepo.findOne({ where: { id } });
  }
}
