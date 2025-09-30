import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MatchingService } from '../matching/matching.service';
import { OwnerService } from '../owner/owner.service';
import { DriverJob as DriverJobEntity } from './entities/driver-job.entity';

type DriverRole = 'taxi' | 'tuk_tuk' | 'kia_haml' | 'stuta' | 'bike';
type JobStatus = 'PENDING' | 'ACCEPTED' | 'COMPLETED' | 'REJECTED';

export interface DriverJob {
  id: string;
  role: DriverRole;
  citizenName: string;
  citizenPhone: string;
  // Pricing
  price: number; // legacy: used for non-bike roles (fare)
  totalPrice?: number; // total order price (used for bike)
  deliveryPrice?: number; // delivery fee price (used for bike)
  startLat: number;
  startLng: number;
  destLat: number;
  destLng: number;
  status: JobStatus;
}

@Injectable()
export class DriverJobsService {
  constructor(
    private readonly owner: OwnerService,
    private readonly matching: MatchingService,
    @InjectRepository(DriverJobEntity) private readonly jobsRepo: Repository<DriverJobEntity>,
  ) {}

  async list(role?: DriverRole, status?: JobStatus) {
    const where: any = {};
    if (role) where.role = role;
    if (status) where.status = status;
    const entities = await this.jobsRepo.find({ where, order: { createdAt: 'DESC' } });
    return entities.map(this.mapEntityToDto);
  }

  async accept(id: string) {
    const j = await this.mustFind(id);
    if (j.status !== 'PENDING') throw new BadRequestException('Invalid state');
    j.status = 'ACCEPTED';
    await this.jobsRepo.save(j);
    return this.mapEntityToDto(j);
  }

  async reject(id: string) {
    const j = await this.mustFind(id);
    if (j.status === 'COMPLETED' || j.status === 'REJECTED') throw new BadRequestException('Invalid state');
    j.status = 'REJECTED';
    await this.jobsRepo.save(j);
    return { ok: true };
  }

  async complete(id: string) {
    const j = await this.mustFind(id);
    if (j.status !== 'ACCEPTED') throw new BadRequestException('Invalid state');
    j.status = 'COMPLETED';
    await this.jobsRepo.save(j);
    let commission = 0;
    let total = j.price;
    if (j.role === 'bike') {
      const totalPrice = j.totalPrice ?? 0;
      const deliveryPrice = j.deliveryPrice ?? 0;
      commission = Math.max(0, Math.floor(totalPrice - deliveryPrice * 0.9));
      total = totalPrice;
    } else {
      commission = Math.floor(j.price * 0.1);
      total = j.price;
    }
    this.owner.addToWallet(commission);
    return { ok: true, totalPrice: total, commission };
  }

  async notifyAdminOnReject(id: string) {
    const j = await this.mustFind(id);
    return { ok: true, to: 'admin', jobId: j.id, message: 'تم رفض الرحلة من السائق' };
  }

  async notifyCitizenArrived(id: string) {
    const j = await this.mustFind(id);
    return { ok: true, to: j.citizenPhone, message: 'لقد وصل السائق إلى نقطة الانطلاق' };
  }

  // Bike-specific notifications
  async notifyArrivedAtRestaurant(id: string) {
    const j = await this.mustFind(id);
    return { ok: true, to: j.citizenPhone, message: 'وصل السائق إلى المطعم' };
  }

  async notifyPickedUp(id: string, driverName: string) {
    const j = await this.mustFind(id);
    const name = driverName?.trim() || 'السائق';
    return { ok: true, to: j.citizenPhone, message: `تم استلام طلبك من قبل ${name}` };
  }

  async notifyArrivedToCitizen(id: string) {
    const j = await this.mustFind(id);
    return { ok: true, to: j.citizenPhone, message: 'تم وصول السائق إلى موقعك' };
  }

  private async mustFind(id: string) {
    const j = await this.jobsRepo.findOne({ where: { id } });
    if (!j) throw new BadRequestException('Job not found');
    return j;
  }

  // Ranking helper for drivers near pickup location
  rankDrivers(candidates: Array<{ id: string; active: boolean; walletBalance: number; lat?: number; lng?: number }>, opts: {
    startLat: number;
    startLng: number;
    maxRadiusKm?: number;
    minWallet?: number;
    limit?: number;
  }) {
    return this.matching.filterAndRankCandidates(candidates, {
      jobLat: opts.startLat,
      jobLng: opts.startLng,
      maxRadiusKm: opts.maxRadiusKm,
      minWallet: opts.minWallet,
      limit: opts.limit,
    });
  }

  // Enforce max allowed total for bike orders (40,000 IQD per person)
  enforceBikePriceCap(totalPriceIqD: number): boolean {
    return totalPriceIqD <= 40000;
  }

  private mapEntityToDto = (e: DriverJobEntity): DriverJob => ({
    id: e.id,
    role: e.role as DriverRole,
    citizenName: e.citizenName,
    citizenPhone: e.citizenPhone,
    price: e.price,
    totalPrice: e.totalPrice ?? undefined,
    deliveryPrice: e.deliveryPrice ?? undefined,
    startLat: e.startLat,
    startLng: e.startLng,
    destLat: e.destLat,
    destLng: e.destLng,
    status: e.status as JobStatus,
  });
}
