import { ConfigService } from '@nestjs/config';
export interface JwtPayload {
    sub: string;
    phone: string;
    role: string;
}
declare const JwtStrategy_base: new (...args: any) => any;
export declare class JwtStrategy extends JwtStrategy_base {
    constructor(config: ConfigService);
    validate(payload: JwtPayload): Promise<JwtPayload>;
}
export {};
