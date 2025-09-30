import { StudentLinesService } from './student-lines.service';
export declare class StudentLinesController {
    private readonly lines;
    constructor(lines: StudentLinesService);
    create(body: {
        name: string;
        originArea: string;
        destinationArea: string;
        distanceKm: number;
        kind: 'school' | 'university';
    }): Promise<import("./student-line.entity").StudentLine>;
    list(): Promise<import("./student-line.entity").StudentLine[]>;
    createPublic(body: {
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
    listPublic(): {
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
    approvePublic(_adminId: string, id: string): {
        ok: boolean;
        error: string;
    } | {
        ok: boolean;
        error?: undefined;
    };
    rejectPublic(_adminId: string, id: string): {
        ok: boolean;
        error: string;
    } | {
        ok: boolean;
        error?: undefined;
    };
}
