import { Repository } from 'typeorm';
import { User } from '../users/user.entity';
import { VerificationCode } from '../auth/verification-code.entity';
import { ApprovalsService } from '../approvals/approvals.service';
declare class DecisionBody {
    adminId: string;
    note?: string;
}
export declare class AdminController {
    private readonly approvals;
    private readonly usersRepo;
    private readonly codesRepo;
    constructor(approvals: ApprovalsService, usersRepo: Repository<User>, codesRepo: Repository<VerificationCode>);
    listApprovals(status?: 'PENDING' | 'APPROVED' | 'REJECTED'): Promise<import("../approvals/approval.entity").Approval[]>;
    approve(id: string, body: DecisionBody): Promise<import("../approvals/approval.entity").Approval>;
    reject(id: string, body: DecisionBody): Promise<import("../approvals/approval.entity").Approval>;
    listCodes(phone?: string): Promise<VerificationCode[]>;
    listUsers(role?: User['role'], approved?: 'true' | 'false', q?: string): Promise<User[]>;
    setUserRole(id: string, body: {
        role: User['role'];
    }): Promise<User | null>;
    setUserApproval(id: string, body: {
        approved: boolean;
    }): Promise<User | null>;
}
export {};
