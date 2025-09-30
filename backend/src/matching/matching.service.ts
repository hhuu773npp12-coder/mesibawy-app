import { Injectable } from '@nestjs/common';

export interface Candidate {
  id: string;
  active: boolean;
  walletBalance: number; // IQD
  lat?: number;
  lng?: number;
}

export interface MatchOptions {
  jobLat: number;
  jobLng: number;
  maxRadiusKm?: number; // default 15
  minWallet?: number; // default 0
  limit?: number; // default 10
}

export interface RankedCandidate extends Candidate {
  distanceKm: number;
}

@Injectable()
export class MatchingService {
  distanceKm(aLat: number, aLng: number, bLat: number, bLng: number): number {
    const toRad = (d: number) => (d * Math.PI) / 180;
    const R = 6371; // km
    const dLat = toRad(bLat - aLat);
    const dLon = toRad(bLng - aLng);
    const lat1 = toRad(aLat);
    const lat2 = toRad(bLat);
    const h = Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
    return 2 * R * Math.asin(Math.min(1, Math.sqrt(h)));
  }

  filterAndRankCandidates(cands: Candidate[], opts: MatchOptions): RankedCandidate[] {
    const maxRadiusKm = opts.maxRadiusKm ?? 15;
    const minWallet = opts.minWallet ?? 0;
    const limit = opts.limit ?? 10;

    const enriched: RankedCandidate[] = [];
    for (const c of cands) {
      if (!c.active) continue;
      if (c.walletBalance < minWallet) continue;
      if (typeof c.lat !== 'number' || typeof c.lng !== 'number') continue;
      const dist = this.distanceKm(opts.jobLat, opts.jobLng, c.lat!, c.lng!);
      if (dist > maxRadiusKm) continue;
      enriched.push({ ...c, distanceKm: +dist.toFixed(3) });
    }

    enriched.sort((a, b) => {
      if (a.distanceKm !== b.distanceKm) return a.distanceKm - b.distanceKm; // الأقرب أولاً
      return b.walletBalance - a.walletBalance; // ثم الأعلى رصيداً
    });

    return enriched.slice(0, Math.max(1, limit));
  }
}
