import { Campaign } from './campaign.entity';
import { User } from '../users/user.entity';
export type CampaignBookingStatus = 'BOOKED' | 'CANCELLED';
export declare class CampaignBooking {
    id: string;
    campaign: Campaign;
    user: User;
    status: CampaignBookingStatus;
    createdAt: Date;
}
