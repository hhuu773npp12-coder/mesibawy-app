import { OrdersService } from './orders.service';
export declare class RestaurantOrdersController {
    private readonly orders;
    constructor(orders: OrdersService);
    list(req: any, stage?: string): Promise<import("./order.entity").Order[]>;
    updateStatus(id: string, body: {
        stage: 'accepted' | 'preparing' | 'delivering' | 'completed' | 'rejected';
    }): Promise<import("./order.entity").Order>;
}
