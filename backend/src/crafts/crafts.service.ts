import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MatchingService } from '../matching/matching.service';
import { CraftJob as CraftJobEntity, CraftJobStatus } from './entities/craft-job.entity';
import { CraftProfile } from './entities/craft-profile.entity';

type CraftRole = 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech';
type JobStatus = 'PENDING' | 'ACCEPTED' | 'IN_PROGRESS' | 'PAUSED' | 'COMPLETED' | 'REJECTED';

// Legacy interface kept for return shape compatibility.
export interface CraftJob {
  id: string;
  role: CraftRole;
  citizenName: string;
  citizenPhone: string;
  address: string;
  detail?: string;
  lat?: number;
  lng?: number;
  hoursRequested: number;
  hoursAdded: number;
  pricePerHour: number;
  status: JobStatus;
  timerSecondsLeft?: number;
  craftsmanName?: string;
  craftsmanPhone?: string;
}

@Injectable()
export class CraftsService {
  constructor(
    private readonly matching: MatchingService,
    @InjectRepository(CraftJobEntity) private readonly jobsRepo: Repository<CraftJobEntity>,
    @InjectRepository(CraftProfile) private readonly profilesRepo: Repository<CraftProfile>,
  ) {}

  async list(role?: CraftRole, status?: JobStatus) {
    const where: any = {};
    if (role) where['assignee'] = { craftType: role };
    if (status) where['status'] = status;
    // If role filter absent, return all regardless of assignee
    const qb = this.jobsRepo.createQueryBuilder('j').leftJoinAndSelect('j.assignee', 'a');
    if (status) qb.andWhere('j.status = :status', { status });
    if (role) qb.andWhere('a.craftType = :role', { role });
    qb.orderBy('j.createdAt', 'DESC');
    const entities = await qb.getMany();
    return entities.map(this.mapEntityToDto);
  }

  async getById(id: string) {
    const j = await this.jobsRepo.findOne({ where: { id }, relations: ['assignee'] });
    if (!j) throw new BadRequestException('Job not found');
    return this.mapEntityToDto(j);
  }

  async createRequest(input: {
    role: CraftRole;
    citizenName: string;
    citizenPhone: string;
    address: string;
    detail?: string;
    lat?: number;
    lng?: number;
    hours: number;
    pricePerHour: number;
  }) {
    const entity = this.jobsRepo.create({
      citizenName: input.citizenName,
      citizenPhone: input.citizenPhone,
      address: input.address,
      status: 'PENDING',
      timerSecondsLeft: 0,
      hoursRequested: Math.max(0, Math.floor(input.hours)),
      hoursAdded: 0,
      pricePerHour: Math.max(0, Math.floor(input.pricePerHour)),
    } as Partial<CraftJobEntity>);
    // Assign a profile by role if exists (optional step): find first matching profile
    const profile = await this.profilesRepo.findOne({ where: { craftType: input.role } });
    if (profile) (entity as any).assignee = profile;
    const saved = await this.jobsRepo.save(entity);
    const fresh = await this.jobsRepo.findOne({ where: { id: saved.id }, relations: ['assignee'] });
    if (!fresh) throw new BadRequestException('Failed to create job');
    return this.mapEntityToDto(fresh);
  }

  async accept(id: string, craftsman?: { name?: string; phone?: string }) {
    const j = await this.mustFind(id);
    if (j.status !== 'PENDING') throw new BadRequestException('Invalid state');
    j.status = 'ACCEPTED';
    j.timerSecondsLeft = (j.hoursRequested + j.hoursAdded) * 3600;
    await this.jobsRepo.save(j);
    // Optionally store craftsman info into assignee profile fields if needed (skipped to keep schema minimal)
    return this.mapEntityToDto(j);
  }

  async reject(id: string) {
    const j = await this.mustFind(id);
    if (j.status === 'COMPLETED' || j.status === 'REJECTED') throw new BadRequestException('Invalid state');
    j.status = 'REJECTED';
    await this.jobsRepo.save(j);
    return { ok: true };
  }

  async start(id: string) {
    const j = await this.mustFind(id);
    if (j.status !== 'ACCEPTED' && j.status !== 'PAUSED') throw new BadRequestException('Invalid state');
    if (!j.timerSecondsLeft || j.timerSecondsLeft <= 0) j.timerSecondsLeft = (j.hoursRequested + j.hoursAdded) * 3600;
    j.status = 'IN_PROGRESS';
    await this.jobsRepo.save(j);
    return this.mapEntityToDto(j);
  }

  async pause(id: string) {
    const j = await this.mustFind(id);
    if (j.status !== 'IN_PROGRESS') throw new BadRequestException('Invalid state');
    j.status = 'PAUSED';
    await this.jobsRepo.save(j);
    return this.mapEntityToDto(j);
  }

  async resume(id: string) {
    return this.start(id);
  }

  async addHours(id: string, hours: number) {
    if (!Number.isFinite(hours) || hours <= 0) throw new BadRequestException('Invalid hours');
    const j = await this.mustFind(id);
    j.hoursAdded += Math.floor(hours);
    if (j.timerSecondsLeft && j.timerSecondsLeft > 0) j.timerSecondsLeft += Math.floor(hours * 3600);
    await this.jobsRepo.save(j);
    return this.mapEntityToDto(j);
  }

  async cancelByCitizen(id: string) {
    const j = await this.mustFind(id);
    if (j.status === 'IN_PROGRESS' || j.status === 'COMPLETED' || j.status === 'REJECTED') {
      throw new BadRequestException('Cannot cancel at this stage');
    }
    j.status = 'REJECTED';
    await this.jobsRepo.save(j);
    return { ok: true };
  }

  async complete(id: string) {
    const j = await this.mustFind(id);
    if (j.status === 'REJECTED' || j.status === 'COMPLETED') throw new BadRequestException('Invalid state');
    j.status = 'COMPLETED';
    await this.jobsRepo.save(j);
    const totalHours = j.hoursRequested + j.hoursAdded;
    const totalPrice = totalHours * j.pricePerHour;
    const commission = Math.floor(totalPrice * 0.1);
    // TODO: integrate OwnerService.addToWallet once module exports are wired
    // Temporary no-op to avoid boot failure due to missing OwnerService in CraftsModule
    // this.owner.addToWallet(commission);
    return { ok: true, totalHours, totalPrice, commission };
  }

  async notify(id: string, message: string) {
    const j = await this.mustFind(id);
    return { ok: true, to: j.citizenPhone, message };
  }

  private async mustFind(id: string) {
    const j = await this.jobsRepo.findOne({ where: { id }, relations: ['assignee'] });
    if (!j) throw new BadRequestException('Job not found');
    return j;
  }

  // Ranking helper: given external candidates (craftsmen), return top matches
  rankCandidates(candidates: Array<{ id: string; active: boolean; walletBalance: number; lat?: number; lng?: number }>, opts: {
    jobLat: number;
    jobLng: number;
    maxRadiusKm?: number;
    minWallet?: number;
    limit?: number;
  }) {
    return this.matching.filterAndRankCandidates(candidates, opts);
  }

  private mapEntityToDto = (e: CraftJobEntity): CraftJob => ({
    id: e.id,
    role: (e.assignee?.craftType as CraftRole) ?? 'electrician',
    citizenName: e.citizenName,
    citizenPhone: e.citizenPhone,
    address: e.address,
    hoursRequested: e.hoursRequested,
    hoursAdded: e.hoursAdded,
    pricePerHour: e.pricePerHour,
    status: e.status as JobStatus,
    timerSecondsLeft: e.timerSecondsLeft ?? 0,
  });
}
