export type UserRole = 'citizen' | 'taxi' | 'tuk_tuk' | 'kia_haml' | 'kia_passenger' | 'stuta' | 'bike' | 'electrician' | 'plumber' | 'ac_tech' | 'blacksmith' | 'restaurant_owner' | 'admin' | 'owner';
export declare class User {
    id: string;
    userId: string;
    name: string;
    phone: string;
    role: UserRole;
    isApproved: boolean;
    isActive: boolean;
    walletBalance: number;
    lastLat?: number | null;
    lastLng?: number | null;
    vehicleType?: string | null;
    vehicleColor?: string | null;
    plateNumber?: string | null;
    plateImageUrl?: string | null;
    craftType?: string | null;
    createdAt: Date;
    updatedAt: Date;
}
