import { ConfigService } from '@nestjs/config';
import { Repository } from 'typeorm';
import { NotificationEntity } from './notification.entity';
import { User } from '../users/user.entity';
export declare class NotificationsService {
    private readonly config;
    private readonly repo;
    private readonly usersRepo;
    private appId;
    private apiKey;
    constructor(config: ConfigService, repo: Repository<NotificationEntity>, usersRepo: Repository<User>);
    private ensureConfigured;
    sendToAll(title: string, message: string, data?: Record<string, any>): Promise<any>;
    sendToExternalUserIds(userIds: string[], title: string, message: string, data?: Record<string, any>): Promise<any>;
    sendToTags(tags: Array<{
        key: string;
        relation: '=' | '!=' | 'exists' | 'not_exists' | '>' | '<';
        value?: string;
    }>, title: string, message: string, data?: Record<string, any>): Promise<any>;
    listForUser(userId: string): Promise<NotificationEntity[]>;
    markAllRead(userId: string): Promise<{
        ok: boolean;
        unread: number;
    }>;
}
