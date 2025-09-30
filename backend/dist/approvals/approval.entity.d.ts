import { User } from '../users/user.entity';
export type ApprovalStatus = 'PENDING' | 'APPROVED' | 'REJECTED';
export declare class Approval {
    id: string;
    user: User;
    status: ApprovalStatus;
    decidedByAdminId: string | null;
    note: string | null;
    createdAt: Date;
    updatedAt: Date;
}
