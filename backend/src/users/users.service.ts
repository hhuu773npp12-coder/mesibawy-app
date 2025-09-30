import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly repo: Repository<User>,
  ) {}

  private generateUserId(): string {
    // Simple unique-like id: U + timestamp + base36 random
    const rand = Math.random().toString(36).slice(2, 8).toUpperCase();
    return `U${Date.now().toString(36).toUpperCase()}${rand}`;
  }

  async create(dto: CreateUserDto): Promise<User> {
    const user = this.repo.create({
      ...dto,
      userId: this.generateUserId(),
      isApproved: false,
      isActive: true,
      walletBalance: 0,
    });
    return this.repo.save(user);
  }

  findAll(): Promise<User[]> {
    return this.repo.find({ order: { createdAt: 'DESC' } });
  }

  async findOne(id: string): Promise<User> {
    const user = await this.repo.findOne({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async update(id: string, dto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id);
    Object.assign(user, dto);
    return this.repo.save(user);
  }

  async updateLocation(id: string, lastLat?: number, lastLng?: number): Promise<User> {
    const user = await this.findOne(id);
    if (typeof lastLat === 'number') user.lastLat = lastLat;
    if (typeof lastLng === 'number') user.lastLng = lastLng;
    return this.repo.save(user);
  }

  async findActiveCandidatesByRoles(roles: UserRole[], minWallet = 0): Promise<Array<{ id: string; active: boolean; walletBalance: number; lat?: number; lng?: number }>> {
    const users = await this.repo.find({ where: roles.map((r) => ({ role: r as any } as any)) });
    return users
      .filter((u) => u.isActive && (u.walletBalance ?? 0) >= minWallet && typeof u.lastLat === 'number' && typeof u.lastLng === 'number')
      .map((u) => ({ id: u.id, active: u.isActive, walletBalance: u.walletBalance ?? 0, lat: u.lastLat!, lng: u.lastLng! }));
  }

  async remove(id: string): Promise<void> {
    const user = await this.findOne(id);
    await this.repo.remove(user);
  }
}
