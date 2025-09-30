import { Repository } from 'typeorm';
import { MatchingService } from '../matching/matching.service';
import { CraftJob as CraftJobEntity } from './entities/craft-job.entity';
import { CraftProfile } from './entities/craft-profile.entity';
type CraftRole = 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech';
type JobStatus = 'PENDING' | 'ACCEPTED' | 'IN_PROGRESS' | 'PAUSED' | 'COMPLETED' | 'REJECTED';
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
export declare class CraftsService {
    private readonly matching;
    private readonly jobsRepo;
    private readonly profilesRepo;
    constructor(matching: MatchingService, jobsRepo: Repository<CraftJobEntity>, profilesRepo: Repository<CraftProfile>);
    list(role?: CraftRole, status?: JobStatus): Promise<CraftJob[]>;
    getById(id: string): Promise<CraftJob>;
    createRequest(input: {
        role: CraftRole;
        citizenName: string;
        citizenPhone: string;
        address: string;
        detail?: string;
        lat?: number;
        lng?: number;
        hours: number;
        pricePerHour: number;
    }): Promise<CraftJob>;
    accept(id: string, craftsman?: {
        name?: string;
        phone?: string;
    }): Promise<CraftJob>;
    reject(id: string): Promise<{
        ok: boolean;
    }>;
    start(id: string): Promise<CraftJob>;
    pause(id: string): Promise<CraftJob>;
    resume(id: string): Promise<CraftJob>;
    addHours(id: string, hours: number): Promise<CraftJob>;
    cancelByCitizen(id: string): Promise<{
        ok: boolean;
    }>;
    complete(id: string): Promise<{
        ok: boolean;
        totalHours: number;
        totalPrice: number;
        commission: number;
    }>;
    notify(id: string, message: string): Promise<{
        ok: boolean;
        to: string;
        message: string;
    }>;
    private mustFind;
    rankCandidates(candidates: Array<{
        id: string;
        active: boolean;
        walletBalance: number;
        lat?: number;
        lng?: number;
    }>, opts: {
        jobLat: number;
        jobLng: number;
        maxRadiusKm?: number;
        minWallet?: number;
        limit?: number;
    }): import("../matching/matching.service").RankedCandidate[];
    private mapEntityToDto;
}
export {};
