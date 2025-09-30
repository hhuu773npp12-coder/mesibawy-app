import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { VerificationCode } from './verification-code.entity';
import { JwtService } from '@nestjs/jwt';
import { User, UserRole } from '../users/user.entity';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(VerificationCode)
    private readonly codesRepo: Repository<VerificationCode>,
    @InjectRepository(User)
    private readonly usersRepo: Repository<User>,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  private generate4Digit(): string {
    return Math.floor(1000 + Math.random() * 9000).toString();
  }

  async requestCode(phone: string, intendedRole?: string, name?: string) {
    const now = new Date();
    const expires = new Date(now.getTime() + 5 * 60 * 1000); // 5 minutes

    // Invalidate previous active codes for this phone
    await this.codesRepo.update({ phone, used: false }, { used: true });

    const code = this.generate4Digit();
    const vc = this.codesRepo.create({ phone, code, expiresAt: expires, used: false, intendedRole: intendedRole ?? null, name: name ?? null });
    const saved = await this.codesRepo.save(vc);

    // NOTE: في النسخة الفعلية سيتم إرسال الكود إلى لوحة الأدمن و/أو إشعار.
    // الآن نُعيد الكود في الاستجابة للتجربة فقط.
    return { id: saved.id, phone, code, expiresAt: saved.expiresAt };
  }

  async verify(phone: string, code: string, intendedRole?: string, name?: string) {
    const existing = await this.codesRepo.findOne({ where: { phone, code } });
    if (!existing) throw new NotFoundException('Invalid code');
    if (existing.used) throw new BadRequestException('Code already used');
    if (existing.expiresAt.getTime() < Date.now()) throw new BadRequestException('Code expired');

    existing.used = true;
    await this.codesRepo.save(existing);

    // Find or create user by phone as a basic flow (will be adjusted per role later)
    let user = await this.usersRepo.findOne({ where: { phone } });
    if (!user) {
      const role: UserRole = ((existing.intendedRole || intendedRole) as UserRole) || 'citizen';
      user = this.usersRepo.create({
        phone,
        name: (existing.name || name || 'مستخدم') as string,
        role,
        userId: `U${Date.now().toString(36).toUpperCase()}`,
        isApproved: false,
        isActive: true,
        walletBalance: 0,
      });
      user = await this.usersRepo.save(user);
    }

    const payload = { sub: user.id, phone: user.phone, role: user.role };
    const token = await this.jwt.signAsync(payload);
    return { token, user };
  }

  // Admin/Owner direct login without OTP
  private get adminSecrets(): string[] {
    const raw = this.config.get<string>('ADMIN_SECRETS', '') || '';
    const list = raw.split(',').map((s) => s.trim()).filter(Boolean);
    // safe minimal defaults for development only
    return list.length ? list : ['914206'];
  }
  private get ownerSecrets(): string[] {
    const raw = this.config.get<string>('OWNER_SECRETS', '') || '';
    const list = raw.split(',').map((s) => s.trim()).filter(Boolean);
    return list.length ? list : ['519740'];
  }

  async adminOwnerLogin(input: { name: string; phone: string; role: 'admin' | 'owner'; secret: string }) {
    const { name, phone, role, secret } = input;
    const list = role === 'admin' ? this.adminSecrets : this.ownerSecrets;
    if (!list.includes(secret)) throw new BadRequestException('Invalid secret');

    // enforce max counts: 10 admins, 2 owners
    const max = role === 'admin' ? 10 : 2;
    const count = await this.usersRepo.count({ where: { role } });
    // allow login for existing users even if limit reached
    let user = await this.usersRepo.findOne({ where: { phone } });

    if (!user) {
      if (count >= max) throw new BadRequestException('Max accounts reached for role');
      user = this.usersRepo.create({
        phone,
        name: name || 'مستخدم',
        role: role as UserRole,
        userId: `U${Date.now().toString(36).toUpperCase()}`,
        isApproved: true, // direct approval for admin/owner
        isActive: true,
        walletBalance: 0,
      });
      user = await this.usersRepo.save(user);
    } else {
      // ensure role alignment
      user.role = role as UserRole;
      user.name = name || user.name;
      user.isApproved = true;
      await this.usersRepo.save(user);
    }

    const payload = { sub: user.id, phone: user.phone, role: user.role };
    const token = await this.jwt.signAsync(payload);
    return { token, user };
  }
}
