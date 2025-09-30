import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('request-code')
  requestCode(@Body() body: { phone: string; intendedRole?: string; name?: string }) {
    return this.auth.requestCode(body.phone, body.intendedRole, body.name);
  }

  @Post('verify')
  verify(@Body() body: { phone: string; code: string; intendedRole?: string; name?: string }) {
    return this.auth.verify(body.phone, body.code, body.intendedRole, body.name);
  }

  @Post('admin-owner-login')
  adminOwnerLogin(@Body() body: { name: string; phone: string; role: 'admin' | 'owner'; secret: string }) {
    return this.auth.adminOwnerLogin(body);
  }
}
