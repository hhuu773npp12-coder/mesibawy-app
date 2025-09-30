import { Repository } from 'typeorm';
import { Order } from './order.entity';
import { PricingService, Category } from '../pricing/pricing.service';
import { User } from '../users/user.entity';
import { RestaurantOffer } from '../restaurants/restaurant-offer.entity';
export declare class OrdersService {
    private readonly repo;
    private readonly usersRepo;
    private readonly offersRepo;
    private readonly pricing;
    constructor(repo: Repository<Order>, usersRepo: Repository<User>, offersRepo: Repository<RestaurantOffer>, pricing: PricingService);
    estimateAndCreate(input: {
        userId?: string;
        category: Category;
        distanceKm: number;
        durationMin?: number;
    }): Promise<{
        order: Order;
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
    listAdmin(limit?: number, filters?: {
        category?: string;
        status?: string;
        dateFrom?: string;
        dateTo?: string;
    }): Promise<Order[]>;
    createFoodOrder(userId: string, input: {
        offerId: string;
        quantity: number;
        notes?: string;
    }): Promise<Order>;
    listRestaurantOrders(ownerUserId: string, stage?: string): Promise<Order[]>;
    updateRestaurantOrderStage(orderId: string, stage: 'accepted' | 'preparing' | 'delivering' | 'completed' | 'rejected'): Promise<Order>;
    getByIdForUser(userId: string, orderId: string): Promise<Order>;
}
