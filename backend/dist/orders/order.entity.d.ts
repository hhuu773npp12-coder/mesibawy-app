import { User } from '../users/user.entity';
export type OrderStatus = 'CREATED' | 'CANCELLED' | 'COMPLETED';
export declare class Order {
    id: string;
    user: User | null;
    category: string;
    distanceKm: number;
    durationMin: number | null;
    priceTotal: number;
    currency: string;
    breakdown: any;
    status: OrderStatus;
    createdAt: Date;
}
