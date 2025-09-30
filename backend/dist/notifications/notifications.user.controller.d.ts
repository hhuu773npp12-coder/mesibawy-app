import { NotificationsService } from './notifications.service';
export declare class NotificationsUserController {
    private readonly notifications;
    constructor(notifications: NotificationsService);
    listMine(req: any): Promise<import("./notification.entity").NotificationEntity[]>;
    markAllRead(req: any): Promise<{
        ok: boolean;
        unread: number;
    }>;
}
