import { Controller, Get, Param, Post, Body, UseGuards, Req } from '@nestjs/common';
import { WalletsService } from './wallets.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('wallets')
export class WalletsController {
  constructor(private readonly wallets: WalletsService) {}

  @Get(':userId/balance')
  getBalance(@Param('userId') userId: string) {
    return this.wallets.getBalance(userId);
  }

  @Get(':userId/transactions')
  list(@Param('userId') userId: string) {
    return this.wallets.listTransactions(userId);
  }

  @Post(':userId/credit')
  credit(@Param('userId') userId: string, @Body() body: { amount: number; reference?: string }) {
    return this.wallets.addTransaction(userId, Math.abs(body.amount), 'CREDIT', body.reference);
  }

  @Post(':userId/debit')
  debit(@Param('userId') userId: string, @Body() body: { amount: number; reference?: string }) {
    return this.wallets.addTransaction(userId, -Math.abs(body.amount), 'DEBIT', body.reference);
  }

  // Secure top-up for current authenticated user
  @Post('me/topup')
  @UseGuards(JwtAuthGuard)
  topupMe(@Req() req: any, @Body() body: { code: string }) {
    const userId = req.user?.sub as string;
    return this.wallets.topupByCode(userId, (body.code || '').toString());
  }
}
