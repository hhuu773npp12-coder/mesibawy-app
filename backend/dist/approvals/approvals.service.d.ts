import { Repository } from 'typeorm';
import { Approval, ApprovalStatus } from './approval.entity';
import { User } from '../users/user.entity';
export declare class ApprovalsService {
    private readonly repo;
    private readonly usersRepo;
    constructor(repo: Repository<Approval>, usersRepo: Repository<User>);
    list(status?: ApprovalStatus): Promise<Approval[]>;
    createForUser(userId: string): Promise<Approval>;
    approve(id: string, adminId: string, note?: string): Promise<Approval>;
    reject(id: string, adminId: string, note?: string): Promise<Approval>;
}
