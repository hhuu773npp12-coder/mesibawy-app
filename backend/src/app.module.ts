import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { ApprovalsModule } from './approvals/approvals.module';
import { WalletsModule } from './wallets/wallets.module';
import { CardsModule } from './cards/cards.module';
import { NotificationsModule } from './notifications/notifications.module';
import { AuthModule } from './auth/auth.module';
import { AdminModule } from './admin/admin.module';
import { CampaignsModule } from './campaigns/campaigns.module';
import { StudentLinesModule } from './student-lines/student-lines.module';
import { PricingModule } from './pricing/pricing.module';
import { OrdersModule } from './orders/orders.module';
import { FilesModule } from './files/files.module';
import { RestaurantsModule } from './restaurants/restaurants.module';
import { OwnerModule } from './owner/owner.module';
import { CraftsModule } from './crafts/crafts.module';
import { DriverJobsModule } from './driver-jobs/driver_jobs.module';
import { MatchingModule } from './matching/matching.module';
import { DevSeedModule } from './dev-seed/dev-seed.module';

@Module({
  imports: [
    // Load environment variables from .env
    ConfigModule.forRoot({ isGlobal: true }),
    // Database connection
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get<string>('DB_HOST', '127.0.0.1'),
        port: parseInt(config.get<string>('DB_PORT', '5432'), 10),
        username: config.get<string>('DB_USER', 'postgres'),
        password: config.get<string>('DB_PASS', ''),
        database: config.get<string>('DB_NAME', 'mesibawy'),
        autoLoadEntities: true,
        synchronize: config.get<string>('NODE_ENV') === 'development',
        logging: false,
      }),
    }),
    UsersModule,
    ApprovalsModule,
    WalletsModule,
    CardsModule,
    NotificationsModule,
    AuthModule,
    AdminModule,
    CampaignsModule,
    StudentLinesModule,
    PricingModule,
    OrdersModule,
    FilesModule,
    RestaurantsModule,
    OwnerModule,
    CraftsModule,
    DriverJobsModule,
    MatchingModule,
    DevSeedModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
