import { RestaurantOrderItem } from './restaurant-order-item.entity';
export type RestaurantOrderStage = 'PENDING' | 'APPROVED' | 'REJECTED_BY_RESTAURANT' | 'COMPLETED';
export declare class RestaurantOrder {
    id: string;
    ownerUserId: string;
    customerName?: string | null;
    customerPhone?: string | null;
    stage: RestaurantOrderStage;
    itemsTotal: number;
    commission: number;
    delivery: number;
    createdAt: Date;
    items: RestaurantOrderItem[];
}
