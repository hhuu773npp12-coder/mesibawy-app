import { NotificationsService } from './notifications.service';
export declare class NotificationsController {
    private readonly notifications;
    constructor(notifications: NotificationsService);
    broadcast(body: {
        title: string;
        message: string;
        data?: Record<string, any>;
    }): Promise<any>;
    toUsers(body: {
        userIds: string[];
        title: string;
        message: string;
        data?: Record<string, any>;
    }): Promise<any>;
    toTags(body: {
        tags: Array<{
            key: string;
            relation: '=' | '!=' | 'exists' | 'not_exists' | '>' | '<';
            value?: string;
        }>;
        title: string;
        message: string;
        data?: Record<string, any>;
    }): Promise<any>;
}
