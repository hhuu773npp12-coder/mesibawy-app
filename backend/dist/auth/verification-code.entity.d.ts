export declare class VerificationCode {
    id: string;
    phone: string;
    code: string;
    intendedRole?: string | null;
    name?: string | null;
    expiresAt: Date;
    used: boolean;
    createdAt: Date;
    updatedAt: Date;
}
