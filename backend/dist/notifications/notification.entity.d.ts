import { User } from '../users/user.entity';
export declare class NotificationEntity {
    id: string;
    user: User;
    title: string;
    body: string;
    read: boolean;
    createdAt: Date;
}
