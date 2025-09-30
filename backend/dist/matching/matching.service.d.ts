export interface Candidate {
    id: string;
    active: boolean;
    walletBalance: number;
    lat?: number;
    lng?: number;
}
export interface MatchOptions {
    jobLat: number;
    jobLng: number;
    maxRadiusKm?: number;
    minWallet?: number;
    limit?: number;
}
export interface RankedCandidate extends Candidate {
    distanceKm: number;
}
export declare class MatchingService {
    distanceKm(aLat: number, aLng: number, bLat: number, bLng: number): number;
    filterAndRankCandidates(cands: Candidate[], opts: MatchOptions): RankedCandidate[];
}
