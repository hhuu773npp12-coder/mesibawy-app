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
    price: number;
    totalPrice?: number;
    deliveryPrice?: number;
    startLat: number;
    startLng: number;
    destLat: number;
    destLng: number;
    status: JobStatus;
}
export declare class DriverJobsService {
    private readonly owner;
    private readonly matching;
    private readonly jobsRepo;
    constructor(owner: OwnerService, matching: MatchingService, jobsRepo: Repository<DriverJobEntity>);
    list(role?: DriverRole, status?: JobStatus): Promise<DriverJob[]>;
    accept(id: string): Promise<DriverJob>;
    reject(id: string): Promise<{
        ok: boolean;
    }>;
    complete(id: string): Promise<{
        ok: boolean;
        totalPrice: number;
        commission: number;
    }>;
    notifyAdminOnReject(id: string): Promise<{
        ok: boolean;
        to: string;
        jobId: string;
        message: string;
    }>;
    notifyCitizenArrived(id: string): Promise<{
        ok: boolean;
        to: string;
        message: string;
    }>;
    notifyArrivedAtRestaurant(id: string): Promise<{
        ok: boolean;
        to: string;
        message: string;
    }>;
    notifyPickedUp(id: string, driverName: string): Promise<{
        ok: boolean;
        to: string;
        message: string;
    }>;
    notifyArrivedToCitizen(id: string): Promise<{
        ok: boolean;
        to: string;
        message: string;
    }>;
    private mustFind;
    rankDrivers(candidates: Array<{
        id: string;
        active: boolean;
        walletBalance: number;
        lat?: number;
        lng?: number;
    }>, opts: {
        startLat: number;
        startLng: number;
        maxRadiusKm?: number;
        minWallet?: number;
        limit?: number;
    }): import("../matching/matching.service").RankedCandidate[];
    enforceBikePriceCap(totalPriceIqD: number): boolean;
    private mapEntityToDto;
}
export {};
