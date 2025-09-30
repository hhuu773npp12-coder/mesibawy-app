import { Repository } from 'typeorm';
import { VerificationCode } from './verification-code.entity';
import { JwtService } from '@nestjs/jwt';
import { User } from '../users/user.entity';
import { ConfigService } from '@nestjs/config';
export declare class AuthService {
    private readonly codesRepo;
    private readonly usersRepo;
    private readonly jwt;
    private readonly config;
    constructor(codesRepo: Repository<VerificationCode>, usersRepo: Repository<User>, jwt: JwtService, config: ConfigService);
    private generate4Digit;
    requestCode(phone: string, intendedRole?: string, name?: string): Promise<{
        id: string;
        phone: string;
        code: string;
        expiresAt: Date;
    }>;
    verify(phone: string, code: string, intendedRole?: string, name?: string): Promise<{
        token: string;
        user: User;
    }>;
    private get adminSecrets();
    private get ownerSecrets();
    adminOwnerLogin(input: {
        name: string;
        phone: string;
        role: 'admin' | 'owner';
        secret: string;
    }): Promise<{
        token: string;
        user: User;
    }>;
}
