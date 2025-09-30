export type DriverJobStatus = 'PENDING' | 'ACCEPTED' | 'IN_PROGRESS' | 'COMPLETED' | 'REJECTED';
export type DriverRole = 'taxi' | 'tuk_tuk' | 'kia_haml' | 'kia_passenger' | 'stuta' | 'bike';
export declare class DriverJob {
    id: string;
    citizenName: string;
    citizenPhone: string;
    startLat: number;
    startLng: number;
    destLat: number;
    destLng: number;
    price: number;
    totalPrice?: number | null;
    deliveryPrice?: number | null;
    status: DriverJobStatus;
    role: DriverRole;
    driverUserId?: string | null;
    createdAt: Date;
}
