import { Repository } from 'typeorm';
import { Campaign } from './campaign.entity';
import { CampaignBooking } from './campaign-booking.entity';
import { User } from '../users/user.entity';
import { NotificationsService } from '../notifications/notifications.service';
export declare class CampaignsService {
    private readonly repo;
    private readonly bookingRepo;
    private readonly usersRepo;
    private readonly notifications?;
    constructor(repo: Repository<Campaign>, bookingRepo: Repository<CampaignBooking>, usersRepo: Repository<User>, notifications?: NotificationsService | undefined);
    create(data: {
        title: string;
        originArea: string;
        seatsTotal: number;
        pricePerSeat: number;
    }): Promise<Campaign>;
    list(): Promise<Campaign[]>;
    sharePlaceholder(id: string): Promise<{
        ok: boolean;
        message: string;
        campaignId: string;
    }>;
    book(campaignId: string, userId: string, count?: number): Promise<{
        ok: boolean;
        bookingIds: string[];
        count: number;
        remaining: number;
    }>;
    adminListBookings(campaignId: string): Promise<CampaignBooking[]>;
}
