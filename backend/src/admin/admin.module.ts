import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminController } from './admin.controller';
import { UsersModule } from '../users/users.module';
import { ApprovalsModule } from '../approvals/approvals.module';
import { User } from '../users/user.entity';
import { VerificationCode } from '../auth/verification-code.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([User, VerificationCode]),
    UsersModule,
    ApprovalsModule,
  ],
  controllers: [AdminController],
})
export class AdminModule {}
