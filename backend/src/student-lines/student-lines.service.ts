import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { StudentLine } from './student-line.entity';

@Injectable()
export class StudentLinesService {
  constructor(
    @InjectRepository(StudentLine)
    private readonly repo: Repository<StudentLine>,
  ) {}

  private weeklyPriceFor(distanceKm: number): number {
    const d = distanceKm;
    if (d >= 1 && d <= 5) return 5000;
    if (d > 5 && d <= 8) return 10000;
    if (d > 8 && d <= 12) return 15000;
    if (d > 12 && d <= 20) return 20000;
    if (d > 20 && d <= 40) return 25000;
    if (d > 40 && d <= 50) return 30000;
    if (d > 50 && d <= 60) return 35000;
    if (d >= 70 && d <= 90) return 40000;
    if (d >= 90 && d <= 120) return 50000;
    // خارج النطاقات المحددة نعيد 0 أو نحسب بالتقريب لاحقاً
    return 0;
  }

  // In-memory store for public requests (simplified)
  private requests: Array<{
    id: string;
    citizenName: string;
    citizenPhone: string;
    kind: 'school' | 'university';
    count: number;
    originLat: number;
    originLng: number;
    destLat: number;
    destLng: number;
    distanceKm: number;
    weeklyPrice: number;
    status: 'PENDING' | 'APPROVED' | 'REJECTED';
    createdAt: Date;
  }> = [];

  private genId() {
    return 'slr_' + Math.random().toString(36).substring(2, 10);
  }

  createPublicRequest(data: {
    citizenName: string;
    citizenPhone: string;
    kind: 'school' | 'university';
    count: number;
    originLat: number;
    originLng: number;
    destLat: number;
    destLng: number;
    distanceKm: number;
  }) {
    const weeklyPrice = this.weeklyPriceFor(data.distanceKm);
    const req = { id: this.genId(), ...data, weeklyPrice, status: 'PENDING' as const, createdAt: new Date() };
    this.requests.unshift(req);
    return req;
  }

  listPublicRequests() {
    return this.requests;
  }

  approvePublicRequest(id: string) {
    const r = this.requests.find((x) => x.id === id);
    if (!r) return { ok: false, error: 'not_found' };
    r.status = 'APPROVED';
    return { ok: true };
  }

  rejectPublicRequest(id: string) {
    const r = this.requests.find((x) => x.id === id);
    if (!r) return { ok: false, error: 'not_found' };
    r.status = 'REJECTED';
    return { ok: true };
  }

  create(data: {
    name: string;
    originArea: string;
    destinationArea: string;
    distanceKm: number;
    kind: 'school' | 'university';
  }) {
    const weeklyPrice = this.weeklyPriceFor(data.distanceKm);
    const line = this.repo.create({ ...data, weeklyPrice, active: true });
    return this.repo.save(line);
  }

  list() {
    return this.repo.find({ order: { createdAt: 'DESC' } });
  }
}
