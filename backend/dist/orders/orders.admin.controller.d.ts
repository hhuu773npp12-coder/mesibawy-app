import { OrdersService } from './orders.service';
export declare class OrdersAdminController {
    private readonly orders;
    constructor(orders: OrdersService);
    list(limit?: string, category?: string, status?: string, dateFrom?: string, dateTo?: string): Promise<import("./order.entity").Order[]>;
}
