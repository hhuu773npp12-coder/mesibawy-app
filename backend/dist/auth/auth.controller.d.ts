import { AuthService } from './auth.service';
export declare class AuthController {
    private readonly auth;
    constructor(auth: AuthService);
    requestCode(body: {
        phone: string;
        intendedRole?: string;
        name?: string;
    }): Promise<{
        id: string;
        phone: string;
        code: string;
        expiresAt: Date;
    }>;
    verify(body: {
        phone: string;
        code: string;
        intendedRole?: string;
        name?: string;
    }): Promise<{
        token: string;
        user: import("../users/user.entity").User;
    }>;
    adminOwnerLogin(body: {
        name: string;
        phone: string;
        role: 'admin' | 'owner';
        secret: string;
    }): Promise<{
        token: string;
        user: import("../users/user.entity").User;
    }>;
}
