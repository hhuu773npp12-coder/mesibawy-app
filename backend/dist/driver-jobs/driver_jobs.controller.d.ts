import { DriverJobsService } from './driver_jobs.service';
export declare class DriverJobsController {
    private readonly svc;
    constructor(svc: DriverJobsService);
    list(role?: 'taxi' | 'tuk_tuk' | 'kia_haml' | 'stuta', status?: 'PENDING' | 'ACCEPTED' | 'COMPLETED' | 'REJECTED'): any;
    accept(id: string): any;
    reject(id: string): any;
    complete(id: string): any;
    notifyAdmin(id: string): any;
    notifyArrived(id: string): any;
    notifyArrivedRestaurant(id: string): any;
    notifyPickedUp(id: string, body: {
        driverName?: string;
    }): Promise<{
        ok: boolean;
        to: string;
        message: string;
    }>;
    notifyArrivedCitizen(id: string): any;
}
