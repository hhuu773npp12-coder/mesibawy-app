import { CraftsService } from './crafts.service';
export declare class CraftsController {
    private readonly crafts;
    constructor(crafts: CraftsService);
    list(role?: 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech', status?: 'PENDING' | 'ACCEPTED' | 'IN_PROGRESS' | 'PAUSED' | 'COMPLETED' | 'REJECTED'): any;
    create(body: {
        role: 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech';
        citizenName: string;
        citizenPhone: string;
        address: string;
        detail?: string;
        lat?: number;
        lng?: number;
        hours: number;
        pricePerHour: number;
    }): any;
    getOne(id: string): any;
    accept(id: string, body: {
        craftsmanName?: string;
        craftsmanPhone?: string;
    }): any;
    reject(id: string): any;
    start(id: string): any;
    pause(id: string): any;
    resume(id: string): any;
    addHours(id: string, body: {
        hours: number;
    }): any;
    addHoursCitizen(id: string, body: {
        hours: number;
    }): any;
    complete(id: string): any;
    cancel(id: string): any;
    notify(id: string, body: {
        message: string;
    }): any;
}
