import { Repository } from 'typeorm';
import { User, UserRole } from './user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
export declare class UsersService {
    private readonly repo;
    constructor(repo: Repository<User>);
    private generateUserId;
    create(dto: CreateUserDto): Promise<User>;
    findAll(): Promise<User[]>;
    findOne(id: string): Promise<User>;
    update(id: string, dto: UpdateUserDto): Promise<User>;
    updateLocation(id: string, lastLat?: number, lastLng?: number): Promise<User>;
    findActiveCandidatesByRoles(roles: UserRole[], minWallet?: number): Promise<Array<{
        id: string;
        active: boolean;
        walletBalance: number;
        lat?: number;
        lng?: number;
    }>>;
    remove(id: string): Promise<void>;
}
