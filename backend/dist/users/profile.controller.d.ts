import { Repository } from 'typeorm';
import { User } from './user.entity';
export declare class ProfileController {
    private readonly usersRepo;
    constructor(usersRepo: Repository<User>);
    upsertVehicle(req: any, body: {
        vehicleType: 'taxi' | 'tuk_tuk' | 'kia_haml' | 'kia_passenger' | 'stuta' | 'bike';
        vehicleColor?: string;
        plateNumber?: string;
        plateImageUrl?: string;
    }): Promise<{
        ok: boolean;
        message: string;
        user?: undefined;
    } | {
        ok: boolean;
        user: User;
        message?: undefined;
    }>;
    upsertCraft(req: any, body: {
        craftType: 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech';
        photos?: string[];
    }): Promise<{
        ok: boolean;
        message: string;
        user?: undefined;
    } | {
        ok: boolean;
        user: User;
        message?: undefined;
    }>;
}
