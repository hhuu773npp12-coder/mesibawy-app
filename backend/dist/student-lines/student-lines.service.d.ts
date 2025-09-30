import { Repository } from 'typeorm';
import { StudentLine } from './student-line.entity';
export declare class StudentLinesService {
    private readonly repo;
    constructor(repo: Repository<StudentLine>);
    private weeklyPriceFor;
    private requests;
    private genId;
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
    }): {
        weeklyPrice: number;
        status: "PENDING";
        createdAt: Date;
        citizenName: string;
        citizenPhone: string;
        kind: "school" | "university";
        count: number;
        originLat: number;
        originLng: number;
        destLat: number;
        destLng: number;
        distanceKm: number;
        id: string;
    };
    listPublicRequests(): {
        id: string;
        citizenName: string;
        citizenPhone: string;
        kind: "school" | "university";
        count: number;
        originLat: number;
        originLng: number;
        destLat: number;
        destLng: number;
        distanceKm: number;
        weeklyPrice: number;
        status: "PENDING" | "APPROVED" | "REJECTED";
        createdAt: Date;
    }[];
    approvePublicRequest(id: string): {
        ok: boolean;
        error: string;
    } | {
        ok: boolean;
        error?: undefined;
    };
    rejectPublicRequest(id: string): {
        ok: boolean;
        error: string;
    } | {
        ok: boolean;
        error?: undefined;
    };
    create(data: {
        name: string;
        originArea: string;
        destinationArea: string;
        distanceKm: number;
        kind: 'school' | 'university';
    }): Promise<StudentLine>;
    list(): Promise<StudentLine[]>;
}
