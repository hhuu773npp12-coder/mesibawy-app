export declare class RestaurantSettlement {
    id: string;
    restaurantOwnerId: string;
    ordersCount: number;
    totalAmount: number;
    taxAmount: number;
    dueAmount: number;
    paidAt?: Date | null;
    createdAt: Date;
    updatedAt: Date;
}
