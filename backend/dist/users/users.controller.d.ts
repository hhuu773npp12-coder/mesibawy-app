import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    findAll(): Promise<import("./user.entity").User[]>;
    findOne(id: string): Promise<import("./user.entity").User>;
    me(req: any): Promise<import("./user.entity").User>;
    create(dto: CreateUserDto): Promise<import("./user.entity").User>;
    update(id: string, dto: UpdateUserDto): Promise<import("./user.entity").User>;
    updateLocation(id: string, body: {
        lastLat?: number;
        lastLng?: number;
    }): Promise<import("./user.entity").User>;
    remove(id: string): Promise<void>;
}
