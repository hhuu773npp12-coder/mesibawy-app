import { OrdersService } from './orders.service';
import { Category } from '../pricing/pricing.service';
export declare class OrdersController {
    private readonly orders;
    constructor(orders: OrdersService);
    estimateAndCreate(body: {
        userId?: string;
        category: Category;
        distanceKm: number;
        durationMin?: number;
    }): Promise<{
        order: import("./order.entity").Order;
        estimate: {
            category: Category;
            distanceKm: number;
            breakdown: {
                base: number;
                perKm: number;
                distanceCost: number;
            };
            total: number;
            currency: string;
        };
    }>;
    createFood(req: any, body: {
        offerId: string;
        quantity: number;
        notes?: string;
    }): Promise<import("./order.entity").Order>;
    getOne(req: any, id: string): Promise<import("./order.entity").Order>;
}
