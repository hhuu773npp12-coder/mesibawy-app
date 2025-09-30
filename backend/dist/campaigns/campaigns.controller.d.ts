import { CampaignsService } from './campaigns.service';
export declare class CampaignsController {
    private readonly campaigns;
    constructor(campaigns: CampaignsService);
    create(body: {
        title: string;
        originArea: string;
        seatsTotal: number;
        pricePerSeat: number;
    }): Promise<import("./campaign.entity").Campaign>;
    list(): Promise<import("./campaign.entity").Campaign[]>;
    share(id: string): Promise<{
        ok: boolean;
        message: string;
        campaignId: string;
    }>;
    listBookings(id: string): Promise<import("./campaign-booking.entity").CampaignBooking[]>;
}
