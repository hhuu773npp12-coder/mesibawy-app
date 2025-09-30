import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Approval, ApprovalStatus } from './approval.entity';
import { User } from '../users/user.entity';

@Injectable()
export class ApprovalsService {
  constructor(
    @InjectRepository(Approval)
    private readonly repo: Repository<Approval>,
    @InjectRepository(User)
    private readonly usersRepo: Repository<User>,
  ) {}

  async list(status?: ApprovalStatus): Promise<Approval[]> {
    if (status) return this.repo.find({ where: { status }, order: { createdAt: 'DESC' } });
    return this.repo.find({ order: { createdAt: 'DESC' } });
  }

  async createForUser(userId: string): Promise<Approval> {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    const approval = this.repo.create({ user, status: 'PENDING' });
    return this.repo.save(approval);
  }

  async approve(id: string, adminId: string, note?: string): Promise<Approval> {
    const approval = await this.repo.findOne({ where: { id } });
    if (!approval) throw new NotFoundException('Approval not found');
    approval.status = 'APPROVED';
    approval.decidedByAdminId = adminId;
    approval.note = note ?? null;
    // mark user as approved
    if (approval.user) {
      approval.user.isApproved = true;
      await this.usersRepo.save(approval.user);
    }
    return this.repo.save(approval);
  }

  async reject(id: string, adminId: string, note?: string): Promise<Approval> {
    const approval = await this.repo.findOne({ where: { id } });
    if (!approval) throw new NotFoundException('Approval not found');
    approval.status = 'REJECTED';
    approval.decidedByAdminId = adminId;
    approval.note = note ?? null;
    // ensure user remains unapproved
    if (approval.user && approval.user.isApproved) {
      approval.user.isApproved = false;
      await this.usersRepo.save(approval.user);
    }
    return this.repo.save(approval);
  }
}
