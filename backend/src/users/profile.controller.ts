import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { User } from './user.entity';

@Controller('profile')
@UseGuards(JwtAuthGuard)
export class ProfileController {
  constructor(@InjectRepository(User) private readonly usersRepo: Repository<User>) {}

  @Post('vehicle')
  async upsertVehicle(
    @Req() req: any,
    @Body()
    body: {
      vehicleType: 'taxi' | 'tuk_tuk' | 'kia_haml' | 'kia_passenger' | 'stuta' | 'bike';
      vehicleColor?: string;
      plateNumber?: string;
      plateImageUrl?: string; // TODO: switch to real file upload endpoint later
    },
  ) {
    const userId = req.user?.sub as string;
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) return { ok: false, message: 'User not found' };

    user.vehicleType = body.vehicleType;
    user.vehicleColor = body.vehicleColor ?? null;
    user.plateNumber = body.plateNumber ?? null;
    user.plateImageUrl = body.plateImageUrl ?? null;
    await this.usersRepo.save(user);

    return { ok: true, user };
  }

  @Post('craft')
  async upsertCraft(
    @Req() req: any,
    @Body()
    body: {
      craftType: 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech';
      photos?: string[]; // TODO: switch to real file upload endpoint later
    },
  ) {
    const userId = req.user?.sub as string;
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) return { ok: false, message: 'User not found' };

    user.craftType = body.craftType;
    // photos are not persisted yet; will be added when file storage is ready
    await this.usersRepo.save(user);

    return { ok: true, user };
  }
}
