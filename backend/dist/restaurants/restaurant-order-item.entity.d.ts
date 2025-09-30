import { RestaurantOrder } from './restaurant-order.entity';
import { RestaurantOffer } from './restaurant-offer.entity';
export declare class RestaurantOrderItem {
    id: string;
    order: RestaurantOrder;
    offer: RestaurantOffer;
    qty: number;
    price: number;
}
