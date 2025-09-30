import { ApprovalsService } from './approvals.service';
declare class CreateApprovalBody {
    userId: string;
}
declare class DecisionBody {
    adminId: string;
    note?: string;
}
export declare class ApprovalsController {
    private readonly approvals;
    constructor(approvals: ApprovalsService);
    list(status?: string): Promise<import("./approval.entity").Approval[]>;
    create(body: CreateApprovalBody): Promise<import("./approval.entity").Approval>;
    approve(id: string, body: DecisionBody): Promise<import("./approval.entity").Approval>;
    reject(id: string, body: DecisionBody): Promise<import("./approval.entity").Approval>;
}
export {};
